#source("R/JAJ.R")
#' Standalone JAJ
#'
#' This function launches a standalone testing session for the MPT.
#' This can be used for data collection, either in the laboratory or online.
#' @param title (Scalar character) Title to display during testing.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' @param languages (Character vector)
#' Determines the languages available to participants.
#' Possible languages include English (\code{"EN"}),
#' and German (\code{"DE"}).
#' The first language is selected by default
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param ... Further arguments to be passed to \code{\link{JAJ}()}.
#' @export
#'
#'
#library(tidyverse)
options(shiny.error = browser)

#I cannot put the true Russian title here into the source, because of some (yet another mysterious) encoding issue
#has to be done during calling standalone_JAJ, which works.


standalone_JAJ <- function(title = NULL,
                           num_items = 16L,
                           with_feedback = FALSE,
                           take_training = TRUE,
                           admin_password = "conifer",
                           researcher_email = "kf@omniversum.de",
                           languages = c("EN", "DE", "RU"),
                           dict = JAJ::JAJ_dict,
                           validate_id = "auto",
                           ...) {
  feedback <- NULL
  if(with_feedback) {
    feedback <- JAJ_feedback_with_score()
  }
  elts <- c(
    psychTestR::new_timeline(
      psychTestR::get_p_id(prompt = psychTestR::i18n("ENTER_ID"),
                           button_text = psychTestR::i18n("CONTINUE"),
                           validate = validate_id),
      dict = dict
    ),
    JAJ(num_items = num_items,
        take_training = take_training,
        feedback = feedback,
        ...),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    psychTestR::new_timeline(
      psychTestR::final_page(shiny::p(
        psychTestR::i18n("RESULTS_SAVED"),
        psychTestR::i18n("CLOSE_BROWSER"))
      ), dict = dict)
  )
  if(is.null(title)){
    title <-default_title <- c("RU" = "",
                               "EN" = "Jack & Jill Memory Test",
                               "DE" = "Johann und Johanna Gedächtnistest")
    title[["RU"]] <- JAJ::JAJ_dict  %>% as.data.frame() %>% filter(key == "TITLE") %>% pull(RU)
  }
  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = languages))
}
