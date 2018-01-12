# packages ----

deps<-dget("deps.R")

my_pkgs<-Reduce(union, deps)

# install ----
install_if_missing = function(p) {
   if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies = NA)
  }
  else {
    cat(paste("Skipping already installed package:", p, "\n"))
  }
}
invisible(sapply(my_pkgs, install_if_missing))
