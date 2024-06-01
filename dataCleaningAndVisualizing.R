# Load required libraries
library(tidyverse)
library(pdftools)
library(tidytext)
library(ggplot2)

# Set directory containing PDFs
pdf_dir <- "sentimentAnalysis/pdf"

# List all PDF files in the directory
pdf_files <- list.files(pdf_dir, full.names = TRUE)

# Read the PDF files into a data frame
text_data <- lapply(pdf_files, function(file) {
  tryCatch(
    {
      pdf_text(file)
    },
    error = function(e) {
      warning(paste("Error reading file:", file))
      return(NA)
    }
  )
}) %>%
  unlist() %>%
  na.omit() %>%
  data.frame(text = .)

# Function to clean text data
clean_text <- function(text) {
  # Convert to lowercase
  text <- tolower(text)
  
  # Remove punctuation
  text <- gsub("[[:punct:]]", " ", text)
  
  # Remove numbers
  text <- gsub("[[:digit:]]", "", text)
  
  # Remove extra white spaces
  text <- gsub("\\s+", " ", text)
  
  # Remove stop words
  text <- removeWords(text, stopwords("en"))
  
  return(text)
}

# Apply text cleaning function to the text data
text_data <- text_data %>%
  mutate(cleaned_text = map_chr(text, clean_text))

# Perform sentiment analysis for each candidate
sentiment_analysis <- text_data %>%
  mutate(candidate = case_when(
    str_detect(cleaned_text, "donald trump") ~ "Trump",
    str_detect(cleaned_text, "hillary clinton") ~ "Clinton",
    TRUE ~ "Other"
  )) %>%
  filter(candidate != "Other") %>%
  unnest_tokens(word, cleaned_text) %>%
  inner_join(get_sentiments("bing"), by = c("word" = "word")) %>%
  group_by(candidate) %>%
  summarise(sentiment_score = sum(sentiment == "positive") - sum(sentiment == "negative"))

# Plotting the sentiment analysis results
ggplot(sentiment_analysis, aes(x = candidate, y = sentiment_score, fill = candidate)) +
  geom_bar(stat = "identity") +
  labs(x = "Candidate", y = "Sentiment Score", title = "Sentiment Analysis for Trump vs Clinton") +
  theme_minimal() +
  scale_fill_manual(values = c("Trump" = "red", "Clinton" = "blue")) +
  geom_text(aes(label = sentiment_score), vjust = -0.5)
