## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----dynforestRgraph, eval = TRUE, echo = FALSE, out.width = "80%", out.height = "30%", fig.cap = "Figure 1: Overall scheme of the tree building in DynForest with (A) the tree structure, (B) the node-specific treatment of time-dependent predictors to obtain time-fixed features, (C) the dichotomization of the time-fixed features, (D) the splitting rule."----
knitr::include_graphics("Figures/dynforestR_graph.png")

