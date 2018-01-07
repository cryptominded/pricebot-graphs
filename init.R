if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber")

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
print(wd)

setwd(wd)

print(list.files(path=wd, pattern="*.R$"))

r <- plumb(file=paste(wd, "api.R", sep="/"))

rm(wd)

r$run(port=3333, swagger=TRUE)