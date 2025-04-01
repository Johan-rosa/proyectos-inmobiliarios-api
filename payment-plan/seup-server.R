analogsea::account()
analogsea::droplets()

install_package_secure <- function(droplet, pkg){
  analogsea::install_r_package(droplet, pkg, repo="https://cran.rstudio.com")
}

mydrop <- plumberDeploy::do_provision(example = FALSE)

# mydrop <- "download-payment-plan"

packages <- 
  c(
    "box",
    "glue", 
    "knitr", 
    "tidyr", 
    "dplyr", 
    "scales", 
    "config", 
    "pagedown", 
    "jsonlite",
    "rmarkdown",
    "kableExtra",
    "devtools"
  )

install_package_secure(mydrop, packages)

analogsea::install_github_r_package(
  droplet = mydrop, 
  package = "Kohze/fireData"
)

plumberDeploy::do_deploy_api(
  droplet = mydrop,
  path = "download-plan",
  localPath = "payment-plan",
  port = 4454,
  overwrite = TRUE
)


# To test locally ---------------------------------------------------------

#' library(plumber)
#' 
#' report <- plumb("payment-plan/plumber.R")
#' report$run(port=8005, host="0.0.0.0")
