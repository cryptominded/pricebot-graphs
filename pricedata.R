function() {
   url<-"https://min-api.cryptocompare.com/data/"
   avg.fromOHCL <- dget("priceutil.R")()[["avg.fromOHCL"]]
   
   function(fsym="BTC", tsym="USD", period="1day") {
      histpars<-switch(period,
                       "1day"=c(hists="histominute", limit=1440)
      )
      data <- url %>% 
         paste0(., histpars["hists"]) %>%
         param_set(., key="fsym", value=fsym) %>%
         param_set(., key="tsym", value=tsym) %>%
         param_set(., key="limit", value=histpars["limit"]) %>%
         param_set(., key="e", value="CCCAGG") %>%
         param_set(., key="aggregate", value="3")  %>%
         curl(.) %>%
         stream_in(.)
      candles <- data$Data[[1]] %>%
         mutate(avg=avg.fromOHCL(open,close,high,low)) %>%
         dplyr::select(-time) %>%
         as.xts(cbind(.), 
                order.by=as.POSIXct(data$Data[[1]]$time, origin="1970-01-01")) %>%
         as.zoo(.)
   }
}