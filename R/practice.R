
ask_repeat <- function(prompt) {
  psychTestR::NAFC_page(
    label = "ask_repeat",
    prompt = prompt,
    choices = c("go_back", "continue"),
    labels = lapply(c("GOBACK", "CONTINUE"), psychTestR::i18n),
    save_answer = FALSE,
    arrange_vertically = FALSE,
    on_complete = function(state, answer, ...) {
      psychTestR::set_local("do_intro", identical(answer, "go_back"), state)
    }
  )
}

make_training_feedback <- function(seq_len){
  seq_len <- force(seq_len)
  #printf("make_training_feedback called with %d", seq_len)
  training_feedback <- psychTestR::reactive_page(function(state, ...) {
    #printf("Training_feedback called with %d", seq_len)
    #printf("last_correct hand: %d", psychTestR::get_global("last_correct_hand", state))
    #printf("last_correct position: %d", psychTestR::get_global("last_correct_position", state))

    correct_hand <- ifelse(psychTestR::get_global("last_correct_hand", state) == seq_len,
                           "CORRECT_HAND",
                           "INCORRECT_HAND")
    correct_pos  <- ifelse(psychTestR::get_global("last_correct_position", state),
                           "CORRECT_POS",
                           "INCORRECT_POS")
    #printf("H: %s, P: %s", correct_hand, correct_pos)

    answer_hand <- psychTestR::i18n(correct_hand)
    answer_pos <- psychTestR::i18n(correct_pos)


    #psychTestR::set_global(key = "last_correct_hand", value =  0, state = state)
    #psychTestR::set_global(key = "last_correct_position", value =  0, state = state)
    psychTestR::one_button_page(
      body = shiny::p(answer_hand, shiny::tags$br(),
                      answer_pos),
      button_text = psychTestR::i18n("CONTINUE")
    )
  }
  )

}
practice <- function(img_dir, with_intro = T) {
  if(with_intro){
    ret <- psychTestR::one_button_page(body = psychTestR::i18n("TRAINING_INTRO"),
                         button_text = psychTestR::i18n("CONTINUE"))
  }else{
    ret <- NULL
  }

  cum_seq_len <- cumsum(nchar(JAJ_training_items_pos))

  for(i in 1:2){
    label <- sprintf("training%d", i)
    training <- JAJ_item(item_id = label,
                         running_item_number = i,
                         num_items_in_test = 0, #Training!
                         img_dir = img_dir,
                         label = label,
                         JAJ_training_items_pos[i],
                         JAJ_training_items_hands[i],
                         save_answer = FALSE)
    ret <- c(ret, training)
    training_feedback <- make_training_feedback(seq_len = cum_seq_len[i])
    ret <-c(ret, training_feedback)
  }
  ret <- c(ret, psychTestR::one_button_page( body = psychTestR::i18n("CONTINUE_MAIN_TEST"),
                                             button_text = psychTestR::i18n("CONTINUE")
  ))
  #messagef("Created %d training pages", length(ret))
  ret
}
