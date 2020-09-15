#' Demo JAJ
#'
#' This function launches a demo for the JAJ.
#'
#' @param num_items (Integer scalar) Number of items in the test.
#' @param take_training (Boolean scalar) Defines whether instructions and training are included.
#' Defaults to TRUE.
#' @param feedback (Function) Defines the feedback to give the participant
#' at the end of the test. Defaults to a graph-based feedback page.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' Defaults to \code{"demo"}.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' Defaults to \email{kf@omniversum.de},
#' the email address of this package's developer.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param language The language you want to run your demo in.
#' Possible languages include English (\code{"en"}), German (\code{"de"})
#' and Russion (\code{"RU"}).
#' The first language is selected by default
#' @param ... Further arguments to be passed to \code{\link{JAJ}()}.
#' @export
JAJ_demo <- function(num_items = 3L,
                     take_training = TRUE,
                     feedback = JAJ::JAJ_feedback_with_score(),
                     admin_password = "demo",
                     researcher_email = "longgold@gold.uc.ak",
                     dict = JAJ::JAJ_dict,
                     language = "en",
                     ...) {

  elts <- c(
    JAJ::JAJ(num_items = num_items,
             take_training = take_training,
             feedback = feedback,
             dict = dict,
             ...),
    psychTestR::new_timeline(
      psychTestR::final_page(psychTestR::i18n("CLOSE_BROWSER")),
      dict = dict
    )
  )

  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = "Jack & Jill Demo",
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = TRUE,
                                   languages = tolower(language)))
}
