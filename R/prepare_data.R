# In this file, write the R-code necessary to load your original data file
# (e.g., an SPSS, Excel, or SAS-file), and convert it to a data.frame. Then,
# use the function open_data(your_data_frame) or closed_data(your_data_frame)
# to store the data.

library(worcs)
library(openxlsx)
library(haven)

# Read STATA
dat <- readstata13::read.dta13("../data/Data_DJA.dta", nonint.factors = TRUE, convert.factors = TRUE)

# Make nonsense ID number
set.seed(1985)
dat$id <- sample.int(nrow(dat), nrow(dat), replace = FALSE)
dat <- dat[order(dat$id), ]

# Remove empty variables
dat[c("session_id", "id_panel", "client_id", #"started_at",
      "completed_at", "completion_time", "consultation_active", "is_panel_participant", "panel_id", "panel_source", "b1812_consent__created_at", "b1812_consent__consent_given",
      "created_at", "b2215_questions__created_at", "b2216_questions__created_at", "b2212_questions__created_at",
      "start")] <- NULL
dates <- data.frame(dat$id, date = as.Date(dat$started_at))
dat[["started_at"]] <- NULL

# Rename ------------------------------------------------------------------

# namz <- openxlsx::read.xlsx("../data/Variabelen_DJA_shortlabels.xlsx")
# write.csv(namz, "../data/Variabelen_DJA_shortlabels.csv", row.names = F)
namz <- read.csv("../data/Variabelen_DJA_shortlabels.csv")
namz <- namz[namz$Variabele.naam %in% names(dat),]
names(dat)[match(namz$Variabele.naam, names(dat))] <- namz$short


# Correctly label factors------------------------------------------------------
dat$language <- factor(dat$language)
dat$work_life <- factor(dat$work_life)

# Remove test cases -------------------------------------------------------

# Find test entries
charvars <- sapply(dat, inherits, what = "character")
df_char <- dat[, charvars]
tmp = trimws(tolower(unlist(df_char))) == "test" | grepl("(test 123|Test Koen)", unlist(df_char), ignore.case = T)
istest <- matrix(tmp, ncol = ncol(df_char))
test_ids <- dat$id[apply(istest, 1, function(i)isTRUE(any(i)))]
dat <- dat[!apply(istest, 1, function(i)isTRUE(any(i))), ]


# Store character data ----------------------------------------------------
write.csv(dat[, c("id", names(dat)[charvars])], "../data/data_character_clean.csv", row.names = FALSE)

dat[names(dat)[charvars]] <- NULL


# Clean variable classes --------------------------------------------------
dat_norecode <- dat
#levels(dat$language)[levels(dat$language) == ""] <- NA

dat$applied_grant <- NA
dat$applied_grant[dat$successful_applications == "Ik heb nog nooit een onderzoeksaanvraag gedaan"] <- 0
dat$applied_grant[dat$successful_applications %in% c("Ja, minder dan 10% van mijn aanvragen", "Ja, 10-20% van mijn aanvragen",
                                           "Ja, 20-30% van mijn aanvragen", "Ja, meer dan 30% van mijn aanvragen",
                                           "Nee")] <- 1
dat$got_grant <- NA
dat$got_grant[dat$successful_applications == "Nee"] <- 0
dat$got_grant[dat$successful_applications %in% c("Ja, minder dan 10% van mijn aanvragen", "Ja, 10-20% van mijn aanvragen",
                                                     "Ja, 20-30% van mijn aanvragen", "Ja, meer dan 30% van mijn aanvragen")] <- 1

levels(dat$successful_applications)[levels(dat$successful_applications) == "Ik heb nog nooit een onderzoeksaanvraag gedaan"] <- NA

dat$successful_applications <- ordered(dat$successful_applications, levels = c("Nee", "Ja, minder dan 10% van mijn aanvragen", "Ja, 10-20% van mijn aanvragen", "Ja, 20-30% van mijn aanvragen", "Ja, meer dan 30% van mijn aanvragen"))


# Try to reconstruct missing language -------------------------------------

# is_english <- dat$work_life %in% c("I don't want to say", "No", "Yes, to a small degree", "Yes, to a big degree")
# is_dutch <- dat$work_life %in% c("Wil / kan ik niet zeggen", "Nee", "Ja, in kleine mate ", "Ja, in grote mate ")
#
# table(dat$language, is_english, useNA= "always")

