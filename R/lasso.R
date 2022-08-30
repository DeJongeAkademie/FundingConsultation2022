library(glmnet)
require("httr")
url <- 'https://osf.io/w48vz//?action=download'
filename <- 'imp.csv'
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
)

x <- df[xvars]

yvars <- grep("^kt_", names(df), value = TRUE)
yvars <- yvars[!grepl("^kt_(slider|funds)", yvars)]

res <- lapply(yvars, function(yvar){
  y <- df[[yvar]]
  x <- model.matrix(~., x)[, -1]
  cv.glmnet(x, y)
})

coefs <- sapply(res, function(v){
  out <- coef(v, s = "lambda.1se")
  tmp <- as.numeric(out)
  names(tmp) <- rownames(out)
  tmp
})
coefs[coefs == 0] <- NA
coefs <- data.frame(coefs)
names(coefs) <- yvars

write.csv(coefs, "../results/lasso.csv", row.names = FALSE)
