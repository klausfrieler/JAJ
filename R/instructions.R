info_page <- function(id, style = "text-align:justify; margin-left:20%;margin-right:20%") {
  psychTestR::one_button_page(shiny::div(psychTestR::i18n(id, html = TRUE), style = style),
                              button_text = psychTestR::i18n("CONTINUE"))
}
make_instructions <- function(img_dir){
  positions <- c(3, 6, 6, 4, 4, NA, NA, NA)
  hands <- c("r", "r", "r", "l", "l", "", "", "")
  indices <- c("1a", "2a", "2b", "3a", "3b", "4a", "4b", "4c")
  ret <- c()
  for(i in 1:length(indices)){
    prompt <- psychTestR::i18n(sprintf("INSTRUCTION%s", indices[i]))
    label <- sprintf("instruction%d", i)
    if(i <= 5 ){
      ret <- c(ret, JAJ_page_hand(positions[i],
                                  hands[i],
                                  img_dir = img_dir,
                                  prompt = prompt,
                                  label = label,
                                  save_answer = FALSE,
                                  instruction_page = TRUE))
    }
    else {
      ret <- c(ret, JAJ_page_position(4,
                                      img_dir = img_dir,
                                      prompt = prompt,
                                      label = label,
                                      save_answer = FALSE,
                                      instruction_page = TRUE))
    }
  }
  messagef("Generated %d instruction pages", length(ret))
  ret
}

get_instruction <- function(img_dir){
  ins_def <- read.csv("data/JAJ_instructions_def.csv", header=T, sep = ";", stringsAsFactors = F)
  ins_def$buttons <- as.logical(ins_def$buttons)
  ins_def$arrow_pos <- as.logical(ins_def$arrow_pos)
  ins_def$text <- NULL
  #print(glimpse(ins_def))
  ret <- c()
  for(i in 1:nrow(ins_def)){
    label <- sprintf("instruction%s", ins_def$id[i])
    #printf("Label: %s", label)
    prompt <- psychTestR::i18n(sprintf("INSTRUCTION%s", ins_def$id[i]))
    label <- sprintf("instruction%s", ins_def$id[i])

    page_type <- ins_def$page_type[i]
    #printf("Buttons: %s", !ins_def$buttons[i])

    if(page_type  == "hand" ){
      #printf("Page type: %s", page_type)
      ret <- c(ret, JAJ_page_hand(position = ins_def$pos[i],
                                  ball_hand = ins_def$hands[i],
                                  img_dir = img_dir,
                                  prompt = prompt,
                                  label = label,
                                  save_answer = FALSE,
                                  instruction_page = !ins_def$buttons[i]))
    }
    else if(page_type == "position"){
      arrow_pos <- ins_def$arrow_pos[i]
      if(arrow_pos){
        arrow_pos <- ins_def$pos[i]
      }
      else{
        arrow_pos <- NULL
      }
      ret <- c(ret, JAJ_page_position(seq_length = 1,
                                      prompt = prompt,
                                      label = label,
                                      save_answer = FALSE,
                                      arrow_pos = arrow_pos,
                                      instruction_page = !ins_def$buttons[i]))
    }
    else {
      ret <- c(ret, one_button_page(body = prompt,
                                    button_text = psychTestR::i18n("CONTINUE")))
    }
  }
  messagef("get_instructions: Generated %d instruction pages", length(ret))
  ret

}

instructions <- function(img_dir) {
  c(
    psychTestR::code_block(function(state, ...) {
      psychTestR::set_local("do_intro", TRUE, state)
    }),
    get_instruction(img_dir),
    practice(img_dir, with_intro = FALSE)
    #psychTestR::loop_while(
    #  test = function(state, ...) psychTestR::get_local("do_intro", state),
    #  logic = c(
    #    practice(img_dir)
    #    #ask_repeat()
    #  ))
    ,
    psychTestR::one_button_page(psychTestR::i18n("CONTINUE_MAIN_TEST"),
                                button_text = psychTestR::i18n("CONTINUE"))
  )
}

