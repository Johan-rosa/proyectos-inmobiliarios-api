library(plumber)

report_dir <- "reports"
if (!dir.exists(report_dir)) dir.create(report_dir)

#* Generate or retrieve a student report for the ORExt
#* @serializer contentType list(type="application/pdf")
#* @get /report
function(firebase_id) {
  report_path <- file.path(report_dir, paste0(firebase_id, ".pdf"))
  
  if (file.exists(report_path)) {
    return(readBin(report_path, "raw", n = file.info(report_path)$size))
  }
  
  generate_report(firebase_id, report_path)
}

#* Overwrite an existing student report
#* @serializer contentType list(type="application/pdf")
#* @post /report/overwrite
function(firebase_id) {
  report_path <- file.path(report_dir, paste0(firebase_id, ".pdf"))
  generate_report(firebase_id, report_path)
}

#* Trigger report generation without downloading it
#* @post /report/trigger
function(firebase_id) {
  report_path <- file.path(report_dir, paste0(firebase_id, ".pdf"))
  
  generate_report(firebase_id, report_path)
  
  list(status = "success", message = "Report generated successfully")
}

generate_report <- function(firebase_id, output_pdf) {
  temp_html <- tempfile(fileext = ".html")
  temp_pdf <- tempfile(fileext = ".pdf")
  
  on.exit({
    unlink(temp_html)
    unlink(temp_pdf)
  }, add = TRUE)
  
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
    
    file.copy(temp_pdf, output_pdf, overwrite = TRUE)
    
    readBin(output_pdf, "raw", n = file.info(output_pdf)$size)
  }, error = function(e) {
    stop("Report generation failed: ", e$message)
  })
}
