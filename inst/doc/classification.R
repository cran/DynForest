## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----message = FALSE----------------------------------------------------------
library("DynForest")
data(pbc2)
head(pbc2)

## ----message = FALSE----------------------------------------------------------
pbc2 <- pbc2[which(pbc2$years>4&pbc2$time<=4),]
pbc2$event <- ifelse(pbc2$event==2, 1, 0)
pbc2$event[which(pbc2$years>10)] <- 0
set.seed(1234)
id <- unique(pbc2$id)
id_sample <- sample(id, length(id)*2/3)
id_row <- which(pbc2$id%in%id_sample)
pbc2_train <- pbc2[id_row,]
pbc2_pred <- pbc2[-id_row,]

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  timeData_train <- pbc2_train[,c("id","time",
#                                  "serBilir","SGOT",
#                                  "albumin","alkaline")]
#  timeVarModel <- list(serBilir = list(fixed = serBilir ~ time,
#                                       random = ~ time),
#                       SGOT = list(fixed = SGOT ~ time + I(time^2),
#                                   random = ~ time + I(time^2)),
#                       albumin = list(fixed = albumin ~ time,
#                                      random = ~ time),
#                       alkaline = list(fixed = alkaline ~ time,
#                                       random = ~ time))
#  fixedData_train <- unique(pbc2_train[,c("id","age","drug","sex")])

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  Y <- list(type = "factor",
#            Y = unique(pbc2_train[,c("id","event")]))

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn <- dynforest(timeData = timeData_train,
#                       fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id",
#                       timeVarModel = timeVarModel,
#                       mtry = 7, nodesize = 2,
#                       Y = Y, ncores = 7, seed = 1234)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn_OOB <- compute_ooberror(dynforest_obj = res_dyn)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  summary(res_dyn_OOB)
#  
#  dynforest executed for categorical outcome
#  	Splitting rule: Minimize weighted within-group Shannon entropy
#  	Out-of-bag error type: Missclassification
#  	Leaf statistic: Majority vote
#  ----------------
#  Input
#  	Number of subjects: 150
#  	Longitudinal: 4 predictor(s)
#  	Numeric: 1 predictor(s)
#  	Factor: 2 predictor(s)
#  ----------------
#  Tuning parameters
#  	mtry: 7
#  	nodesize: 2
#  	ntree: 200
#  ----------------
#  ----------------
#  dynforest summary
#  	Average depth per tree: 5.89
#  	Average number of leaves per tree: 16.81
#  	Average number of subjects per leaf: 5.72
#  ----------------
#  Out-of-bag error based on Missclassification
#  	Out-of-bag error: 0.2333
#  ----------------
#  Computation time
#  	Number of cores used: 7
#  	Time difference of 2.87888 mins
#  ----------------

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  timeData_pred <- pbc2_pred[,c("id","time",
#                                "serBilir","SGOT",
#                                "albumin","alkaline")]
#  fixedData_pred <- unique(pbc2_pred[,c("id","age","drug","sex")])
#  pred_dyn <- predict(object = res_dyn,
#                      timeData = timeData_pred,
#                      fixedData = fixedData_pred,
#                      idVar = "id", timeVar = "time",
#                      t0 = 4)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  head(data.frame(pred = pred_dyn$pred_indiv,
#                  proba = pred_dyn$pred_indiv_proba))
#  
#      pred proba
#  101    0 0.945
#  104    0 0.790
#  106    1 0.600
#  108    0 0.945
#  112    1 0.575
#  114    0 0.650

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  res_dyn_VIMP <- compute_vimp(dynforest_obj = res_dyn_OOB, seed = 123)
#  plot(res_dyn_VIMP, PCT = TRUE)

## ----fig.cap = "Figure 1: VIMP statistic displayed as a percentage of loss in OOB error of prediction.", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_classi_VIMP.png")

## ----eval = FALSE, echo = TRUE, fig.show='hide'-------------------------------
#  depth_dyn <- compute_vardepth(dynforest_obj = res_dyn_OOB)
#  p1 <- plot(depth_dyn, plot_level = "predictor")
#  p2 <- plot(depth_dyn, plot_level = "feature")

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  plot_grid(p1, p2, labels = c("A", "B"))

## ----DynForestRfactormindepth, fig.cap = "Figure 2: Average minimal depth by predictor (A) and feature (B).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_classi_mindepth.png")

