main_test <- function(label, img_dir, num_items,
                      next_item.criterion,
                      next_item.estimator,
                      next_item.prior_dist = next_item.prior_dist,
                      next_item.prior_par = next_item.prior_par,
                      final_ability.estimator, dict = JAJ::JAJ_dict) {
  item_bank <- JAJ::JAJ_item_bank
  show_item <- psychTestR::new_timeline(c(
    psychTestR::code_block(function(state, ...) {
      psychTestR::set_local("counter", 0L, state)
      counter <- psychTestR::get_local("counter", state)
    }),
    psychTestR::loop_while(
      test = function(state, ...) {
        counter <- psychTestR::get_local("counter", state)
        n <- psychTestR::get_local("item", state)$seq_len + 1
        #messagef("Test Item : %s", paste0(psychTestR::get_local("item", state), collapse = " "))
        #messagef("Test Answer: %s", paste0(psychTestR::answer(state), collapse = " "))
        psychTestR::answer(state) <- psychTestR::answer(state)$raw
        counter < n
      },
      logic = c(
        psychTestR::code_block(function(state, ...) {
          counter <- psychTestR::get_local("counter", state)
          counter <- 1L + counter
          psychTestR::set_local("counter", counter, state)
        }),
        psychTestR::reactive_page(function(state, ...) {
          counter <- psychTestR::get_local("counter", state)
          page <- JAJ_item_wrapper(img_dir = img_dir, state = state, counter = counter)
          #messagef("Show Item : %s", paste0(psychTestR::get_local("item", state), collapse = " "))
          #messagef("Show Answer: %s", paste0(psychTestR::answer(state), collapse = " "))
          page
        })))
  ),
  dict = JAJ::JAJ_dict)

  psychTestRCAT::adapt_test(
    label = label,
    item_bank = item_bank,
    show_item = show_item,
    stopping_rule = psychTestRCAT::stopping_rule.num_items(n = num_items),
    opt = JAJ_options(next_item.criterion = next_item.criterion,
                      next_item.estimator = next_item.estimator,
                      next_item.prior_dist = next_item.prior_dist,
                      next_item.prior_par = next_item.prior_par,
                      final_ability.estimator = final_ability.estimator,
                      constrain_answers = FALSE,
                      item_bank = item_bank)
  )
}


