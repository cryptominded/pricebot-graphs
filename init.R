# setup wd ----
wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)


# init libs ----
if (!require("pacman")) install.packages("pacman")
# init.R
pacman::p_load("plumber")
# api.R
pacman::p_load("curl", "jsonlite", "dplyr", "xts", "zoo", "ggplot2", "ggExtra", "tidyquant", "urltools")


# start app ----
wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)
r <- plumb(paste(wd,"api.R", sep="/"))
rm(wd)

r$run(port=3333, swagger=TRUE)
