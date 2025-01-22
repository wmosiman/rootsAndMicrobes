# this file: pdfTextExtraction/testLlamaParse_Google.R
# created: 2025-01-09 WM
# goal: test out LlamaParse using files stored in google drive rather than locally

rm(list = ls())

# setup                                      ####
library(httr)
library(jsonlite)
library(googledrive)
library(beepr)

source('build.R')

# save API key for LlamaParse
# find a more secure way to do this wyatt! Extra important if/when we actually start spending money
apiKey <- LLAMA_CLOUD_API_KEY

# authenticate user for googledrive package (driveUser comes from 'build.R')
drive_auth(email = driveUser)


# write functions                            ####

# check the status of an in-progress llamaparse job
checkJobStatus <- function(id, key) {
  headers = c(
    'Accept' = 'application/json',
    'Authorization' = paste('Bearer', key)
  )
  
  res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", id), add_headers(headers))
  content <- content(res)
  return(content$status) # Adjust based on API response structure
}

# track llamaparse job progress and give a beep when complete
pollJobStatus <- function(id, key, interval = 10) {
  seconds <- 0
   repeat {
    seconds <- seconds + interval
    status <- checkJobStatus(id, key)
    cat("Current status:", status, "\n")
    
    if (status == "SUCCESS") {
      beep(1) # Play a success sound
      cat("Job completed!\nSeconds elapsed:", seconds)
      Sys.sleep(2)
      break
    } else if (status == "FAILED") {
      beep(10) # Play an error sound
      cat("Job failed\n")
      Sys.sleep(2)
      break
    }
    
    Sys.sleep(interval) # Wait before checking again
  }
}


# prep google drive link                     ####

# LlamaParse can accept a direct download link, which is the kind of link you could paste into google and it will just automatically download the file to your computer. We can get that by pasting the drive file id of the pdf in question after a certain url:
# correct format for download link = "https://drive.google.com/uc?export=download&id=FILE_ID"

# identify folder where pdf files for parsing are stored
folder <- "input" 

# get pdf file information
pdfs <- drive_ls(path = folder) # oh wow didn't even need a path. what about folders with identical names? don't love this, find more specific way mayhaps. Id for the folder probably good

# convert ids to direct download urls
ids <- as.character(pdfs$id) # get vector of all ids
urls <- paste0("https://drive.google.com/uc?export=download&id=", ids) # add on the url to make them direct dowload links


# write llamaparse instructions              ####

# guidelines instructions
gi <- 
'You are a pdf parsing service that excels at extracting text from pdfs of scientific papers. Your goal is to maximize readability of the document without sacrificing the accuracy of the output. Do not omit text unless specified in these instructions.
  
  If the last sentence on a page is incomplete, leave it as is. Do not attempt to autocomplete the sentence and do not add a period if none already exists. As with every other sentence, copy it word-for-word.
  
  The pdf may have text split into multiple columns. Ensure you maintain the proper order of text by parsing one column at a time rather than crossing over from one column to another mid-column. Take special care with lines ending in a hyphen that you do not skip to the next column and instead continue one column at a time.

  Every time you encounter a superscript or a subscript, place all text that is super or subscripted into brackets and include a "^" (superscript) or "_" (subscript) before the brackets. Be certain you always include the caret ^ or the underscore _ before the text in brackets. Omitting this leads to confusion about whether the text is subscripted or superscripted. The brackets are very important because they identify the extent of the text in the super or subscript, so these must always be included also.
- Examples:
  - 2² becomes 2^[2],
  - ml^-1 becomes ml^[-1],
  - Jane Doe^1,3 becomes Jane Doe^[1,3],
  - d_200 becomes d_[200],
  - cm^-2 becomes cm^[-2],
  - ^1 University becomes ^[1] University
  - W_dry becomes W_[dry].
- Pay particular attention to units with negative superscripts, such as ml^-1, cm^-2, and s^-3. Always format these correctly as ml^[-1], cm^[-2], and s^[-3], with the negative sign included.
- These instructions apply to the entirety of the parsed scientific paper, including any text extracted from tables and figures. Tables and figures often contain units with superscripts, and it is essential they are extracted using the specified format.
- Remember, the ^[ ] or _[ ] format must be used for every single instance of superscript or subscript text in the pdf, respectively
'

# formatting instructions
fi <- ''


# upload job to llamaparse                   ####

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
  'page_separator' = "\n\n---- Page {pageNumber} ----\n\n", # how it should separate pages
  'content_guideline_instruction' = gi # guidelines for parsing (see 'write llamaparse instructions' section)
  #,
  # 'formatting_instruction' = fi # formating specific instructions
)


# send to LlamaParse
res <- VERB("POST", url = "https://api.cloud.llamaindex.ai/api/v1/parsing/upload", body = body, add_headers(headers), encode = 'multipart')

# store job ID 
response_json <- fromJSON(content(res, as = "text", encoding = "UTF-8"))
jobId <- response_json$id



# check job status                           ####
pollJobStatus(id = jobId, key = apiKey)



# view markdown results                      ####

# LlamaParse header prereqs
headers = c(
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

# make request
res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", jobId, "/result/raw/markdown"), add_headers(headers))

# print markdown content
cat(content(res, 'text', encoding = "UTF-8"))




# # save as md file to google drive          ####
# # save content as string
# mdContent <- content(res, 'text', encoding = "UTF-8")
# 
# # create a temporary file connection with the markdown text
# tempFile <- tempfile(fileext = ".md")
# writeLines(mdContent, tempFile)
# 
# # upload the temporary file to Google Drive
# drive_upload(
#   path = 'output',            # where in google drive the file goes
#   media = tempFile,           # the file to be uploaded
#   name = "biswas2000_002.md"  # name of the file in Google Drive
# )
# 
# # clean up the temporary file
# unlink(tempFile)
# 
