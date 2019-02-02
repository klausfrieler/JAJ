JAJ_dict_raw <- readRDS("data-raw/JAJ_dict.RDS")

JAJ_dict <- psychTestR::i18n_dict$new(JAJ_dict_raw)
get_JAJ_dict <- function(){
  return(JAJ::JAJ_dict)
}
usethis::use_data(JAJ_dict, overwrite = TRUE)
