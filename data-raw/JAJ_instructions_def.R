JAJ_instructions_def  <- read.csv("data-raw/JAJ_instructions_def.csv", header=T, sep = ";", stringsAsFactors = F)
JAJ_instructions_def$buttons <- as.logical(JAJ_instructions_def$buttons)
JAJ_instructions_def$arrow_pos <- as.logical(JAJ_instructions_def$arrow_pos)
JAJ_instructions_def$text <- NULL

usethis::use_data(JAJ_instructions_def, overwrite = TRUE)
