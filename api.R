# setup ----

lapply(c("rJava", "curl", "jsonlite", "dplyr", "xts", "zoo", 
         "ggplot2", "ggExtra", "cowplot", "gridExtra", "tidyquant", 
         "urltools"), 
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
   
   lw1 <- loess(as.numeric(candles$avg) ~ as.numeric(index(candles)), span=1/12)
   lw2 <- loess(as.numeric(candles$avg) ~ as.numeric(index(candles)), span=sqrt(1/12))
   lw2w <- loess(as.numeric(candles$avg) ~ as.numeric(index(candles)),
                 weights=as.numeric(candles$volumeto),
                 span=sqrt(1/12))
   
   pprice <- ggplot(candles, aes(x=Index, y=close)) +
      geom_barchart(aes(open=open, high=high, low=low, close=close),
                    color_up="#77ff77", color_down="#ff7777") +
      geom_point(aes(y=avg), cex=0.3, colour="#777777") +
      labs(x="date&time",y=paste0("price (", tsym, "/1 ", fsym, ")")) +
      ggtitle(paste(fsym, tsym, period, sep=" - ")) +
      geom_line(aes(y=predict(lw1)), colour="#33bbbb", lwd=0.618) +
      geom_line(aes(y=predict(lw2)), colour="#dd44dd", lwd=0.618) +
      geom_line(aes(y=predict(lw2w)), colour="#dd44dd", lwd=0.618, lty="dotted") +
      #geom_ma(aes(volume=volumefrom),
      #        ma_fun=VWMA, n=13, colour="blue", size=0.3) +
      #geom_ma(ma_fun=EMA, n=13, colour="orange", size=0.3) +
      xlim(range(index(candles))) +
      theme(axis.title.x = element_blank(), 
            axis.text.x = element_blank(),
            text = element_text(size = 20)) 
   
   pvol <- ggplot(candles,aes(x=Index, y=volumeto)) + 
      geom_bar(stat="identity", width = 60*24/8, colour="#cacaca") +
      geom_smooth(span=1/24, se=F, colour="#33bbbb") +
      theme(text = element_text(size = 20)) +
      ylab(paste0("volume (", tsym ,")")) +
      xlab("date & time") +
      xlim(range(index(candles)))
   
   
   gl <- lapply(list(pprice,pvol), ggplotGrob)  
   wd <- do.call(unit.pmax, lapply(gl, "[[", 'widths'))
   gl <- lapply(gl, function(x) {
      x[['widths']] = wd
      x})
   
   gl <- lapply(list(pprice,pvol), ggplotGrob)  
   wd <- do.call(unit.pmax, lapply(gl, "[[", 'widths'))
   gl <- lapply(gl, function(x) {
      x[['widths']] = wd
      x})
   
   print(plot_grid(gl[[1]], gl[[2]], align = "v", nrow = 2, rel_heights = c(0.618, 0.382)))
   
}
