# Social Media Engagement Analysis for UNICEF NL

In this group project we had to analyze 1,645 social media posts from UNICEF Netherlands amd find the patterns that create engagement in Facebook and Instagram. We combined text and image analytics with machine learning. Then we went to Unicef and we presented the results to them. 

---

**Tech Stack**  

- **Python**: Web scraping (BeautifulSoup, Requests), Google Vision API
- **R**: Statistical analysis (dplyr, caret, randomForest)
- **Machine Learning**: Random Forest, Linear Regression
- **NLP**: Sentiment analysis (Syuzhet package)

**Methodology**

- **Data Collection**:  1,645 social media posts were given and we scrapted associated images
- **Feature Engineering**: 
   - Sentiment analysis for content/message framing
   - Image analysis for color and luminance features
   - Rolling engagement metrics
- **Models**: 
   - Baseline linear regression
   - Random Forest with 10-fold cross-validation
- **Evaluation**: F1-scores of 0.765 (reactions), 0.695 (shares)
   

**Highlights**  
- factual framing drives higher engagement.  
- Negative framing increases engagement especially effective for shares.  
- Warm colors perform better while medium luminance underperforms.  
- Organic posts are better, sponsored posts reduce engagement.  
- previous-week engagement strongly predicts next-week results.


**Repository Guide**  
-  `docs/` → [Slides (PDF)](../docs/UNICEF_presentation.pdf) • [Final Report (PDF)](../docs/UnicefReport.pdf)  
- `scripts/` → R/Python scripts for data prep, feature engineering, and modeling  

>  Note: Dataset is not included in this repository due to privacy considerations.

