# require --

lapply(c("curl", "urltools", "jsonlite", "dplyr",
         "xts", "zoo", "rJava", "tidyquant", "quantreg",
         "ggplot2", "ggExtra","grid", "cowplot", "magick"), 
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
watermark<-image_read("https://cryptominded.com/wp-content/uploads/2017/06/logo-center.png") %>%
   image_colorize(opacity=96, color="white")


cols <- c(darkblue="#424182", 
          blue="#1496FA", 
          lightblue="#6EC8F0",
          orange="#FFC801",
          darkorange="#E67814") 

#* @apiTitle CCGL - Cryptominded Crypto Graphing Library
#* @apiDescription API for cryptocurrency price and volume graphs in cryptominded style, including 
#* analytics and analysis.
#* @apiVersion socrates (470BC-399BC)  

# testgraph ----
#' Get testxyplot
#' @get /testxyplot
#' @png()
#' @response 400 Some error...
#' @response 404 I have been looking very deeply, but I can't find what you ask me
function() {
   plot(1:10, (1:10)^2)
}

# testgraph ----
#' Get testboxplot
#' @get /testboxplot
#' @png()
#' @response 400 Some error...
#' @response 404 I have been looking very deeply, but I can't find what you ask me
function() {
   print(ggplot(diamonds, aes(carat, price)) +
      geom_boxplot(aes(group = cut_width(carat, 0.25))))
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
   
   pricerange<-c(min(candles$low), max(candles$high))
   
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
      geom_line(aes(y=predict(lw1)), colour=cols['darkblue'], lwd=1) +
      geom_line(aes(y=predict(lw2)), colour=cols['orange'], lwd=0.618) +
      geom_line(aes(y=predict(lw2w)), colour=cols['orange'], lwd=0.618, lty="dashed")  +
      geom_hline(yintercept=findxpeaks(candles$avg, weights, bw="SJ"),
                 colour="darkcyan",
                 size=0.2,
                 linetype="longdash") +
      xlim(range(index(candles))) +
      ylim(pricerange) +
      theme(axis.title.x = element_blank(), 
            axis.text.x = element_blank(),
            text = element_text(size = fontscale),
            plot.margin = unit(c(0.25, 0.25, 0, 0.25), "cm")) 

   pvol <- ggplot(candles,aes(x=Index, y=volumeto)) + 
      geom_bar(stat="identity", width = nrow(candles)/8, colour=cols['darkblue']) +
      geom_smooth(span=1/24, se=F, colour=cols['orange']) +
      theme(text = element_text(size = fontscale),
            plot.margin = unit(c(0, 0.25, 0.25, 0.25), "cm")) +
      ylab(paste0("volume (", tsym ,")")) +
      xlab("date & time") +
      xlim(range(index(candles)))
   
   
   gl <- lapply(list(pprice,pvol), ggplotGrob)  
   wd <- do.call(unit.pmax, lapply(gl, "[[", 'widths'))
   gl <- lapply(gl, function(x) {
      x[['widths']] = wd
      x})
   
   #("DRAFT!", angle = 45, size = 80, alpha = .2))
   
   print(
      ggdraw() + 
         draw_image(watermark) +
         draw_plot(
            plot_grid(gl[[1]], 
                      ggplot(candles, aes(x=1,y=avg)) + 
                         ggtitle("density") +
                         geom_violin(aes(weight=weights/sum(weights)),
                                     fill=cols['orange'],
                                     bw="SJ",
                                     draw_quantiles = c(0.05, 0.2, 0.382, 0.618, 0.8, 0.95),
                                     colour="white", lwd=0.2) + 
                         geom_boxplot(aes(weight=weights/sum(weights)),
                                      width = 0.05) +
                         theme(axis.title.y = element_blank(),
                               axis.text.y = element_blank(),
                               axis.title.x = element_blank(), 
                               axis.text.x = element_blank(),
                               text = element_text(size = fontscale),
                               plot.margin = unit(c(0.25, 0.25, 0, 0.25), "cm")) +
                         ylim(pricerange),
                      gl[[2]],
                      ggplot(candles, aes(x=1, y=volumeto)) +
                         geom_violin(fill=cols['orange'], colour=cols['orange'], lwd=0.1) +
                         xlab("-") +
                         theme(axis.title.y = element_blank(),
                               axis.text.y = element_blank(),
                               text = element_text(size = fontscale),
                               plot.margin = unit(c(0, 0.25, 0.25, 0.25), "cm")), 
                      nrow = 2,
                      ncol=2,
                      rel_widths = c(0.764, 0.236),
                      rel_heights = c(0.618, 0.382))))
}
