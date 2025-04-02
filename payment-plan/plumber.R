library(plumber)
library(aws.s3)

S3_BUCKET <- Sys.getenv("AWS_S3_BUCKET")

#* Generate or retrieve a student report for the ORExt
#* @serializer contentType list(type="application/pdf")
#* @get /report
function(firebase_id) {
  s3_path <- paste0("reports/", firebase_id, ".pdf")
  
  # Check if report exists in S3
  if (aws.s3::head_object(s3_path, bucket = S3_BUCKET)) {
    return(get_report_from_s3(s3_path))
  }
  
  # Generate and upload the report
  temp_pdf <- generate_report(firebase_id)
  upload_to_s3(temp_pdf, s3_path)
  
  return(get_report_from_s3(s3_path))
}

#* Overwrite an existing student report
#* @serializer contentType list(type="application/pdf")
#* @post /report/overwrite
function(firebase_id) {
  s3_path <- paste0("reports/", firebase_id, ".pdf")
  
  # Generate and upload the new report
  temp_pdf <- generate_report(firebase_id)
  upload_to_s3(temp_pdf, s3_path)
  
  return(get_report_from_s3(s3_path))
}

#* Trigger report generation without downloading it
#* @post /report/trigger
function(firebase_id) {
  s3_path <- paste0("reports/", firebase_id, ".pdf")
  
  temp_pdf <- generate_report(firebase_id)
  upload_to_s3(temp_pdf, s3_path)
  
  list(status = "success", message = "Report generated successfully")
}

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

# Function to retrieve a report from S3
get_report_from_s3 <- function(s3_path) {
  temp_pdf <- tempfile(fileext = ".pdf")
  save_object(
    object = s3_path,
    bucket = S3_BUCKET,
    file = temp_pdf
  )
  
  return(readBin(temp_pdf, "raw", n = file.info(temp_pdf)$size))
}
