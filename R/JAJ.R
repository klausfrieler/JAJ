library(tidyverse)
library(psychTestR)
library(psychTestRCAT)
JAJ_img_url <- "http://media.gold-msi.org/test_materials/JAJ/img"

messagef <- function(...) message(sprintf(...))
printf <- function(...) print(sprintf(...))

JAJ <- function(num_items = 16L,
                take_training = TRUE,
                label = "JAJ",
                feedback = JAJ_feedback_with_score(),
                img_dir = JAJ_img_url,
                next_item.criterion = "bOpt",
                next_item.estimator = "BM",
                next_item.prior_dist = "norm",
                next_item.prior_par = c(0, 1),
                final_ability.estimator = "WL",
                dict = JAJ::JAJ_dict) {
  stopifnot(is.scalar.character(label), is.scalar.numeric(num_items),
            is.scalar.logical(take_training),
            is.scalar.character(img_dir),
            psychTestR::is.timeline(feedback) ||
              is.list(feedback) ||
              psychTestR::is.test_element(feedback) ||
              is.null(feedback))
  img_dir <- gsub("/$", "", img_dir)
  psychTestR::new_timeline({
    c(
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
