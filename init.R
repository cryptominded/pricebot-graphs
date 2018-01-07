if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber", "here")

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)

print(list.files(path=wd, pattern="*.R$", recursive=T))

r <- plumb("api.R", wd)  

rm(wd)

r$run(port=as.numeric(Sys.getenv("PORT", unset=3333)), swagger=TRUE)