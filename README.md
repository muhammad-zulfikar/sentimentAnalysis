# Sentiment Analysis Project in RStudio

This project is part of the "Big Data in International Relations" course. The task of the project is to generate a sentiment analysis visualization between Donald Trump and Hillary Clinton from journal articles and published papers.

For comprehensive reports you can refer to this [markdown website](https://muhammad-zulfikar.github.io/bigDataInInternationalRelations/Task-2.html)

## Project Structure
```
sentimentAnalysis
├── dataCleaningAndVisualizing.R
├── dataScraping.R
└── pdf
├── donald trump
│ ├── <filename>.pdf
│ ├── <filename>.pdf
│ ├── <filename>.pdf
│ └── ...
└── hillary clinton
├── <filename>.pdf
├── <filename>.pdf
├── <filename>.pdf
└── ....
```

### dataScraping.R

The [`dataScraping.R`](https://github.com/muhammad-zulfikar/googleScholarPdfScraping) script is used to scrape journal articles and published papers from Google Scholar and store them in separate folders for Donald Trump and Hillary Clinton.

```R
# Run the function
scrape_google_scholar("hillary+clinton", 20, "pdf/hillary+clinton")
```

### dataCleaningAndVisualizing.R

The `dataCleaningAndVisualizing.R` script reads the downloaded PDFs, cleans the text data, performs sentiment analysis, and visualizes the results.

```R
# Visualize sentiment analysis
sentiment_plot <- ggplot(text_sentiment, aes(x = label, y = n, fill = sentiment)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("negative" = "red", "positive" = "green")) +
  labs(title = "Sentiment Analysis between Donald Trump and Hillary Clinton",
       x = "Label",
       y = "Count",
       fill = "Sentiment") +
  theme_minimal() +
  theme(axis.text.x = element_text(hjust = 1))
```

### output

![sentimentAnalysis(Journal).png](output/sentimentAnalysis(Journal).png)
