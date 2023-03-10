library(tidySEM)
require("httr")
library(psych)
url <- 'https://osf.io/f76rb//?action=download'
filename <- 'dat.csv'
GET(url, write_disk(filename, overwrite = TRUE))
df <- read.csv(filename)

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
           #"grant_pers_nl", "grant_pers_foreign", "grant_consortium",
           # "grant_faculty", "grant_university", "grant_foundation", "grant_private",
           #
           # "nogrant_want", "nogrant_necessary", "nogrant_early", "nogrant_education",
           # "nogrant_time", "nogrant_waste",
           #
           #
           # "body_nwo",
           # "body_university", "body_foreign", "body_award", "body_none",
           #
           # "rol_supervisor", "rol_head", "rol_dean", "rol_colleagues", "rol_nwo",
           # "rol_ocw", "rol_mentor",
           #
           "carreer_success",
           #
           "need_no",
           # "need_security",
           # "need_team", "need_freedom", "need_equipment",
           #
           "award_fair",
           # "award_lottery", "award_time", "award_bandwagon",
           #
           # "who_researcher",
           # "who_manager", "who_university", "who_committee", "who_government",
           # "who_society",
           #
           # "co_private", "co_connections", "co_irrelevant",
           #
           "time_research", "time_education",
           # "time_phds", "time_management_low",
           # "time_management_hi", "time_service", "time_admin", "time_involvement",
           # "time_patients",
           #
           # "review_info", "review_confidence", "review_informative",
           # "review_more", "review_government",
           "discipline"
           #
           # "pos5"
           c("ktversie", "kt_slider_personal_senior", "kt_slider_team",
             "kt_slider_personal_ecr", "kt_slider_thematic", "kt_slider_thematic_co",
             "kt_slider_small_first", "kt_slider_small_second", "kt_slider_award",
             "kt_slider_first_ecr", "kt_slider_rolling_ecr", "kt_slider_rolling_senior",
             "work_life", "grade", "ct", "versie", "age", "sex", "quit", "major_changes",
             "grant_no", "grant_pers_nl", "grant_pers_foreign", "grant_consortium",
             "grant_faculty", "grant_university", "grant_foundation", "grant_private",
             "nogrant_want", "nogrant_necessary", "nogrant_early", "nogrant_education",
             "nogrant_time", "nogrant_waste", "successful_applications", "body_nwo",
             "body_university", "body_foreign", "body_award", "body_none",
             "rol_supervisor", "rol_head", "rol_dean", "rol_colleagues", "rol_nwo",
             "rol_ocw", "rol_mentor", "carreer_success", "need_no", "need_security",
             "need_team", "need_freedom", "need_equipment", "award_fair",
             "award_lottery", "award_time", "award_bandwagon", "who_researcher",
             "who_manager", "who_university", "who_committee", "who_government",
             "who_society", "co_private", "co_connections", "co_irrelevant",
             "time_research", "time_education", "time_phds", "time_management_low",
             "time_management_hi", "time_service", "time_admin", "time_involvement",
             "time_patients", "review_info", "review_confidence", "review_informative",
             "review_more", "review_government", "language", "discipline",
             "pos5", "pos9", "institution", "kt_funds_personal_senior", "kt_funds_team",
             "kt_funds_personal_ecr", "kt_funds_thematic", "kt_funds_thematic_co",
             "kt_funds_small_first", "kt_funds_small_second", "kt_funds_award",
             "kt_funds_first_ecr", "kt_funds_rolling_ecr", "kt_funds_rolling_senior",
             "funds_spent", "id", "applied_grant", "got_grant", "quit_ever",
             "success_chance", "invested_time", "funds_available", "kt_personal_senior",
             "kt_team", "kt_personal_ecr", "kt_thematic", "kt_thematic_co",
             "kt_small_first", "kt_small_second", "kt_award", "kt_first_ecr",
             "kt_rolling_ecr", "kt_rolling_senior")

)
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
coefs[coefs == 0] <- NA
coefs <- data.frame(pred = rownames(coefs), coefs)
names(coefs) <- yvars

write.csv(coefs, "../results/pca_lasso.csv", row.names = FALSE)

