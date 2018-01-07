# setup wd ----
wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)

resource<-function(file) {
   paste(wd, file, sep="/")
}


# init libs ----
if (!require("pacman")) install.packages("pacman")
# init.R
pacman::p_load("plumber")
# api.R
pacman::p_load("curl", "jsonlite", "dplyr", "xts", "zoo", "ggplot2", "ggExtra", "tidyquant", "urltools")


# start app ----
r <- plumb(resource("api.R"))
rm(wd)

r$run(port=3333, swagger=TRUE)
