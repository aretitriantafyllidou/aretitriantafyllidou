
# in this script we do sentiment analysis and we creates the variable of content and message framing


# libraries
library(dplyr)
library(tidytext)
library(stringr)
library(syuzhet)
library(readr)
library(purrr)
library(scales)
library(DescTools)




# Load dataset

social_media_data <- read_delim(
  "data/social_media_postings_translations.csv", 
  delim = ";", 
  quote = "\"", 
  col_types = cols()
)

 nrow(social_media_data)

# Remove duplicate post_id values
social_media_data <- social_media_data %>%
  distinct(post_id, .keep_all = TRUE)

 nrow(social_media_data), 

# Remove unnecessary columns
columns_to_remove <- c(
  "V1", "post", "date", "profile", "organic_impressions", 
  "paid_impressions", "organic_reach", "paid-reach", "potential_reach", 
  "dislikes", "saves", "post_link_clicks", "sproutlink_clicks", 
  "other_post_clicks", "other_engagements", "subscribers_gained_from_video", 
  "annotation_clicks", "card_clicks", "organic_video_views", "paid_video_views", 
  "organic_partial_video_views", "paid_partial_video_views", 
  "organic_full_video_views", "paid_full_video_views", "full_video_view_rate", 
  "follow_video_views", "for_you_video_views", "hashtag_video_views", 
  "business_account_video_views", "sound_video_views", "unspecified_video_views", 
  "estimated_minutes_watched", "story_taps_back", "story_taps_forward", 
  "story_exits", "story_replies", "video_added_to_playlists", 
  "subscribers_lost_from_video", "love_reactions", "haha_reactions", 
  "wow_reactions", "sad_reactions", "angry_reactions", "video_views", 
  "partial_video_views", "full_video_views", "engagement_rate_per_impression",
  "average_video_time_watched_seconds", "video_removed_from_playlists", 
  "poll_votes", "tags", "call_id"
)

social_media_data <- social_media_data %>%
  select(-one_of(columns_to_remove))

# Remove rows with missing translations
original_count <- nrow(social_media_data)
social_media_data <- social_media_data %>%
  filter(!is.na(translation))

 nrow(social_media_data)

#calculate engagement rate


social_media_data <- social_media_data %>%
  mutate(
    engagement_rate = ifelse(
      impressions > 0,
      round((engagements / impressions) * 100, 2),
      0
    )
  )


#text process

social_media_data <- social_media_data %>%
  mutate(
    text = str_to_lower(translation),      # Convert to lowercase
    text = gsub("[[:punct:]]", "", text),  # Remove punctuation
    text = gsub("[0-9]+", "", text),       # Remove numbers
    text = str_squish(text)                # Remove extra whitespace
  )

#sentiment analysis


# Calculate sentiment scores using Syuzhet
social_media_data <- social_media_data %>%
  mutate(
    sentiment_score = map_dbl(text, ~ get_sentiment(., method = "syuzhet"))
  )

# Rescale sentiment scores to -1 to 1 range
social_media_data <- social_media_data %>%
  mutate(
    sentiment_score = scales::rescale(sentiment_score, to = c(-1, 1))
  )


# sentiment distribution

print(summary(social_media_data$sentiment_score))



# Extract emotions using NRC emotion lexicon
emotions <- get_nrc_sentiment(social_media_data$text)

#8 primary emotions
emotions <- emotions %>%
  select(anger, anticipation, disgust, fear, joy, sadness, surprise, trust)

# Add emotions to main dataset
social_media_data <- bind_cols(social_media_data, emotions)



#factual vs emotional



# we classify posts based on sentiment intensity
# we have a threshold: |sentiment| > 0.195 = Emotional, otherwise Factual
social_media_data <- social_media_data %>%
  mutate(
    post_category = ifelse(
      abs(sentiment_score) > 0.195, 
      "Emotional", 
      "Factual"
    )
  )

social_media_data$post_category <- as.factor(social_media_data$post_category)

# Display distribution
print(table(social_media_data$post_category))

##message framing

# Classify message tone based on sentiment polarity
social_media_data <- social_media_data %>%
  mutate(
    message_tone = case_when(
      sentiment_score > 0  ~ "Positive",
      sentiment_score < 0  ~ "Negative",
      TRUE                 ~ "Neutral"
    )
  )

# Convert to factor
social_media_data$message_tone <- as.factor(social_media_data$message_tone)

# Display distribution
print(table(social_media_data$message_tone))



# Plot sentiment distribution
png("results/sentiment_distribution.png", width = 800, height = 600)
hist(
  social_media_data$sentiment_score, 
  main = "Sentiment Score Distribution",
  xlab = "Sentiment Score (-1 to 1)",
  col = "lightblue", 
  border = "white",
  breaks = 30
)
dev.off()

#  relationship between content framing and message tone
crosstab <- table(social_media_data$post_category, social_media_data$message_tone)
print(crosstab)


# Calculate Cramér's V (measure of association)
cramer_v <- CramerV(crosstab)
round(cramer_v, 3)


# Linear regression: Content framing effect on engagement
lm_engagement <- lm(
  engagement_rate ~ post_category, 
  data = social_media_data
)
=print(summary(lm_engagement))

lm_reactions <- lm(
  reactions ~ post_category, 
  data = social_media_data
)
print(summary(lm_reactions))

lm_comments <- lm(
  comments ~ post_category, 
  data = social_media_data
)
print(summary(lm_comments))



# Save the final dataset with sentiment and framing variables
write.csv(
  social_media_data, 
  "data/social_media_with_sentiment.csv", 
  row.names = FALSE
)




