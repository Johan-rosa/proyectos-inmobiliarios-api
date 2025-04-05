args <- commandArgs(trailingOnly = TRUE)
firebase_id <- args[1]

library(logger)
log_appender(appender_file("report_log.txt"))

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
