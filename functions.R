# this file: functions.R
# created: 2025-01-22 WM
# intent: store and document functions relevant to the roots/microbes project


# LlamaParse ####
  # lp.checkJobStatus ####

# checks the status of an in-progress llamaparse job
# required packages: httr, jsonlite

# arguments:
  # id = job id of job you want to check
  # key = llamaparse api key

lp.checkJobStatus <- function(id, key) {
  headers = c(
    'Accept' = 'application/json',
    'Authorization' = paste('Bearer', key)
  )
  
  res <- VERB("GET", url = paste0("https://api.cloud.llamaindex.ai/api/v1/parsing/job/", id), add_headers(headers))
  content <- content(res)
  return(content$status)
}


  # lp.pollJobStatus ####

# tracks llamaparse job progress and gives a beep when complete
# required packages: httr, jsonlite, beepr

# arguments:
  # id = job id of job you want to check
  # key = llamaparse api key
  # interval = time in seconds between checking job status (default 10)

lp.pollJobStatus <- function(id, key, interval = 10, sound = T) {
  seconds <- 0
  repeat {
    status <- lp.checkJobStatus(id, key)
    cat("Current status:", status, "| time elapsed:", seconds, "s", "\n")
    
    if (status == "SUCCESS") {
      if (sound == T) {
        beep(1) # Play a success sound
      }
      cat("Job completed!\nSeconds elapsed:", seconds) # print success message and time
      Sys.sleep(2) # 2 sec delay to allow sound to play
      break
    } else if (status == "ERROR") {
      if (sound == T) {
        beep(10) # Play an error sound
      }
      cat("Job failed\nSeconds elapsed:", second) # print failure message and time
      Sys.sleep(2) # 2 sec delay to allow sound to play
      break
    }
    
    Sys.sleep(interval) # Wait [interval] seconds before checking again
    seconds <- seconds + interval
  }
}