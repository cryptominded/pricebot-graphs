# setup ----

lapply(c("rJava", "curl", "jsonlite", "dplyr", "xts", "zoo", "ggplot2", "ggExtra", "tidyquant", "urltools"), 
       require,
       character.only=T)

if(Sys.getenv("ON_HEROKU", unset=F)) {
   .jinit()
   .jaddClassPath("/app")
   .jclassPath()
}

pricedata<-dget("pricedata.R")()


#* @apiTitle Some title
#* @apiDescription Description 

# testgraph ----
#' Get testgraph
#' @get /testgraph
#' @png()
#' @response 400 Some error...
#' @response 404 I have been looking very deeply, but I can't find what you ask me
testgraph <- function() {
   plot(1:10, (1:10)^2)
}

# graph ----
#' Get graph
#' @param fsym:character symbol
#' @param tsym:character symbol
#' @param period:character period
#' @get /graph
#' @png(width=777,height=480)
#' @response 400 Some error...
#' @response 404 I have been looking very deeply, but I can't find what you ask me
graph <- function(fsym="BTC", tsym="USD", period="1day") {
   candles<-pricedata(fsym, tsym, period)
   
   pl <- ggplot(candles, aes(x=Index, y=close)) +
      geom_barchart(aes(open=open, high=high, low=low, close=close),
                    color_up="green", color_down="red") +
      geom_point(aes(y=avg), cex=0.3) +
      labs(x="date&time",y=paste0("price (", tsym, "/1 ", fsym, ")")) +
      ggtitle(paste(fsym, tsym, period, sep=" - ")) +
      #geom_ma(aes(volume=volumefrom),
      #        ma_fun=VWMA, n=13, colour="blue", size=0.3) +
      #geom_ma(ma_fun=EMA, n=13, colour="orange", size=0.3) +
      theme_tq(base_size=25)
   
   
   print(pl)
}
