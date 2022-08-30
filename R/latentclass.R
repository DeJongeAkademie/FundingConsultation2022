library(tidyLPA)
require("httr")

url <- 'https://osf.io/f76rb//?action=download'
filename <- 'dat.csv'
GET(url, write_disk(filename, overwrite = TRUE))
df <- read.csv(filename)
df <- df[c("kt_personal_senior", "kt_team", "kt_personal_ecr", "kt_thematic",
           "kt_thematic_co", "kt_small_first", "kt_small_second", "kt_award",
           "kt_first_ecr", "kt_rolling_ecr", "kt_rolling_senior")]
names(df) <- paste0("x", 1:ncol(df))
res <- tidyLPA::estimate_profiles(df, 1:6, package = "Mplus")

tabfit <- tidyLPA::get_fit(res)
write.csv(tabfit, "../results/latentclass_fit.csv", row.names = FALSE)
