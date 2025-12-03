#  ESG Advertising & Market Reactions

**Master’s Thesis – Erasmus University Rotterdam (2025)**  
**Author:** Areti Triantafyllidou  

This project explores how Environmental, Social and Governance focused advertising, campaigns influence both consumer sentiment and financial market reactions.  
Using multilingual NLP and event-study econometrics, it quantifies how authentic, socially responsible communication impacts trust and market performance.

---

###  Tech Stack & Rationale
- **Python** (pandas, scikit-learn, transformers) — preprocessing, feature engineering, and machine learning models.  
- **R** (tidyverse, sandwich, eventstudies) — econometric modeling, robust regression, and event-study analysis.  
- **RoBERTa (Hugging Face)** — transformer-based sentiment model for multilingual and complex text.  
- **Zero-shot classification (Hugging Face)** — label detection for purchase intent and ESG theme without manual annotation.  
- **yfinance / quantmod** — financial data extraction and CAR/BHAR computation.  
- **Power BI / Looker Studio** — interactive visualization and dashboarding.  

---

###  Data Collection
Public engagement data were scraped from **YouTube** and **Twitter** campaigns through a combination of official APIs and automated collection tools.  
All comments were **anonymized** and **aggregated** to ensure privacy.  
Synthetic samples are included for reproducibility.  

---

###  Highlights
- **Authentic ESG ads → higher consumer trust**  
- **Positive sentiment** around campaigns predicts **short-term abnormal returns**  
- **Platform effect:** Twitter shows stronger sentiment volatility than YouTube  
- **Greenwashing risk** weakens market reactions  
- **Stakeholder alignment** amplifies the ESG–performance link  

---

###  Repository Guide
 [`Areti Triantafyllidou Thesis.pdf`](Areti%20Triantafyllidou%20Thesis.pdf) – Full thesis document  
 `/code/` → Python and R scripts for NLP, sentiment, and econometrics  
 `/figures/` → Sentiment and CAR/BHAR visualizations  
 `/sample_data/` → Synthetic examples (real ad data confidential)  

>  *All advertising data are anonymized or synthetic. Real datasets are not shared for confidentiality reasons.*


