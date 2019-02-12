###### J & J Stuff #####
library(tidyverse)
get_item_value <- function(item_id, col){
  if(purrr::is_scalar_character(item_id)){
    return(JAJ::JAJ_item_bank[JAJ::JAJ_item_bank$item_id == item_id, col][1])
  }
  if(purrr::is_scalar_integer(item_id) || purrr::is_scalar_double(item_id)){
    return(JAJ::JAJ_item_bank[item_id, col][1])
  }
  stop(printf("Invalid item id %s", item_id))
}

JAJ_training_items_pos <- c("1", "23", "434")
JAJ_training_items_hands <- c("r", "lr", "rlr")
JAJ_exclude_items <- c(JAJ_training_items_pos)
custom_NAFC_page <- function(label,
                             prompt,
                             choices,
                             save_answer = TRUE,
                             get_answer = NULL,
                             arrange_vertically = length(choices) > 2L,
                             hide_response_ui = FALSE,
                             response_ui_id = "response_ui",
                             on_complete = NULL,
                             admin_ui = NULL) {
  stopifnot(is.scalar.character(label),
            is.character(choices), length(choices) > 0L,
            is.scalar.logical(arrange_vertically))
  ui <- shiny::div(
    tagify(prompt),
    psychTestR::make_ui_NAFC(choices,
                 hide = hide_response_ui,
                 arrange_vertically = arrange_vertically,
                 id = response_ui_id))
  if(is.null(get_answer)){
    get_answer <- function(input, ...) input$last_btn_pressed
  }
  validate <- function(answer, ...) !is.null(answer)
  psychTestR::page(ui = ui, label = label,  get_answer = get_answer, save_answer = save_answer,
       validate = validate, on_complete = on_complete, final = FALSE,
       admin_ui = admin_ui)
}

scale_coords <- function(coords, scale_factor = 1){
  if(length(coords) > 1){
    tmp <- sapply(coords, scale_coords, scale_factor)
    names(tmp) <- NULL
    return(tmp)
  }
  paste(
    round(as.integer(unlist(strsplit(coords, ",")))*scale_factor),
    collapse=",")
}
dot_positions <- tibble::tibble(pos = 1:6,
                        coords = c("100,200,160,260",
                                   "266,68,322,128",
                                   "431,195,500,255",
                                   "438,344,500,410",
                                   "270,480,330,540",
                                   "100,350,160,410")
)
generate_area_entry <- function(position, scale_factor = 1){
  if(length(position) > 1){
    return(lapply(position, generate_area_entry, scale_factor))
  }
  dot_positions <- dot_positions %>% dplyr::mutate(coords = scale_coords(coords, scale_factor))
  #print(scale_coords(dot_positions$coords, scale_factor))
  click_handler <- sprintf("register_click(%d)", position)
  coords <- dot_positions %>% dplyr::filter(pos == position) %>% dplyr::pull(coords)

  shiny::tags$area(
    shape = "rect",
    href = "#",
    coords = coords[1],
    alt = position,
    title = position,
    onclick = click_handler)

}

click_script <- "
var clicks = []
var max_length = %d
document.getElementById('pos_seq').style.visibility = 'hidden'
function register_click(position){
clicks.push(position)
var orig_src = document.getElementById('click_area').src
var src_split = orig_src.split('/')
src_split[src_split.length-1] = 'spot_hover_' + position + '.jpg'
var highlight_img = src_split.slice(0, src_split.length).join('/')
document.getElementById('click_area').src = highlight_img
Shiny.setInputValue('pos_seq', clicks.join(''));
//document.getElementById('pos_seq').value = clicks.join('')
if(clicks.length == max_length){
Shiny.onInputChange('next_page', performance.now())
}
}
"

get_answer_hand <- function(correct_answer, item_id){
  #printf("Generated get_answer_hand function with correct answer '%s'", correct_answer)
  item_id <- force(item_id)
  correct_answer <- force(correct_answer)
  function(input, ...) {
    #print("get_answer_hand called")
    #printf("%s %s %s", item_id, input$last_btn_pressed, correct_answer)
    tibble::tibble(type = "hand",
           item_id = item_id,
           raw = input$last_btn_pressed,
           correct_answer = correct_answer,
           correct =  input$last_btn_pressed == correct_answer)
  }
}

