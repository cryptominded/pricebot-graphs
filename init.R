if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber")

wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
print(wd)

setwd(wd)

list.files(wd, pattern="*.R$")

r <- plumb("api.R")

r$run(port=3333, swagger=TRUE)

rm(wd)
