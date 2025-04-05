args <- commandArgs(trailingOnly = TRUE)

library(logger)
firebase_id <- args[1]
S3_BUCKET <- Sys.getenv("AWS_S3_BUCKET")

log_appender(appender_file("report_log.txt"))
# Function to generate the report
generate_report <- function(firebase_id) {
  temp_html <- tempfile(fileext = ".html")
  temp_pdf <- tempfile(fileext = ".pdf")
  
  tryCatch({
    rmarkdown::render(
      'assets/payment_plan_template.Rmd',
      output_file = temp_html,
      params = list(firebase_id = firebase_id)
    )
    
    pagedown::chrome_print(
      temp_html, 
      temp_pdf, 
      extra_args = c("--disable-gpu", "--no-sandbox")
    )
    
    return(temp_pdf)
  }, error = function(e) {
    stop("Report generation failed: ", e$message)
  }, finally = function() {
    unlink(temp_html)
  })
}

# Function to upload a file to S3
upload_to_s3 <- function(local_file, s3_path) {
  aws.s3::put_object(
    file = local_file,
    object = s3_path,
    bucket = S3_BUCKET,
    acl = "private"
  )
}

tryCatch({
  log_info("⏳ Starting report generation for {firebase_id}")
  s3_path <- paste0("reports/", firebase_id, ".pdf")
  temp_pdf <- generate_report(firebase_id)
  upload_to_s3(temp_pdf, s3_path)
  unlink(temp_pdf)
  log_success("✅ Done generating report for {firebase_id}")
}, error = function(e) {
  log_error("❌ Failed to generate report for {firebase_id}: {e$message}")
})
