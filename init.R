if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber", "here")

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)

print(list.files(path=wd, pattern="api.R$", recursive=T))

print(list.files(path=wd, pattern="*.R$", recursive=T))


rm(wd)


r <- plumb(paste(wd, "api.R", sep="/"))  

r$run(port=as.numeric(Sys.getenv("PORT", unset=3333)), swagger=TRUE)