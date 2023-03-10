library(tidySEM)
require("httr")
library(psych)
library(glmnet)
url <- 'https://osf.io/f76rb//?action=download'
filename <- 'dat.csv'
GET(url, write_disk(filename, overwrite = TRUE))
df <- read.csv(filename)
#df_pc <- read.csv("../data/pca.csv", stringsAsFactors = F)
xvars <- c("language",
           #"ct",
           "versie",
           "age",
           "sex",
           "quit_ever",
           "major_changes",

           "applied_grant",
           "got_grant",
           #
           "grant_no",
           "grant_pers_nl", "grant_pers_foreign", "grant_consortium",
           "grant_faculty", "grant_university", "grant_foundation", "grant_private",

           "nogrant_want", "nogrant_necessary", "nogrant_early", "nogrant_education",
           "nogrant_time", "nogrant_waste",


           "body_nwo",
           "body_university", "body_foreign", "body_award",
           "body_none",
           #
           "rol_supervisor", "rol_head", "rol_dean", "rol_colleagues", "rol_nwo",
           "rol_ocw", "rol_mentor",

           "carreer_success",
           #
           "need_no",
           "need_security",
           "need_team", "need_freedom", "need_equipment",
           #
           "award_fair",
           "award_lottery", "award_time", "award_bandwagon",
           #
           "who_researcher",
           "who_manager", "who_university", "who_committee", "who_government",
           "who_society",

           "co_private", "co_connections", "co_irrelevant",
           #
           "time_research", "time_education",
           "time_phds", "time_management_low",
           "time_management_hi", "time_service", "time_admin", "time_involvement",
           "time_patients",

           "review_info", "review_confidence", "review_informative",
           "review_more", "review_government",
           "discipline",
           #
           "pos5")
df <- df[xvars]
df$pos5[which(df$pos5 == "Other")] <- NA
df$pos5 <- as.integer(ordered(df$pos5, levels = c("Student-PhD-Postdoc-OA = ECR",
                                                  "Assistant/associate prof/UD (temporary contract)",
                                                  "Assistant, associate (permanent)",
                                                  "Hoogleraar/professor")))

df[sapply(df, inherits, what = "character")] <- lapply(df[sapply(df, inherits, what = "character")], factor)
x <- tidySEM:::mx_dummies(df[,xvars])
x[sapply(x, inherits, what = "ordered")] <- lapply(x[sapply(x, inherits, what = "ordered")], as.integer)

res_cor <- data.frame(Variable = names(x), do.call(rbind, lapply(x, function(thisx){out = try(cor(thisx, df_pc, use = "complete.obs"))})))

write.csv(res_cor, "../results/pca_cors.csv", row.names = FALSE)

set.seed(1)
df_anal <- data.frame(df_pc, x)
yvars <- names(df_pc)
library(missRanger)
df_imp <- missRanger(df_anal)
saveRDS(df_imp, "df_imp_pca.rdata")
res <- lapply(names(df_pc), function(yvar){
  y = df_imp[[yvar]]
  x <- as.matrix(df_imp[-c(1:3)])
  cv.glmnet(x, y)
})

coefs <- sapply(res, function(v){
  out <- coef(v, s = "lambda.1se")
  tmp <- as.numeric(out)
  names(tmp) <- rownames(out)
  tmp
})
r2cv <- lapply(res, function(v){
  v$glmnet.fit$dev.ratio[which(res[[1]]$lambda == res[[1]]$lambda.1se)]
})
names(r2cv) <- yvars
yaml::write_yaml(r2cv, "../results/pca_lasso_r2cv.yml")

coefs[coefs == 0] <- NA
coefs <- data.frame(pred = rownames(coefs), coefs)
coefs <- coefs[-1, ]
names(coefs)[-1] <- yvars
lapply(2:ncol(coefs), function(i){
  write.csv(coefs[order(abs(coefs[[i]]), decreasing = T), c(1,i)], paste0("../results/pca_lasso_", names(coefs)[i], ".csv"), row.names = FALSE)
})
write.csv(coefs, "../results/pca_lasso.csv", row.names = FALSE)

