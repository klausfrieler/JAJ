JAJ_item_bank <- readRDS("data-raw/JAJ_item_bank.RDS")
JAJ_item_bank <- as.data.frame(JAJ_item_bank)
JAJ_item_bank$answer <- JAJ_item_bank$pos_sequence

get_item_bank <- function(){
  return(JAJ_item_bank)
}
get_item_value <- function(item_id, col){
  if(purrr::is_scalar_character(item_id)){
    return(JAJ_item_bank[JAJ_item_bank$item_id == item_id, col][1])
  }
  if(purrr::is_scalar_integer(item_id) || purrr::is_scalar_double(item_id)){
    return(JAJ_item_bank[item_id, col][1])
  }
  stop(printf("Invalid item id %s", item_id))
}
usethis::use_data(JAJ_item_bank, overwrite = TRUE)
