source("R/JAJ.R")
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
options(shiny.error = browser)
debug_locally <- T
JAJ_study_id <- 22

register_participant <- function(){
  messagef("Register participant added")

  psychTestR::code_block(function(state, answer, ...) {
    params <- psychTestR::get_url_params(state)
    p_id <- params$p_id
    messagef("Register participant %s", p_id)
    if(!debug_locally){
      db <- GMSIData::db_connect()
      GMSDS_session_id <- GMSIData::dbNewParticipant(db,
                                                     study_id = JAJ_study_id,
                                                     participant_id = p_id)
      GMSIData::db_disconnect(db)
    }
    else{
      GMSDS_session_id <- "DUMMY SESSION"
    }
    psychTestR::set_local("GMSDS_session_id", GMSDS_session_id, state = state)
  })
}

upload_results <- function(finished = F) {
  messagef("Upload results added")
  psychTestR::code_block(function(state, answer, ...) {
    params <- psychTestR::get_url_params(state)
    p_id <- params$p_id
    GMSDS_session_id <- psychTestR::get_local("GMSDS_session_id", state = state)
    messagef("Uploading data for participant %s and session %s", p_id, GMSDS_session_id)
    value <- psychTestR::get_results(state, complete = TRUE, add_session_info = TRUE)

    if(!debug_locally){
      db <- GMSIData::db_connect()
      GMSIData::dbAddData(db = db,
                          study_id = JAJ_study_id,
                          session_id = GMSDS_session_id,
                          data = list(documentation = "BDS Production",
                                      value = value),
                          label = "BDS_results",
                          finished = finished)
      GMSIData::db_disconnect(db)
    }
  })
}

standalone_JAJ <- function(title = "Jack & Jill Memory Test",
                           num_items = 16L,
                           with_feedback = FALSE,
                           take_training = TRUE,
                           admin_password = "conifer",
                           researcher_email = "ssila010@gold.ac.uk",
                           languages = c("en", "de"),
                           dict = JAJ_dict,
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
    register_participant(),
    JAJ(num_items = num_items,
        take_training = take_training,
        feedback = feedback,
        ...),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    upload_results(F),
    psychTestR::new_timeline(
      psychTestR::final_page(shiny::p(
        psychTestR::i18n("RESULTS_SAVED"),
        psychTestR::i18n("CLOSE_BROWSER"))
      ), dict = dict)
  )

  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = languages))
}
