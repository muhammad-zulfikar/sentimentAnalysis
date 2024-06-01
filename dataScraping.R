# Load necessary libraries
library(rvest)
library(httr)
library(tools)

# Function to create a safe filename from a URL
safe_filename <- function(url) {
  # Remove protocol and special characters
  fname <- gsub("[:/?#\\[\\]@!$&'()*+,;=]", "_", url)
  # Shorten if too long
  if (nchar(fname) > 255) {
    fname <- substr(fname, 1, 255)
  }
  return(fname)
}

# Function to scrape Google Scholar and download PDF files
scrape_google_scholar <- function(query, pages, output_dir) {
  
  # Create output directories if they do not exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # File to store metadata
  metadata_file <- file.path(output_dir, "pdf_metadata.csv")
  
  # Initialize metadata storage
  metadata <- data.frame(Link = character(), Title = character(), stringsAsFactors = FALSE)
  
  # List to track downloaded PDF links
  downloaded_links <- c()
  
  # Loop through each page
  for (i in seq(0, (pages - 1) * 10, by = 10)) {
    
    # Construct the URL
    url <- paste0("https://scholar.google.com/scholar?start=", i, "&q=", query, "&hl=en&as_sdt=0,5")
    
    # Read the page content
    page <- read_html(url)
    
    # Extract PDF links
    links <- page %>% html_nodes("a") %>% html_attr("href")
    
    # Filter PDF links
    pdf_links <- links[grepl("\\.pdf$", links)]
    
    # Download each PDF if not already downloaded
    for (pdf_link in pdf_links) {
      if (!(pdf_link %in% downloaded_links)) {
        safe_name <- safe_filename(pdf_link)
        pdf_file <- file.path(output_dir, paste0(safe_name, ".pdf"))
        
        tryCatch({
          download.file(pdf_link, pdf_file, mode = "wb")
          # Append metadata
          metadata <- rbind(metadata, data.frame(Link = pdf_link, Title = safe_name, stringsAsFactors = FALSE))
          downloaded_links <- c(downloaded_links, pdf_link)
        }, error = function(e) {
          message("Failed to download ", pdf_link, ": ", e)
        })
      } else {
        message("Skipping already downloaded PDF: ", pdf_link)
      }
    }
  }
  
  # Write metadata to CSV
  write.csv(metadata, metadata_file, row.names = FALSE)
}

# Run the function
# scrape_google_scholar("hillary+clinton", 20, "pdf/hillary+clinton")
