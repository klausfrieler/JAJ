#source("R/JAJ.R")
#options(shiny.error = browser)
#' Standalone JAJ
#'
#' This function launches a standalone testing session for the MPT.
#' This can be used for data collection, either in the laboratory or online.
#' @param title (Scalar character) Title to display during testing.
#' @param num_items (Scalar integer) Number of items for the test.
#' @param with_feedback (Boolean scalar) Defines whether feedback about test performance shall be given
#' at the end of the test.
#' Defaults to TRUE.
#' @param with_welcome (Logical scalar) Whether to include a welcome message. Defaults to TRUE.
#' @param take_training (Boolean scalar) Defines whether instructions and training are included.
#' Defaults to TRUE.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' @param languages (Character vector)
#' Determines the languages available to participants.
#' Possible languages include English (\code{"en"}), German (\code{"de"}), formal German (\code{"de_f"}),
#' Italian (\code{"it"}), Spanish \code{"es"}, Latvian \code{"lv"}, and Russian (\code{"ru"}).
#' The first language is selected by default
#' @param dict The psychTestR dictionary used for internationalisation. Defaults to  JAJ_dict.
#' @param validate_id An external function for validating IDs, which takes a string ID as input and returns a BOOELAN.
#' Defaults to "auto", which validates purely alphanumeric IDs with no more than 100 characters.
#' @param ... Further arguments to be passed to \code{\link{JAJ}()}.
#' @export
#'
#'
JAJ_standalone <- function(title = NULL,
                           num_items = 16L,
                           with_feedback = FALSE,
                           with_welcome = TRUE,
                           take_training = TRUE,
                           admin_password = "conifer",
                           researcher_email = "longgold@gold.uc.ak",
                           languages = c("en", "de", "de_f", "ru", "it", "es", "lv"),
                           dict = JAJ::JAJ_dict,
                           validate_id = "auto",
                           ...) {
  feedback <- NULL
  if(with_feedback) {
    feedback <- JAJ::JAJ_feedback_with_score()
    #feedback <- JAJ_feedback_with_graph()
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
        with_welcome = with_welcome,
        feedback = feedback,
        ...),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    psychTestR::new_timeline(
      psychTestR::final_page(shiny::p(
        psychTestR::i18n("RESULTS_SAVED"),
        psychTestR::i18n("CLOSE_BROWSER"))
      ), dict = dict)
  )
  if(is.null(title) || nchar(title) == 0){
    require(dplyr)
    #extract title as named vector from dictionary
    title <-
      JAJ::JAJ_dict  %>%
      as.data.frame() %>%
      dplyr::filter(key == "TESTNAME") %>%
      dplyr::select(-key) %>%
      as.list() %>%
      unlist()
    title <- gsub("&amp;", "&", title)
  }
  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = tolower(languages)))
}
