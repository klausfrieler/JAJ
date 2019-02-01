JAJ_dict_raw <- readRDS("./data_raw/JAJ_dict.RDS")
#names(JAJ_dict_raw) <- tolower(names(JAJ_dict_raw))
#tmp_dict <- bind_rows(
#  tibble(key = "DESCRIBE_ID", en = "Participant IDs must start with UK or AUS followed by an underscore and a number, e.g., UK_01 or AUS_02", de = "Teilnehmer ID beginnen mit UK oder AUS, gefolgt von einer einer Zahl, z.B. UK_01 oder AUS_02."),
#  tibble(key = "ENTER_ID", en = "Please enter your particpant ID.", de = "Bitte gebe deine Teilnehmer-ID ein."),
#  tibble(key = "EXAMPLE_ID", en = "e.g., 123456", de = "Z.B. 123456"),
#  tibble(key = "RESULTS_SAVED", en = "Your results have been saved.", de = "Deine Ergebnisse wurden gespeichert."),
#  tibble(key = "CLOSE_BROWSER", en = "You may now close the browser window.", de = "Du kannst das Browserfenster jetzt schließen.")
#    tibble(key = "COMPLETED", en = "You completed the Jack & Jill memory test!\\\\You answered {{num_correct}} position sequences out of {{num_question}} correctly.", de = "Du hast den Johann & Johanna Gedächtnistest abgeschlossen.\\\\Von {{num_question}} Positionsfolgen waren {{num_correct}} richtig.")
#)

JAJ_dict <- psychTestR::i18n_dict$new(JAJ_dict_raw)
#devtools::use_data(mpt_dict, overwrite = TRUE)
