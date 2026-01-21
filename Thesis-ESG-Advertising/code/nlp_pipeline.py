#libraries
import os
import re
import string
import numpy as np
import pandas as pd
from transformers import pipeline
from langdetect import detect, DetectorFactory
import matplotlib.pyplot as plt
import seaborn as sns

# settings
os.environ["TOKENIZERS_PARALLELISM"] = "false"
DetectorFactory.seed = 0



#data
df = pd.read_csv("campaign_comments.csv")

if "text" not in df.columns:
    raise ValueError("Input CSV must contain a 'text' column.")
if "likes" not in df.columns:
    df["likes"] = 0

# text cleaning
URL_RE = re.compile(r"http\\S+")
USER_RE = re.compile(r"@\\w+")

def clean(txt: str) -> str:
    if pd.isna(txt):
        return ""
    txt = str(txt)
    txt = URL_RE.sub(" <URL> ", txt)
    txt = USER_RE.sub(" <USER> ", txt)
    txt = txt.translate(str.maketrans("", "", string.punctuation)).lower()
    return re.sub(r"\\s{2,}", " ", txt).strip()

df["clean"] = df["text"].apply(clean)

# language detection
def safe_detect(txt):
    try:
        return detect(txt) if txt.strip() else "unknown"
    except:
        return "unknown"

df["lang"] = df["clean"].apply(safe_detect)

lang_dist = df["lang"].value_counts()
print(lang_dist.head())

# translation to english with NLLB
from transformers import pipeline as hf_pipe
translator = hf_pipe(
    task="translation",
    model="facebook/nllb-200-distilled-600M",
    src_lang="auto",
    tgt_lang="eng_Latn",
    max_length=256,
    device_map="auto"
)
print("Translator loaded")

def to_english(row):
    if row.lang in ["en", "unknown"]:
        return row.clean
    try:
        tr = translator(row.clean, max_length=256)[0]["translation_text"]
        return str(tr).lower()
    except:
        return row.clean

df["clean_en"] = df.apply(to_english, axis=1)

# ROBERTA
sent_clf = pipeline(
    "sentiment-analysis",
    model="cardiffnlp/twitter-roberta-base-sentiment-latest",
    tokenizer="cardiffnlp/twitter-roberta-base-sentiment-latest",
    truncation=True,
    max_length=512
)
print("RoBERTa loaded")

sent_out = sent_clf(df["clean_en"].tolist(), batch_size=32)
df["roberta_sentiment"] = [o["label"].lower() for o in sent_out]
df["sent_score"] = [o["score"] for o in sent_out]

# zeroshot classification for neutral comments
zs_clf = pipeline(
    "zero-shot-classification",
    model="facebook/bart-large-mnli",
    truncation=True
)
ZS_SENTIMENT_LABELS = ["positive", "neutral", "negative"]

def classify_sentiment_zs(text):
    try:
        out = zs_clf(
            text,
            candidate_labels=ZS_SENTIMENT_LABELS,
            hypothesis_template="This comment expresses a {} sentiment."
        )
        return out["labels"][0].lower()
    except:
        return "unknown"

# Apply only to low-confidence neutrals

neutral_mask = (df["roberta_sentiment"] == "neutral") & (df["sent_score"] < 0.85)
df.loc[neutral_mask, "zero_shot_sentiment"] = df.loc[neutral_mask, "clean_en"].apply(classify_sentiment_zs)

#final sentiment
emotional_positive_phrases = [
    "made me cry", "i cried", "crying", "tears", "tear", "emotional",
    "so touching", "cry", "cryingface", "loudlycryingface", "beautiful", "inspiring",
    "goosebumps", "love this", "uplifting", "empowering", "resonated with me",
    "gave me chills", "stunning", "heartwarming", "hit me hard", "tear up",
    "not crying", "i’m crying", "this hit me", "teared up", "😭", "🥲", "🥹"
]

def is_emotional_positive(text):
    text_lower = str(text).lower()
    return any(p in text_lower for p in emotional_positive_phrases)

def choose_final_sentiment(row):
    if is_emotional_positive(row.get("clean_en", "")):
        return "positive"
    if row["roberta_sentiment"] != "neutral":
        return row["roberta_sentiment"]
    if row["sent_score"] >= 0.85:
        return "neutral"
    zs = row.get("zero_shot_sentiment", "unknown")
    if zs in ["positive", "negative"]:
        return zs
    return "neutral"

df["final_sentiment"] = df.apply(choose_final_sentiment, axis=1)

# weight sentiment with more likes 
df["weight"] = np.sqrt(df["likes"].fillna(0) + 1)
sent_val_map = {"positive": 1, "neutral": 0, "negative": -1}
df["sent_val"] = df["final_sentiment"].map(sent_val_map)
weighted_net = (df["sent_val"] * df["weight"]).sum() / df["weight"].sum()

# purchase intetnion 
import re as _re

POS_KW = {"buy", "buying", "bought", "purchase", "order", "ordered", "need this", "eat"}
NEG_KW = {
    "won't buy", "not buy", "never take", "will not buy", "not buying", "too expensive",
    "overpriced", "pricey", "out of budget", "won't eat", "will not eat", "never eat",
    "can't afford", "waste of money", "never buy", "scam"
}

def has_kw(text, kw_set):
    t = str(text).lower()
    for kw in kw_set:
        if " " in kw:
            if kw in t:
                return True
        else:
            if _re.search(rf"\\b{_re.escape(kw)}\\b", t):
                return True
    return False

def classify_purchase_keywords(text):
    if has_kw(text, POS_KW):
        return "Purchase_Pos"
    if has_kw(text, NEG_KW):
        return "Purchase_Neg"
    return "NoPurchase"

df["purchase_intent_keywords"] = df["clean_en"].apply(classify_purchase_keywords)

# purchase intent with zero shot classification
ZS_PURCHASE_LABELS = ["Purchase_Pos", "Purchase_Neg", "NoPurchase"]

def classify_purchase_zs(text):
    try:
        out = zs_clf(
            text,
            candidate_labels=ZS_PURCHASE_LABELS,
            hypothesis_template="This comment expresses {} behavior."
        )
        return out["labels"][0]
    except:
        return "unknown"

df["purchase_intent_zs"] = df["clean_en"].apply(classify_purchase_zs)

##  Weighted Net Sentiment

#Calculate weighted sentiment using likes as engagement weight.

df["weight"] = np.sqrt(df["likes"].fillna(0) + 1)
sent_val_map = {"positive": 1, "neutral": 0, "negative": -1}
df["sent_val"] = df["final_sentiment"].map(sent_val_map)
weighted_net = (df["sent_val"] * df["weight"]).sum() / df["weight"].sum()

print(f"\n Weighted Net Sentiment: {weighted_net:.3f}")


print("\\nFINAL SUMMARY:")
print("\\nSentiment counts:\\n", df["final_sentiment"].value_counts())
print("\\nWeighted Net Sentiment:", round(float(weighted_net), 3))
print("\\nPurchase Intent (keywords):\\n", df["purchase_intent_keywords"].value_counts())
print("\\nPurchase Intent (zero-shot):\\n", df["purchase_intent_zs"].value_counts())

df.to_csv(OUTPUT_CSV, index=False)
print(f"\\nSaved: {OUTPUT_CSV}")


