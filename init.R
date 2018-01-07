if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber")

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("HOME", unset="~/dev/cryptominded/pricebot-graphs")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
print(wd)
setwd(wd)
rm(wd)

r <- plumb("api.R")  

r$run(port=as.numeric(Sys.getenv("PORT", unset=3333)), swagger=TRUE)