if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber", "here")

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)

print(list.files(path=wd, pattern="*.R$", recursive=T))

r <- plumb(file=paste(wd, "api.R", sep="/"))

rm(wd)

r$run(port=3333, swagger=TRUE)