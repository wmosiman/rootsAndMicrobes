# this file: pdfTextExtraction/testLlamaParse_Google.R
# created: 2025-01-09 WM
# goal: see if I can get llamaparse to work in R using restAPI and read files from google drive!

rm(list = ls())

# load packages etc ####
library(httr)
library(jsonlite)
library(googledrive)

source('build.R')

# save API key for LlamaParse
# find a more secure way to do this wyatt! Important if we actually start spending money
apiKey <- "llx-6t7yYTJFopYODUsCTBZdEIBXHuAHF60ZwfCK63XZIbLJ0XDw"


# prep google drive link ####

# when you copy a link to one of our pdfs in google drive, you get a 'view' link.
# If you give this view link to llamaparse, the link will direct Llamaparse to the google drive sign-in, which is what will get parsed. No bueno! What LlamaParse needs is a direct download link, which is the kind of link you could paste into google and it will just automatically download the file to your computer. The view link we've already copied can easily be transformed into a download link using the file ID, which is all the letters and numbers etc after 'file/d/' and before '/view?'in the link. That's what this step serves to accomplish
# IMPORTANT! make sure the links are set to "Anyone with the link - Anyone on the internet with the link can view"

# correct format for download link = "https://drive.google.com/uc?export=download&id=FILE_ID"

# authenticate user (driveUser comes from 'build.R')
drive_auth(email = driveUser)

# get pdf file information
pdfs <- drive_ls(path = "input") # oh wow didn't even need a path. what about folders with identical names? don't love this, find more specific way mayhaps. Id for the folder probably good

# convert ids to direct download urls
ids <- as.character(pdfs$id)
urls <- paste0("https://drive.google.com/uc?export=download&id=", ids)
print(urls)



# okay could make a function to iterate over all files for llamaparse


# upload job to llamaparse ####

# setup LlamaParse prereqs
headers = c(
  'Content-Type' = 'multipart/form-data',
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

# supply LlamaParse with specific parameters for this job
body = list(
  'input_url' = urls[1], # our download link
  'disable_ocr' = TRUE, # stops LlamaParse from trying to translate images to text
  'page_separator' = "\n\n---- Page {pageNumber} ----\n\n",
  'content_guideline_instruction' = # our instructions to the LLM, below
    
  'You are a pdf parsing service that excels at extracting text from pdfs of scientific papers and converting it to markdown format. Your goal is to maximize readability and accuracy of the output rather than copy the document word-for-word.
  ',
  'formatting_instruction' = # format specific instructions
    'Omit headers, footers, and text appearing in the far left and right margins of each page. Examples of what may appear in headers and footers that you should exclude includes but is not limited to page numbers, journal titles, edition number, publishing year, and urls.'
)

# junkyard
# - Every time you encounter a superscript or a subscript, place all text that is super or subscripted into brackets and include a "^" (superscript) or "_" (subscript) before the brackets. Be certain you always include the caret ^ or the underscore _ before the text in brackets. Omitting this leads to confusion about whether the text is subscripted or superscripted. The brackets are very important because they identify the extent of the text in the super or subscript, so these must always be included also.
# - Examples: 
#   - 2² becomes 2^[2], 
# - ml^-1 becomes ml^[-1], 
# - Jane Doe^1,3 becomes Jane Doe^[1,3],
# - d_200 becomes d_[200], 
# - cm^-2 becomes cm^[-2], 
# - ^1 University becomes ^[1] University
# - W_dry becomes W_[dry]. 
# - Pay particular attention to units with negative superscripts, such as ml^-1, cm^-2, and s^-3. Always format these correctly as ml^[-1], cm^[-2], and s^[-3], with the negative sign included.
# - These instructions apply to the entirety of the parsed scientific paper, including any text extracted from tables and figures. Tables and figures often contain units with superscripts, and it is essential they are extracted using the specified format.
# - Remember, the ^[ ] or _[ ] format must be used for every single instance of superscript or subscript text in the pdf, respectively


# send to LlamaParse
res <- VERB("POST", url = "https://api.cloud.llamaindex.ai/api/v1/parsing/upload", body = body, add_headers(headers), encode = 'multipart')

# check to see jobId and status
cat(content(res, as = 'text', encoding = "UTF-8"))

# check status code to see if it worked 
status_code(res) # (200 = good, 422 = bad)

# store job ID 
response_json <- fromJSON(content(res, as = "text", encoding = "UTF-8"))

jobId <- response_json$id



# check job status ####

# prep some prereqs for LlamaParse
headers = c(
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

# make the request
res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", jobId), add_headers(headers))

# view progress update
cat(content(res, 'text', encoding = "UTF-8")) # PENDING = be patient! | SUCCESS = yay!


# view markdown results ####

# LlamaParse header prereqs
headers = c(
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

# make request
res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", jobId, "/result/raw/markdown"), add_headers(headers))

# print markdown content
cat(content(res, 'text', encoding = "UTF-8"))




# save md file ####
# save content as string
mdContent <- content(res, 'text', encoding = "UTF-8")

# Create a temporary file connection with the markdown text
tempFile <- tempfile(fileext = ".md")
writeLines(mdContent, tempFile)

# Upload the temporary file to Google Drive
drive_upload(
  path = 'output',
  media = tempFile,
  name = "biswas2000_001.md",    # Name of the file in Google Drive
  # type = "document"       # Specify the type if needed (e.g., "document" or "application/vnd.google-apps.file")
)

# Clean up the temporary file
unlink(tempFile)

