if (!require("pacman")) install.packages("pacman")
pacman::p_load("plumber")


r <- plumb("api.R")  

r$run(port=3333)