
JAJ_exclude_items <- c("1", "23", "434")

sample_semi_replace <-function(x, size){
  ret <- c()
  while(length(ret) != size){
    ret <- c(ret, sample(x, size = size - length(ret), replace = T))
    ret <- ret[c(1, which(diff(ret) != 0) + 1)]
  }
  ret
}
generate_test_sequences <- function(seq_length,
                                    size = 25,
                                    exclude_items = JAJ_exclude_items,
                                    max_pos = 6){
  ret <- tibble()

  printf("Creating for seq length %d", seq_length)
  max_size <- max_pos^seq_length
  if(size >= max_size){
    size <- max_size - 1
  }
  for(j in 1:size){
    OK <- F
    while(!OK){
      sequence <- paste(sample_semi_replace(1:max_pos, seq_length), collapse = "")
      if(sequence %in% exclude_items){
        next
      }
      if(nrow(ret) == 0){
        OK <- T
      }
      else if(!(sequence %in% ret$pos_sequence)){
        OK <- T
      }
    }
    ball_hand <- paste(sample(c("l","r"), seq_length, replace =T), collapse="")
    #item_id <- sprintf("%s-%s", sequence, ball_hand)
    item_id <- substr("ABCDEFG", seq_length, seq_length)
    ret <- rbind(ret, tibble(item_id = item_id,
                             seq_len = seq_length,
                             pos_sequence = sequence,
                             hand_sequence = ball_hand) )
    }
  #message(ret)
  ret
}
generate_JAJ_item_bank <- function(size_per_item = 25){
  ip <- readr::read_csv("data_raw/JAJ_item_params.csv") %>% select(item_id, difficulty:inattention)
  item_bank <- map_df(1:7, generate_test_sequences, size = size_per_item) %>%
    right_join(ip) %>%
    mutate(item_id = sprintf("%s-%s", pos_sequence, hand_sequence))
  saveRDS(item_bank, "data_raw/JAJ_item_bank.RDS")
  item_bank
}