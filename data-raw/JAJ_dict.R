#JAJ_dict_raw <- readRDS("data-raw/JAJ_dict.RDS")
#JAJ_dict_raw <- read.table("data-raw/JAJ_dict_4.csv", sep = ",", stringsAsFactors = F, header = T, fileEncoding = "utf8")
JAJ_dict_raw <- readxl::read_xlsx("data-raw/JAJ_dict.xlsx")
JAJ_dict_raw <- JAJ_dict_raw[, c("key", "EN", "DE","DE_F", "RU", "IT", "ES", "LV", "SV")]
JAJ_dict <- psychTestR::i18n_dict$new(JAJ_dict_raw, markdown = T)

get_JAJ_dict <- function(){
  return(JAJ::JAJ_dict)
}
usethis::use_data(JAJ_dict, overwrite = TRUE)
