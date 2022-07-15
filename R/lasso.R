require("httr")
url <- 'https://osf.io/f76rb//?action=download'
filename <- 'dat.csv'
GET(url, write_disk(filename, overwrite = TRUE))
data <- read.csv(filename)
