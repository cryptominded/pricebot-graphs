
lapply(dget("deps.R")$app, 
       require,
       character.only=T)

# setup wd ----
wd<-if(Sys.getenv("ON_HEROKU", unset=F)) {
   Sys.getenv("APP_DIR", unset="/app")
} else {
   "~/dev/cryptominded/pricebot-graphs"
}
setwd(wd)

rm(wd)

# start app ----
r <- plumb("api.R")

r$run(host="0.0.0.0",
      port=strtoi(Sys.getenv('PORT', "3333")), 
      swagger=TRUE)
