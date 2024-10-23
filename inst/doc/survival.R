## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----message = FALSE----------------------------------------------------------
library("DynForest")
data(pbc2)
head(pbc2)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  set.seed(1234)
#  id <- unique(pbc2$id)
#  id_sample <- sample(id, length(id)*2/3)
#  id_row <- which(pbc2$id %in% id_sample)
#  pbc2_train <- pbc2[id_row,]
#  pbc2_pred <- pbc2[-id_row,]

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  timeData_train <- pbc2_train[,c("id","time",
#                                  "serBilir","SGOT",
#                                  "albumin","alkaline")]
#  fixedData_train <- unique(pbc2_train[,c("id","age","drug","sex")])

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  timeVarModel <- list(serBilir = list(fixed = serBilir ~ time,
#                                       random = ~ time),
#                       SGOT = list(fixed = SGOT ~ time + I(time^2),
#                                   random = ~ time + I(time^2)),
#                       albumin = list(fixed = albumin ~ time,
#                                      random = ~ time),
#                       alkaline = list(fixed = alkaline ~ time,
#                                       random = ~ time))

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  Y <- list(type = "surv",
#            Y = unique(pbc2_train[,c("id","years","event")]))

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn <- dynforest(timeData = timeData_train,
#                       fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id",
#                       timeVarModel = timeVarModel, Y = Y,
#                       ntree = 200, mtry = 3, nodesize = 2, minsplit = 3,
#                       cause = 2, ncores = 7, seed = 1234)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  summary(res_dyn)
#  
#  dynforest executed for survival (competing risk) outcome
#  	Splitting rule: Fine & Gray statistic test
#  	Out-of-bag error type: Integrated Brier Score
#  	Leaf statistic: Cumulative incidence function
#  ----------------
#  Input
#  	Number of subjects: 208
#  	Longitudinal: 4 predictor(s)
#  	Numeric: 1 predictor(s)
#  	Factor: 2 predictor(s)
#  ----------------
#  Tuning parameters
#  	mtry: 3
#  	nodesize: 2
#  	minsplit: 3
#  	ntree: 200
#  ----------------
#  ----------------
#  dynforest summary
#  	Average depth per tree: 6.62
#  	Average number of leaves per tree: 27.68
#  	Average number of subjects per leaf: 4.78
#  	Average number of events of interest per leaf: 1.95
#  ----------------
#  Computation time
#  	Number of cores used: 7
#  	Time difference of 3.18191 mins
#  ----------------

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  head(get_tree(dynforest_obj = res_dyn, tree = 1))
#  
#            type id_node var_split feature  threshold   N depth
#  1 Longitudinal       1         4       2 -0.6931377 123     1
#  2      Numeric       2         2      NA -1.4960589  25     2
#  3      Numeric       3         1      NA -1.0052000  98     2
#  4 Longitudinal       4         3       1  0.3332725   3     3
#  5       Factor       5         2      NA         NA  22     3
#  6 Longitudinal       6         5       2  0.7550109  10     3

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  tail(get_tree(dynforest_obj = res_dyn, tree = 1))
#  
#              type id_node var_split feature     threshold N depth
#  156         Leaf   14522        NA      NA            NA 1    14
#  157 Longitudinal   14523         1       1  8.894535e-03 3    14
#  158 Longitudinal   29046         6       1 -1.385950e-07 2    15
#  159         Leaf   29047        NA      NA            NA 1    15
#  160         Leaf   58092        NA      NA            NA 1    16
#  161         Leaf   58093        NA      NA            NA 1    16

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  plot(res_dyn, tree = 1, nodes = 251)

## ----fig.cap = "Figure 1: Estimated cumulative incidence functions in tree 1 and node 251.", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_surv_CIF.png")

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  plot(res_dyn, id = 104, max_tree = 9)

## ----DynForestRCIF, fig.cap = "Figure 2: Estimated cumulative incidence functions for subject 104 over 9 trees.", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_surv_CIF9.png")

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn_OOB <- compute_ooberror(dynforest_obj = res_dyn)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn_OOB
#  
#  [1] 0.1265053

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  id_pred <- unique(pbc2_pred$id[which(pbc2_pred$years>4)])
#  pbc2_pred_tLM <- pbc2_pred[which(pbc2_pred$id %in% id_pred),]
#  timeData_pred <- pbc2_pred_tLM[,c("id","time",
#                                    "serBilir","SGOT",
#                                    "albumin","alkaline")]
#  fixedData_pred <- unique(pbc2_pred_tLM[,c("id","age","drug","sex")])
#  pred_dyn <- predict(object = res_dyn,
#                      timeData = timeData_pred,
#                      fixedData = fixedData_pred,
#                      idVar = "id", timeVar = "time",
#                      t0 = 4)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  plot(pred_dyn, id = c(102, 260))

## ----DynForestRpredCIF, fig.cap = "Figure 3: Predicted cumulative incidence function for subjects 102 and 260 from landmark time of 4 years (represented by the dashed vertical line)", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_surv_CIF9.png")

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn_VIMP <- compute_vimp(dynforest_obj = res_dyn, seed = 123)

## ----eval = FALSE, echo = TRUE, fig.show='hide'-------------------------------
#  p1 <- plot(res_dyn_VIMP, PCT = TRUE)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  group <- list(group1 = c("serBilir","SGOT"),
#                group2 = c("albumin","alkaline"))
#  res_dyn_gVIMP <- compute_gvimp(dynforest_obj = res_dyn,
#                                 group = group, seed = 123)

## ----eval = FALSE, echo = TRUE, fig.show='hide'-------------------------------
#  p2 <- plot(res_dyn_gVIMP, PCT = TRUE)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  plot_grid(p1, p2, labels = c("A", "B"))

## ----DynForestRVIMPgVIMP, fig.cap = "Figure 4: (A) VIMP statistic and (B) grouped-VIMP statistic displayed as a percentage of loss in OOB error of prediction. group1 includes serBilir and SGOT; group2 includes albumin and alkaline.", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_surv_VIMP_gVIMP.png")

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn_max <- dynforest(timeData = timeData_train,
#                           fixedData = fixedData_train,
#                           timeVar = "time", idVar = "id",
#                           timeVarModel = timeVarModel, Y = Y,
#                           ntree = 200, mtry = 7, nodesize = 2, minsplit = 3,
#                           cause = 2, ncores = 7, seed = 1234)

## ----echo = TRUE, eval = FALSE, fig.show='hide'-------------------------------
#  depth_dyn <- compute_vardepth(dynforest_obj = res_dyn_max)
#  p1 <- plot(depth_dyn, plot_level = "predictor")
#  p2 <- plot(depth_dyn, plot_level = "feature")

## ----echo = TRUE, eval = FALSE------------------------------------------------
#  plot_grid(p1, p2, labels = c("A", "B"))

## ----DynForestRmindepth, fig.cap = "Figure 5: Average minimal depth level by predictor (A) and feature (B).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_surv_mindepth.png")

## ----DynForestRmtrytuned, fig.cap = "Figure 6: OOB error according to mtry hyperparameter", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_surv_mtrytuned.png")

