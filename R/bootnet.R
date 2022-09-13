require("httr")
library(psychonetrics)
library(bootnet)

url <- 'https://osf.io/f76rb//?action=download'
filename <- 'dat.csv'
GET(url, write_disk(filename, overwrite = TRUE))
df <- read.csv(filename)
df <- df[c("kt_personal_senior", "kt_team", "kt_personal_ecr", "kt_thematic",
           "kt_thematic_co", "kt_small_first", "kt_small_second", "kt_award",
           "kt_first_ecr", "kt_rolling_ecr", "kt_rolling_senior")]

net <- estimateNetwork(df, default = "EBICglasso", verbose = FALSE)

res_boot <- bootnet(net, nBoots = 1000, nCores = 2)

net_pruned <- bootThreshold(res_boot, alpha = 0.01, verbose = TRUE, thresholdIntercepts = FALSE)

png(filename = "../results/network_pruned.png")
plot(net_pruned, layout = "circle", label.scale = F)
dev.off()

png(filename = "../results/network_centrality.png")
centralityPlot(tmp, orderBy = "Strength")
dev.off()

