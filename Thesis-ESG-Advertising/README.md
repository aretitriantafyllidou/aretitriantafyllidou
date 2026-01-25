#  ESG Communication, Trust and Financial Performance

**Master’s Thesis – Erasmus University Rotterdam (2025)**  
**Author:** Areti Triantafyllidou  
**Supervisor:** Lars Gemmer  
**Completion:** October 2025

For my Master’s thesis, I investigated how Environmental, Social, and Governance (ESG) communication campaigns influence consumer trust on social media and short-term stock performance.

This analysis applies data science, machine learning and finance techniques in real-world marketing campaigns. For the data, I collected thousands of social media comments from YouTube and Twitter via API authentication, processed them and applied sentiment analysis and purchase-intent detection NLP models (RoBERTa, BART). Then i measured Financial performance with abnormal returns around ESG launch dates, using stock price data from Yahoo Finance.

---

###  Key Methodology:

- Identifying the appropriate advertising
- Data Collection via APIs (YouTube, Twitter)
- Text Cleaning, Translation & NLP Preprocessing  
- Sentiment Classification using RoBERTa and BART Transformers  
- Event Study Analysis (CAR, BHAR)  
- Cross-sectional Regressions & Hypothesis Testing (OLS, ANOVA)  
- Visualization of Campaign Outcomes 


### Tools & Tech Stack
- Python (Pandas, Scikit-learn, Transformers – RoBERTa, BART) — preprocessing, feature engineering, and machine learning modeling.  
- R (quantmod, lm, eventstudies) — econometric modeling, robust regression, and event study analysis.  
- APIs (YouTube, Twitter) · yfinance — social media and financial data collection.  
- NLP · Sentiment Analysis · Zero-shot Classification · Event Study Analysis — methods used for text classification and campaign impact evaluation.


###  Highlights

**Results summary:**  
- Environmental campaigns generally received the most positive public sentiment.  
- Governance messages tended to trigger higher skepticism.  
- ESG advertising had no short-term stock impact, but authenticity strongly influenced consumer trust


###  Data Collection
Public engagement data were scraped from YouTube and Twitter campaigns through a combination of official APIs and automated collection tools. All comments were anonymized and aggregated to ensure privacy.  

---

###  Repository Guide
 [`Areti Triantafyllidou Thesis.pdf`](Areti%20Triantafyllidou%20Thesis.pdf) – Full thesis document  
 `/code/` → Python and R scripts for NLP, sentiment, and econometrics  
 `/sample_data/` → Synthetic examples (real ad data confidential)  

>  *All advertising data are anonymized or synthetic. Real datasets are not shared for confidentiality reasons.*


