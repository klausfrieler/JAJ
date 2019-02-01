item_bank <- readRDS("data_raw/JAJ_item_bank.RDS")
item_bank <- as.data.frame(item_bank)
item_bank$answer <- item_bank$pos_sequence

get_item_bank <- function(){
  return(item_bank)
}

get_item_value <- function(item_id, col){
  if(purrr::is_scalar_character(item_id)){
    return(item_bank[item_bank$item_id == item_id, col][1])
  }
  if(purrr::is_scalar_integer(item_id) || purrr::is_scalar_double(item_id)){
    return(item_bank[item_id, col][1])
  }
  stop(printf("Invalid item id %s", item_id))
}

#stopifnot(is.numeric(item_bank$answer))
