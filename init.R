if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber", "here")

print(here())

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
print(wd)
setwd(wd)
rm(wd)

print(here())

setwd(here())

print(list.files(path="../", pattern="api.R$", recursive=T))

print(list.files(path="../", pattern="*.R$", recursive=T))

r <- plumb("api.R")  

r$run(port=as.numeric(Sys.getenv("PORT", unset=3333)), swagger=TRUE)