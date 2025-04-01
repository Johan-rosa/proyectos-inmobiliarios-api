#* Generate a student report for the ORExt
#* @serializer contentType list(type="application/pdf")
#* @get /report
function(firebase_id) {
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
    
    readBin(temp_pdf, "raw", n = file.info(temp_pdf)$size) 
  }, error = function(e) {
    stop("Report generation failed: ", e$message)
  })
}