get_answer_positions <- function(correct_answer, item_id){
  #printf("Generated get_answer_positions function with correct answer '%s'", correct_answer)
  item_id <- force(item_id)
  correct_answer <- force(correct_answer)
  function(input, ...) {
    #print("get_answer_positions called")
    #printf("POS: %s CA: %s", input$pos_seq, correct_answer)
    ret <- tibble::tibble(type = "position",
           item_id = item_id,
           raw = input$pos_seq,
           correct_answer = correct_answer,
           correct =  input$pos_seq == correct_answer)
    ret
  }
}
JAJ_page_position <- function(seq_length,
                              prompt = "",
                              label = "",
                              save_answer = T,
                              arrow_pos = NULL,
                              get_answer = NULL,
                              on_complete = NULL,
                              instruction_page = FALSE){
  jill <- shiny::img(src = sprintf("%s/%s", JAJ_img_url, "jill.jpg"), height="300")
  pos_img <- "empty.jpg"
  if(!is.null(arrow_pos) & is.numeric(arrow_pos)){
    pos_img <- sprintf("arrow_%d.jpg", arrow_pos)
    #printf("Pos img: %s", pos_img)
  }
  click_area <- shiny::img(src = sprintf("%s/%s",
                                         JAJ_img_url, pos_img),
                           height = "300",
                           usemap = "#dot_positions",
                           id = "click_area")
  map <- shiny::tags$map(name = "dot_positions", generate_area_entry(1:6, scale_factor = .5))
  img <- shiny::div(shiny::p(prompt), jill, click_area)
  #text_inputs <- lapply(1:seq_length, generate_pos_input)
  #text_input <-   shiny::tags$input(id = "pos_seq", name = "pos_seq", size = seq_length, style= "visibility:visible")
  text_input <-   shiny::textInput("pos_seq", label="", value="", width = 100)
  pos_inputs <- shiny::div(id = "position_inputs", style="margin-left:50%", text_input)
  script <- shiny::tags$script(shiny::HTML(sprintf(click_script, seq_length)))
  ui <- shiny::div(id = "position_clicker", script, img, map, pos_inputs)
  if(instruction_page){
    psychTestR::one_button_page(ui, button_text = psychTestR::i18n("CONTINUE"))
  }
  else{
    psychTestR::page(ui = ui,
                     label = label,
                     save_answer = save_answer,
                     get_answer = get_answer,
                     on_complete = on_complete)

  }
}
JAJ_page_hand <- function(position,
                          ball_hand,
                          img_dir,
                          prompt = "",
                          label = "",
                          save_answer = T,
                          get_answer = NULL,
                          on_complete = NULL,
                          instruction_page = FALSE){
  jill <- shiny::img(src = sprintf("%s/%s", img_dir, "jill.jpg"), height="300")
  hand_pos <- c("l" = "left", "r" = "right")

  jack_img_src <- sprintf("jack_%s_%s.jpg", hand_pos[ball_hand], position)
  jack <- shiny::img(src = sprintf("%s/%s", img_dir, jack_img_src), height="300")
  text_input <-   shiny::textInput("pos_seq", label="", value="", width = 100)
  pos_inputs <- shiny::div(id = "position_inputs", style="margin-left:50%;visibility:hidden", text_input)

  page_prompt <- shiny::div(shiny::p(prompt), jill, jack, pos_inputs)
  choices <- c("r", "l")
  names(choices) <- c(psychTestR::i18n("SAME"),
                      psychTestR::i18n("DIFFERENT"))
  if(!instruction_page){
    custom_NAFC_page(label,
                     page_prompt,
                     choices = choices,
                     save_answer = save_answer,
                     get_answer = get_answer,
                     on_complete = on_complete)
  }
  else{
    #print("Instruction page hand")
    psychTestR::one_button_page(page_prompt, button_text = psychTestR::i18n("CONTINUE"))
  }
}


