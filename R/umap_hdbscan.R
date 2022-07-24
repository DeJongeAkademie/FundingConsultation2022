library(umap)
require("httr")
library("dbscan")

url <- 'https://osf.io/w48vz//?action=download'
filename <- 'imp.csv'
GET(url, write_disk(filename, overwrite = TRUE))
df <- read.csv(filename)
df <- df[c("kt_personal_senior", "kt_team", "kt_personal_ecr", "kt_thematic",
           "kt_thematic_co", "kt_small_first", "kt_small_second", "kt_award",
           "kt_first_ecr", "kt_rolling_ecr", "kt_rolling_senior")]

custom.config = umap.defaults
custom.config$random_state = 1985
custom.config$n_neighbors <- 5
res_umap = umap(df, config = custom.config)

plot(res_umap$layout)

res_db <- hdbscan(df, minPts = 4)
res_db

png(filename = "../results/umap_hdbscan_clusters.png")
plot(res_umap$layout, col=res_db$cluster+1, pch=20)
dev.off()

