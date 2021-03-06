.dt_spanners_key <- "_spanners"

dt_spanners_get <- function(data) {

  dt__get(data, .dt_spanners_key)
}

dt_spanners_set <- function(data, spanners) {

  dt__set(data, .dt_spanners_key, spanners)
}

dt_spanners_init <- function(data) {

  empty_list <- lapply(seq_along(names(data)), function(x) NULL)

  dplyr::tibble(
    # Column names that are part of the spanner
    vars = list(),
    # The spanner label
    spanner_label = list(),
    # Should be columns be gathered under a single spanner label?
    gather = logical(0),
    built = NA_character_
  ) %>%
    dt_spanners_set(spanners = ., data = data)
}

dt_spanners_add <- function(data, vars, spanner_label, gather) {

  data %>%
    dt_spanners_get() %>%
    dplyr::bind_rows(
      dplyr::tibble(
        vars = list(vars),
        spanner_label = list(spanner_label),
        gather = gather,
        built = NA_character_
      )
    ) %>%
    dt_spanners_set(spanners = ., data = data)
}

dt_spanners_exists <- function(data) {

  spanners <- dt_spanners_get(data = data)

  nrow(spanners) > 0
}

dt_spanners_build <- function(data, context) {

  spanners <- dt_spanners_get(data)

  spanners$built <-
    vapply(spanners$spanner_label, function(label) process_text(label, context), character(1))

  data <- dt_spanners_set(data = data, spanners = spanners)

  data
}

dt_spanners_print <- function(data, include_hidden = TRUE) {

  spanners <- data %>% dt_spanners_get()

  if (!include_hidden) {
    vars <- dt_boxhead_get_vars_default(data = data)
  } else {
    vars <- dt_boxhead_get_vars(data = data)
  }

  vars_list <- rep(NA_character_, length(vars)) %>% magrittr::set_names(vars)

  for (i in seq_len(nrow(spanners))) {
    vars_list[spanners$vars[[i]]] <- spanners$built[[i]]
  }

  vars_list[names(vars_list) %in% vars] %>% unname()
}