JAJ_item <- function(item_id,
                     running_item_number,
                     num_items_in_test,
                     label,
                     pos_seq,
                     hand_seq,
                     img_dir,
                     save_answer = TRUE){
  pos_seq <- force(unlist(strsplit(pos_seq, "")))
  hand_seq <- force(unlist(strsplit(hand_seq, "")))
  stopifnot(length(pos_seq) == length(hand_seq))
  label_hand <- force(sprintf("%s_hand", label))
  label_position <- force(sprintf("%s_position", label))
  save_answer <- force(save_answer)
  on_complete_hand <-    function(state, answer, ...){
    hand_stack <- psychTestR::get_global(key = "last_correct_hand", state = state)
    if(is.null(hand_stack)){
      value <- as.integer(answer$correct[1])
    }
    else{
      value <- hand_stack + as.integer(answer$correct[1])
    }
    psychTestR::set_global(key = "last_correct_hand",
                           value =  value,
                           state = state)

  }
  on_complete_position <-    function(state, answer, ...){
    psychTestR::set_global(key = "last_correct_position",
                           value = answer$correct[1],
                           state = state)

  }

  ret <- list()
  if(num_items_in_test > 0){
    progress <- psychTestR::i18n("PROGRESS_TEXT", sub = list(
      "num_question" = running_item_number,
      "test_length" = num_items_in_test) )
  }
  else {
    progress <- psychTestR::i18n("SAMPLE_HEADER", sub = list("num_example" = item_id) )

  }
  prompt <- shiny::div(
    shiny::h4(progress),
    psychTestR::i18n("PROMPT_HAND"))

  for(i in seq_along(pos_seq)){
    get_answer <- get_answer_hand(hand_seq[i], item_id)
    ret <- c(ret, JAJ_page_hand(position = pos_seq[i],
                                ball_hand = hand_seq[i],
                                img_dir = img_dir,
                                prompt = prompt,
                                label = label_hand,
                                save_answer = save_answer,
                                get_answer = get_answer,
                                on_complete = on_complete_hand))
    #messagef("Adding hand pages #%d for pos seq: %s, new length: %d ", i, paste0(pos_seq, " "), length(ret))
  }

  prompt <- psychTestR::i18n("PROMPT_POSITION")
  get_answer <- get_answer_positions(paste(pos_seq, collapse=""), item_id)

  ret <- c(ret, JAJ_page_position(seq_length = length(pos_seq),
                                  prompt = prompt,
                                  label = label_position,
                                  save_answer = save_answer,
                                  get_answer = get_answer,
                                  on_complete = on_complete_position))
  #messagef("Length after page position  %d", length(ret))
  ret
}

JAJ_item_wrapper <- function(img_dir, state, counter){
  item <- psychTestR::get_local("item", state)
  #printf("JAJ_item_wrapper item %s", item$item_id)
  item_id <- item$item_id[1]
  running_item_number <- psychTestRCAT::get_item_number(item)
  num_items_in_test <- psychTestRCAT::get_num_items_in_test(item)
  seq_len   <- get_item_value(item$item_id, "seq_len")
  pos_seq   <- get_item_value(item$item_id, "pos_sequence")
  hand_seq  <- get_item_value(item$item_id, "hand_sequence")
  progress  <- psychTestR::i18n("PROGRESS_TEXT", sub = list(
    "num_question" = running_item_number,
    "test_length" = num_items_in_test) )
  prompt <- shiny::div(
    shiny::h4(progress),
    psychTestR::i18n("PROMPT_HAND"))
  label <- sprintf("q%d", running_item_number)
  #messagef("Generating: %s for item_id %s, max_items: %s, pos_seq: %s, hand_seq: %s", label, item_id, num_items_in_test, pos_seq, hand_seq)
  pages <- JAJ_item(item_id = item_id,
                    running_item_number = running_item_number,
                    num_items_in_test = num_items_in_test,
                    label = label,
                    pos_seq = pos_seq,
                    hand_seq = hand_seq,
                    img_dir = img_dir,
                    save_answer = TRUE)
  #messagef("Len pages: %d, counter; %d, length: %d", length(pages), counter, seq_len)
  pages[[counter]]
}
