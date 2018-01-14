# list packages ----

deps<-list(app=c("plumber"),
           api=c("curl", "urltools", "jsonlite", "dplyr",
                 "xts", "zoo", "rJava", "tidyquant", "quantreg",
                 "ggplot2", "ggExtra","grid", "cowplot", "magick"))

my_pkgs<-Reduce(union, deps)

# install new packages ----

install_if_missing = function(p) {
   if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies = NA)
  }
  else {
    cat(paste("Skipping already installed package:", p, "\n"))
  }
}
invisible(sapply(my_pkgs, install_if_missing))

rm(deps, my_pkgs, install_if_missing)