levels(dat$work_life)[levels(dat$work_life) %in% c("Wil / kan ik niet zeggen", "I don't want to say","")] <- NA
dat$work_life <- ordered(dat$work_life, levels = c("Nee", "No",
                                                   "Yes, to a small degree", "Ja, in kleine mate ",
                                                   "Ja, in grote mate ", "Yes, to a big degree"))
dat$work_life <- ceiling(as.integer(dat$work_life)/2)

dat$versie <- as.integer(as.character(dat$versie))

dat$age <- as.integer(dat$age)

levels(dat$sex)[levels(dat$sex)=="Geen van beiden/zeg ik niet"] <- NA

levels(dat$carreer_success)[levels(dat$sex) %in% c("Weet niet", "Wil ik niet zeggen")] <- NA
dat$carreer_success <- as.integer(ordered(dat$carreer_success, levels = c("Nee", "Ja")))


# Label dummies correctly
tmp <- dat[, grep("(^grant|nogrant|body|need)_", names(dat))]
tmp[] <- lapply(tmp, as.integer)
tmp[is.na(tmp)] <- 0
dat[, grep("(^grant|nogrant|body|need)_", names(dat))] <- tmp

levels(dat$major_changes)[levels(dat$major_changes)=="Weet niet/wil niet zeggen"] <- NA
dat$major_changes <- ordered(dat$major_changes, levels = c("Geen wijzigingen", "Kleine wijzigingen", "Grote wijzigingen"))
dat$major_changes <- as.integer(dat$major_changes)

levels(dat$quit)[levels(dat$quit)=="Ik werk niet in de wetenschap"] <- NA
dat$quit <- ordered(dat$quit, levels = c("Nee", "Ja, in het verleden", "Ja, ik overweeg de wetenschap te verlaten"))
dat$quit <- as.integer(dat$quit)
dat$quit_ever <- as.integer(!sapply(dat$quit == 1, isTRUE))

dat[grep("^who_", names(dat))] <- lapply(dat[grep("^who_", names(dat))], function(x){
  as.integer(ordered(x, levels = c("Geen invloed", "Neutraal", "Wat invloed", "Veel invloed")))
})

dat[grep("^award_", names(dat))] <- lapply(dat[grep("^award_", names(dat))], function(x){
  as.integer(ordered(x, levels = c("Helemaal niet mee eens", "Niet mee eens", "Neutraal", "Mee eens",
                                   "Helemaal mee eens")))
})

dat[grep("^rol_", names(dat))] <- lapply(dat[grep("^rol_", names(dat))], function(x){
  as.integer(ordered(x, levels = c("Geen rol", "Een kleine rol", "Een redelijk grote rol", "Een zeer grote rol")))
})

dat[grep("^review_", names(dat))] <- lapply(dat[grep("^review_", names(dat))], function(x){
  levels(x)[levels(x)=="Weet ik niet"] <- NA
  x <- ordered(x, levels = c("Helemaal niet mee eens", "Niet mee eens", "Neutraal", "Mee eens",
                             "Helemaal mee eens"))
  as.integer(x)
})

dat[grep("^co_", names(dat))] <- lapply(dat[grep("^co_", names(dat))], function(x){
  as.integer(ordered(x, levels = c("Helemaal niet mee eens", "Niet mee eens", "Neutraal", "Mee eens",
                                   "Helemaal mee eens")
  ))
})

dat[grep("^time_", names(dat))] <- lapply(dat[grep("^time_", names(dat))], function(x){
  as.integer(ordered(x, levels = c("Geen tijd", "Bijna geen tijd", "Veel tijd", "Bijna al mijn tijd"
  )))
})
# type <- sapply(dat, function(x){class(x)[1]})
# lapply(dat[type == "factor"], table)

dat$institution[dat$institution == 'Delft University of Technology'] <- 'Technische Universiteit Delft'
dat$institution[dat$institution == 'Eindhoven University of Technology'] <- 'Technische Universiteit Eindhoven'
dat$institution[dat$institution == 'Anders, niet in de lijst'] <- 'Overig'
dat$institution <- droplevels(dat$institution)


# Make YAML with value labels ---------------------------------------------

# type_orig <- sapply(dat[names(dat_norecode)], function(x){class(x)[1]})
# type_new <- sapply(dat_norecode, function(x){class(x)[1]})
# dat_norecode <- dat_norecode[names(dat_norecode)[!type_orig == type_new]]
#
# out <- lapply(names(dat_norecode), function(nam){
#   i = dat_norecode[[nam]]
#   whatclass <- class(i)[1]
#   tmp <- table(i, dat[[nam]])
#   tmp <- as.data.frame.table(tmp)
#   tmp <- tmp[!tmp$Freq == 0, ]
#   res <- as.list(as.character(tmp$i))
#   names(res) <- tmp$Var2
#   c(list(class = whatclass), res)
# })
# names(out) <- names(dat_norecode)
# yaml::write_yaml(out, file = "value_labels.yml")

