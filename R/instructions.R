info_page <- function(id, style = "text-align:justify; margin-left:20%;margin-right:20%") {
  psychTestR::one_button_page(shiny::div(psychTestR::i18n(id, html = TRUE), style = style),
                              button_text = psychTestR::i18n("CONTINUE"))
}

get_instruction <- function(img_dir){
  ins_def <- JAJ::JAJ_instructions_def
  ret <- c()
  for(i in 1:nrow(ins_def)){
    label <- sprintf("instruction%s", ins_def$id[i])
    prompt <- psychTestR::i18n(sprintf("INSTRUCTION%s", ins_def$id[i]))
    label <- sprintf("instruction%s", ins_def$id[i])

    page_type <- ins_def$page_type[i]

    if(page_type  == "hand" ){
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
      ret <- c(ret, psychTestR::one_button_page(body = prompt,
                                    button_text = psychTestR::i18n("CONTINUE")))
    }
  }
  #messagef("Generated %d instruction pages", length(ret))
  ret

}

instructions <- function(img_dir) {
  c(
    psychTestR::code_block(function(state, ...) {
      psychTestR::set_local("do_intro", TRUE, state)
    }),
    get_instruction(img_dir),
    practice(img_dir, with_intro = FALSE),
    psychTestR::one_button_page(psychTestR::i18n("CONTINUE_MAIN_TEST"),
                                button_text = psychTestR::i18n("CONTINUE"))
  )
}

