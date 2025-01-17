# this file: testLlamaParse.R
# created: 2025-01-09 WM
# goal: see if I can get llamaparse to work in R using restAPI!

rm(list = ls())

library(httr)
# install.packages("jsonlite")
library(jsonlite)

# API from LlamaParse
apiKey <- "llx-6t7yYTJFopYODUsCTBZdEIBXHuAHF60ZwfCK63XZIbLJ0XDw"


# prep google drive link

gl <- "https://drive.google.com/file/d/1BTvOXa5Df_QEL0bQTrqbg4MajcGtLh52/view?usp=drive_link"

# Extract file ID
fileId <- sub(".*?/file/d/(.*?)/view.*", "\\1", gl)

# Construct direct download link
gl2 <- paste0("https://drive.google.com/uc?export=download&id=", fileId)

print(gl2)

# correct format = "https://drive.google.com/uc?export=download&id=FILE_ID"



# upload job to llamaparse ####

headers = c(
  'Content-Type' = 'multipart/form-data',
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

body = list(
  'input_url' = gl2,
  'content_guideline_instruction' = 'This is a scientific paper. The text may appear in columns. Text appearing in the rightmost column on one page may continue in the leftmost column on the next page. 

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

res <- VERB("POST", url = "https://api.cloud.llamaindex.ai/api/v1/parsing/upload", body = body, add_headers(headers), encode = 'multipart')


cat(content(res, as = 'text', encoding = "UTF-8"))

status_code(res)


# save job ID
response_json <- fromJSON(content(res, as = "text", encoding = "UTF-8"))

jobId <- response_json$id



# check job status

headers = c(
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", jobId), add_headers(headers))

cat(content(res, 'text', encoding = "UTF-8"))


# get markdown results:

headers = c(
  'Accept' = 'application/json',
  'Authorization' = paste('Bearer', apiKey)
)

res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", jobId, "/result/raw/markdown"), add_headers(headers))

cat(content(res, 'text', encoding = "UTF-8"))




# save md file
mdContent <- content(res, 'text', encoding = "UTF-8")
# 
# writeLines(mdContent, "/Users/wyatt/Desktop/microbes/pdfToMd/flemerTest1.md")
# 

