# packages ----

pkgs<-list()
# init.R
pkgs$initR<-c("plumber")
# api.R
pkgs$apiR<-c("curl", "jsonlite", "dplyr", "xts", "zoo", "ggplot2", "ggExtra", "tidyquant", "urltools")


my_pkgs<-Reduce(union, pkgs)

# install ----
install_if_missing = function(p) {
   if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies = TRUE)
  }
  else {
    cat(paste("Skipping already installed package:", p, "\n"))
  }
}
invisible(sapply(my_pkgs, install_if_missing))