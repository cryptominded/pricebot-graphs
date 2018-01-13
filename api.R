# require --

lapply(c("curl", "urltools", "jsonlite", "dplyr",
         "xts", "zoo", "rJava", "tidyquant",
         "ggplot2", "ggExtra","grid", "cowplot"), 
       require,
       character.only=T)


# setup ----

if(as.logical(Sys.getenv("ON_HEROKU", unset=F))) {
   # need to set Config Vars in Heroku:
   # BUILD_PACK_VERSION=20180110-2010
   # R_VERSION=3.4.3
   .jinit(parameters=c("-Xmx128m", "-server"))
   .jaddClassPath("/app")
   .jclassPath()
}

pricedata<-dget("pricedata.R")()
findxpeaks<-dget("findxpeaks.R")


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
#' @param fontscale:int base font size
#' @get /graph
#' @png(width=777,height=480)
#' @response 400 Some error...
#' @response 404 I have been looking very deeply, but I can't find what you ask me
graph <- function(fsym="BTC", tsym="USD", period="1day", fontscale=20) {
   candles<-pricedata(toupper(fsym), toupper(tsym), tolower(period))
   fontscale<-as.numeric(fontscale)
   
   lw1 <- loess(as.numeric(candles$avg) ~ as.numeric(index(candles)), span=1/12)
   lw2 <- loess(as.numeric(candles$avg) ~ as.numeric(index(candles)), span=sqrt(1/12))
   lw2w <- loess(as.numeric(candles$avg) ~ as.numeric(index(candles)),
                 weights=as.numeric(candles$volumeto),
                 span=sqrt(1/12))
   
   weights<-tanh((candles$volumeto-median(candles$volumeto))/median(candles$volumeto))
   weights<-as.numeric(weights - min(weights))
   
   pprice <- ggplot(data=candles, aes(x=Index, y=avg)) +
      geom_point(aes(y=avg), cex=0.3, colour="#777777") +
      geom_barchart(aes(open=open, high=high, low=low, close=close),
                    color_up="#77ff77", color_down="#ff7777") +
      labs(x="date&time",y=paste0("price (", tsym, "/1 ", fsym, ")")) +
      ggtitle(paste(fsym, tsym, period, sep=" - ")) +
      geom_line(aes(y=predict(lw1)), colour="#777777", lwd=1) +
      geom_line(aes(y=predict(lw2)), colour="#33bbbb", lwd=0.618) +
      geom_line(aes(y=predict(lw2w)), colour="#33bbbb", lwd=0.618, lty="dashed")  +
      geom_hline(yintercept=findxpeaks(candles$avg, weights, bw="SJ"),
                 colour="darkcyan",
                 size=0.2,
                 linetype="longdash") +
      xlim(range(index(candles))) +
      theme(axis.title.x = element_blank(), 
            axis.text.x = element_blank(),
            text = element_text(size = fontscale),
            plot.margin = unit(c(0, 0, 0, 0), "cm")) 

   pvol <- ggplot(candles,aes(x=Index, y=volumeto)) + 
      geom_bar(stat="identity", width = nrow(candles)/8, colour="#cacaca") +
      geom_smooth(span=1/24, se=F, colour="#dd44dd") +
      theme(text = element_text(size = fontscale),
            plot.margin = unit(c(0, 0, 0, 0), "cm")) +
      ylab(paste0("volume (", tsym ,")")) +
      xlab("date & time") +
      xlim(range(index(candles)))
   
   
   gl <- lapply(list(pprice,pvol), ggplotGrob)  
   wd <- do.call(unit.pmax, lapply(gl, "[[", 'widths'))
   gl <- lapply(gl, function(x) {
      x[['widths']] = wd
      x})
   
   
   print(plot_grid(gl[[1]], 
                   ggplot(candles, aes(x=1,y=avg)) + 
                      geom_violin(aes(weight=weights/sum(weights)),
                                  fill="#33bbbb",
                                  bw="SJ",
                                  draw_quantiles = TRUE) + 
                      geom_boxplot(aes(weight=weights/sum(weights)),
                                   width = 0.2) +
                      theme_void(), 
                   gl[[2]],
                   ggplot(candles, aes(x=1, y=volumeto)) +
                      geom_violin(fill="#dd44dd") +
                      theme_void(), 
                   align = "hv", 
                   nrow = 2,
                   ncol=2,
                   rel_widths = c(0.764, 0.236),
                   rel_heights = c(0.618, 0.382)))
}
