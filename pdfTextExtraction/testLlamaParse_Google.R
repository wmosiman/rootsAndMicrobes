# this file: pdfTextExtraction/testLlamaParse_Google.R
# created: 2025-01-09 WM
# goal: see if I can get llamaparse to work in R using restAPI and read files from google drive!

rm(list = ls())

# load packages etc ####
library(httr)
library(jsonlite)

# save API key for LlamaParse
# find a more secure way to do this wyatt! Important if we actually start spending money
apiKey <- "llx-6t7yYTJFopYODUsCTBZdEIBXHuAHF60ZwfCK63XZIbLJ0XDw"


# prep google drive link ####

# when you copy a link to one of our pdfs in google drive, you get a 'view' link.
# If you give this view link to llamaparse, the link will direct Llamaparse to the google drive sign-in, which is what will get parsed. No bueno! What LlamaParse needs is a direct download link, which is the kind of link you could paste into google and it will just automatically download the file to your computer. The view link we've already copied can easily be transformed into a download link using the file ID, which is all the letters and numbers etc after 'file/d/' and before '/view?'in the link. That's what this step serves to accomplish
# IMPORTANT! make sure the links are set to "Anyone with the link - Anyone on the internet with the link can view"

# correct format for download link = "https://drive.google.com/uc?export=download&id=FILE_ID"

# read in link to paper in our drive
driveLink <- "https://drive.google.com/file/d/1e591urtRJ-1gR2fikK7x_kBZBG42g3RW/view?usp=drive_link" 

# extract file ID using regular expressions
fileId <- sub(".*?/file/d/(.*?)/view.*", "\\1", driveLink)

# build direct download link
downloadLink <- paste0("https://drive.google.com/uc?export=download&id=", fileId)

# check it out
print(downloadLink) # looks good!


# upload job to llamaparse ####

# setup LlamaParse prereqs
headers = c(
  'Content-Type' = 'multipart/form-data',
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

# supply LlamaParse with specific parameters for this job
body = list(
  'input_url' = downloadLink, # our download link
  'disable_ocr' = TRUE, # stops LlamaParse from trying to translate images to text
  'content_guideline_instruction' = # our instructions to the LLM
  'This is a scientific paper. The text may appear in columns. Text appearing in the rightmost column on one page may continue in the leftmost column on the next page. 

When you encounter a superscript or a subscript, place all text that is super or subscripted into brackets and include a "^" (superscript) or "_" (subscript) before the brackets. Be certain you always include the caret ^ or the underscore _ before the text in brackets. Omitting this leads to confusion about whether the text is subscripted or superscripted. The brackets are very important because they identify the extent of the text in the super or subscript, so these must always be included also.

Examples: 
2² becomes 2^[2], 
ml^-1 becomes ml^[-1], 
Jane Doe^1,3 becomes Jane Doe^[1,3],
d_200 becomes d_[200], 
cm^-2 becomes cm^[-2], 
^1 University becomes ^[1] University
W_dry becomes W_[dry]. 

Pay particular attention to units with negative superscripts, such as ml^-1, cm^-2, and s^-3. Always format these correctly as ml^[-1], cm^[-2], and s^[-3], with the negative sign included.
'
)

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
cat(content(res, 'text', encoding = "UTF-8")) # SUCCESS = yay!


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
mdContent <- content(res, 'text', encoding = "UTF-8")
# 
# writeLines(mdContent, "/Users/wyatt/Desktop/microbes/pdfToMd/flemerTest1.md")
# 