#
# names(dat_norecode) <- paste0("orig_", names(dat_norecode))
# dat <- cbind(dat, dat_norecode)


# Reorder property values -------------------------------------------------

orderz <- lapply(list.files("../syntax", pattern = "Hernoemen", full.names = TRUE), function(f){
  f <- readLines(f)
  f <- f[grepl(" kt\\d{1,2}$", f)]
  as.integer(gsub("^.+?_p(\\d{+})_.+?$", "\\1", f)[order(as.integer(gsub("^.+?(\\d{1,2})$", "\\1", f)))])
})

flz <- lapply(list.files("../data", pattern = "Property val", full.names = TRUE), function(f){
  read.csv(f, sep = ";")
})

for(n in 1:3){
  flz[[n]]$qnum <- as.integer(gsub("^(\\d{+})-.*$", "\\1", flz[[n]][[2]]))
  flz[[n]]$qnum <- match(flz[[n]]$qnum, orderz[[n]])
  flz[[n]] <- flz[[n]][order(flz[[n]]$version, flz[[n]]$qnum), ]
}

# Chiel's code ------------------------------------------------------------

# Load files with study characteristics
# 550 M is the total budget
df1 = flz[[1]]
# df1['1708-gemiddelde-succeskans-per-voorstel'].values.reshape(9, 11)
# 400 M is the total budget
df2 = flz[[2]]
# df2['1836-gemiddelde-succeskans-per-voorstel'].values.reshape(9, 11)
# 900 M is the total budget
df3 = flz[[3]]
# df3['1844-gemiddelde-succeskans-per-voorstel'].values.reshape(9, 11)

# First, we read the actual maximum budget values of which the kt values are a fraction from the table.
df1_abs_vals = df1$X1481.maximum.kosten.van.deze.keuze[1:11]
df2_abs_vals = df2$X1830.jaarlijkse.kosten.van.deze.keuze[1:11]
df3_abs_vals = df3$X1838.jaarlijkse.kosten.van.deze.keuze[1:11]

# Reconstruct conditions
success_chance <- c("low", "medium", "high")[(floor((dat$ktversie-1)/3)+1)]
success_chance[dat$versie == 1 & success_chance == "medium"] <- "low"
invested_time = c("short", "moderate", "long")[(dat$ktversie %% 3)+1]

dat$success_chance <- success_chance
dat$invested_time <- invested_time
dat$funds_available <- c(550, 400, 900)[dat$versie]
# The code below was for standardizing the slider scores; now we use the absolute
# values in Euro instead
# Second, we multiply the kt values with the values above and normalize with the total
# to make each kt a fraction of the total money spend.
# df_kt = as.matrix(dat[grep("^kt_", names(dat))])
#
# divby <- matrix(c(
#   df1_abs_vals / 550,
#   df2_abs_vals / 400,
#   df3_abs_vals / 900), byrow = TRUE, nrow = 3)
#
# divby <- divby[dat$versie, ]
#
# df_kt <- df_kt * divby
df_kt = as.matrix(dat[grep("^kt_funds_", names(dat))])
df_kt <- df_kt / as.numeric(dat$funds_available)
colnames(df_kt) <- gsub("_funds", "", colnames(df_kt))
dat <- cbind(dat, df_kt)

# tmp = rowSums(df_kt)
# table(tmp > 1)
# exceeds <- dat[which(tmp>1), ]
# dates <- dates$date[dates$dat.id %in% dat$id]
# median(dates[tmp <= 1], na.rm = T)
# median(dates[tmp > 1], na.rm = T)

# openxlsx::write.xlsx(dat, gsub("[ :]", "_", paste0("data_", Sys.time(), ".xlsx")))

closed_data(dat, synthetic = FALSE)


# Impute data -------------------------------------------------------------

ismiss <- is.na(dat)
bycol <- colSums(ismiss)/nrow(dat)
byrow <- rowSums(ismiss)/sum(bycol > 0)
hist(byrow)
table(byrow > .8)

df_imp <- dat[byrow < .8, ]
library(missRanger)
set.seed(1985)
imp <- missRanger(df_imp)
closed_data(imp, synthetic = FALSE)
