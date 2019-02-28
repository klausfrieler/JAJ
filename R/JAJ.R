library(tidyverse)
library(psychTestR)
library(psychTestRCAT)
JAJ_img_url <- "http://media.gold-msi.org/test_materials/JAJ/img"

#' JAJ
#'
#' This function defines a JAJ module for incorporation into a
#' psychTestR timeline.
#' Use this function if you want to include the JAJ in a
#' battery of other tests, or if you want to add custom psychTestR
#' pages to your test timeline.
#' For demoing the JAJ, consider using \code{\link{JAJ_demo}()}.
#' For a standalone implementation of the JAJ,
#' consider using \code{\link{JAJ_standalone}()}.
#' @param num_items (Integer scalar) Number of items in the test.
#' @param take_training (Logical scalar) Whether to include the training phase.
#' @param label (Character scalar) Label to give the JAJ  results in the output file. Defaults to JAJ.
#' @param feedback (Function) Defines the feedback to give the participant
#' at the end of the test. Defaults JAJ_feedback_with_score.
#' @param next_item.criterion (Character scalar)
#' Criterion for selecting successive items in the adaptive test.
#' See the \code{criterion} argument in \code{\link[catR]{nextItem}} for possible values.
#' Defaults to \code{"bOpt"}.
#' @param next_item.estimator (Character scalar)
#' Ability estimation method used for selecting successive items in the adaptive test.
#' See the \code{method} argument in \code{\link[catR]{thetaEst}} for possible values.
#' \code{"BM"}, Bayes modal,
#' corresponds to the setting used in the original JAJ paper.
#' \code{"WL"}, weighted likelihood,
#' corresponds to the default setting used in versions <= 0.2.0 of this package.
#' @param next_item.prior_dist (Character scalar)
#' The type of prior distribution to use when calculating ability estimates
#' for item selection.
#' Ignored if \code{next_item.estimator} is not a Bayesian method.
#' Defaults to \code{"norm"} for a normal distribution.
#' See the \code{priorDist} argument in \code{\link[catR]{thetaEst}} for possible values.
#' @param next_item.prior_par (Numeric vector, length 2)
#' Parameters for the prior distribution;
#' see the \code{priorPar} argument in \code{\link[catR]{thetaEst}} for details.
#' Ignored if \code{next_item.estimator} is not a Bayesian method.
#' The dfeault is \code{c(0, 1)}.
#' @param final_ability.estimator
#' Estimation method used for the final ability estimate.
#' See the \code{method} argument in \code{\link[catR]{thetaEst}} for possible values.
#' The default is \code{"WL"}, weighted likelihood.
#' If a Bayesian method is chosen, its prior distribution will be defined
#' by the \code{next_item.prior_dist} and \code{next_item.prior_par} arguments.
#' @param dict The psychTestR dictionary used for internationalisation. Defaults to JAJ_dict
#' @export
#'
JAJ <- function(num_items = 16L,
                take_training = TRUE,
                with_welcome = TRUE,
                label = "JAJ",
                feedback = JAJ_feedback_with_score(),
                next_item.criterion = "bOpt",
                next_item.estimator = "BM",
                next_item.prior_dist = "norm",
                next_item.prior_par = c(0, 1),
                final_ability.estimator = "WL",
                dict = JAJ::JAJ_dict) {
  stopifnot(is.scalar.character(label), is.scalar.numeric(num_items),
            is.scalar.logical(take_training),
            psychTestR::is.timeline(feedback) ||
              is.list(feedback) ||
              psychTestR::is.test_element(feedback) ||
              is.null(feedback))
  img_dir <- gsub("/$", "", JAJ_img_url)
  psychTestR::new_timeline({
    c(
      if (with_welcome) psychTestR::new_timeline(
        psychTestR::one_button_page(
          body = shiny::h4(psychTestR::i18n("WELCOME")),
          button_text = psychTestR::i18n("CONTINUE")
      ), dict = dict),

      if (take_training) instructions(img_dir),
      main_test(label = label, img_dir = img_dir, num_items = num_items,
                next_item.criterion = next_item.criterion,
                next_item.estimator = next_item.estimator,
                next_item.prior_dist = next_item.prior_dist,
                next_item.prior_par = next_item.prior_par,
                final_ability.estimator = final_ability.estimator, dict = dict),
      feedback
    )},
    dict = JAJ::JAJ_dict)
}
