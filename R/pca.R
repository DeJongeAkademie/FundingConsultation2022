library(tidyLPA)
require("httr")
library(psych)
url <- 'https://osf.io/f76rb//?action=download'
filename <- 'dat.csv'
GET(url, write_disk(filename, overwrite = TRUE))
df <- read.csv(filename)
df <- df[c("kt_personal_senior", "kt_team", "kt_personal_ecr", "kt_thematic",
           "kt_thematic_co", "kt_small_first", "kt_small_second", "kt_award",
           "kt_first_ecr", "kt_rolling_ecr", "kt_rolling_senior")]

set.seed(1566)
fa.parallel(df)
res_pc <- principal(df, nfactors = 3)
print(res_pc)
df_plot <- data.frame(loading = as.vector(res_pc$loadings),
                      item = ordered(rep(names(df), 3), rev(levels = names(df))),
                      pc = rep(paste0("pc", 1:3), each = 11))

write.csv(df_plot, "../results/pca_loadings.csv", row.names = FALSE)
# library(ggplot2)
# ggplot(df_plot, aes(x = pc, y = item, fill= loading)) +
#   geom_tile()+
#   scale_fill_gradient2()

df_pc <- data.frame(res_pc$scores)
names(df_pc) <- c("senior", "thematic", "ecr")
write.csv(df_pc, "../data/pca.csv", row.names = FALSE)
