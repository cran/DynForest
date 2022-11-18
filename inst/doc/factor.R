## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  library("DynForest")
#  pbc2 <- pbc2[which(pbc2$years>4&pbc2$time<=4),]
#  pbc2$event <- ifelse(pbc2$event==2, 1, 0)
#  pbc2$event[which(pbc2$years>10)] <- 0
#  set.seed(1234)
#  id <- unique(pbc2$id)
#  id_sample <- sample(id, length(id)*2/3)
#  id_row <- which(pbc2$id%in%id_sample)
#  pbc2_train <- pbc2[id_row,]
#  pbc2_pred <- pbc2[-id_row,]

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  timeData_train <- pbc2_train[,c("id","time",
#                                  "serBilir","SGOT",
#                                  "albumin","alkaline")]
#  fixedData_train <- unique(pbc2_train[,c("id","age","drug","sex")])

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  timeVarModel <- list(serBilir = list(fixed = serBilir ~ time,
#                                       random = ~ time),
#                       SGOT = list(fixed = SGOT ~ time + I(time^2),
#                                   random = ~ time + I(time^2)),
#                       albumin = list(fixed = albumin ~ time,
#                                      random = ~ time),
#                       alkaline = list(fixed = alkaline ~ time,
#                                       random = ~ time))

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  Y <- list(type = "factor",
#            Y = unique(pbc2_train[,c("id","event")]))

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn <- DynForest(timeData = timeData_train,
#                       fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id",
#                       timeVarModel = timeVarModel,
#                       mtry = 7, nodesize = 2,
#                       Y = Y, seed = 1234)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn_OOB <- compute_OOBerror(DynForest_obj = res_dyn)
#  summary(res_dyn_OOB)
#  
#  DynForest executed with classification mode
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
#  DynForest summary
#  	Average depth by tree: 5.85
#  	Average number of leaves by tree: 16.7
#  	Average number of subjects by leaf: 9.31
#  ----------------
#  Out-of-bag error based on Missclassification
#  	Out-of-bag error: 0.2333
#  ----------------
#  Time to build the random forest
#  	Time difference of 1.808804 mins
#  ----------------

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  timeData_pred <- pbc2_pred[,c("id","time",
#                                "serBilir","SGOT",
#                                "albumin","alkaline")]
#  fixedData_pred <- unique(pbc2_pred[,c("id","age","drug","sex")])
#  pred_dyn <- predict(object = res_dyn,
#                      timeData = timeData_pred,
#                      fixedData = fixedData_pred,
#                      idVar = "id", timeVar = "time",
#                      t0 = 4)
#  head(data.frame(pred = pred_dyn$pred_indiv,
#                  proba = pred_dyn$pred_indiv_proba))
#  
#      pred proba
#  101    0 0.960
#  104    0 0.780
#  106    1 0.540
#  108    0 0.945
#  112    1 0.515
#  114    0 0.645

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn_VIMP <- compute_VIMP(DynForest_obj = res_dyn_OOB, seed = 123)
#  plot(x = res_dyn_VIMP, PCT = TRUE)

## ---- eval = FALSE------------------------------------------------------------
#  depth_dyn <- var_depth(DynForest_obj = res_dyn_OOB)
#  plot(x = depth_dyn, plot_level = "predictor")
#  plot(x = depth_dyn, plot_level = "feature")

## ---- fig.cap = "Figure 1: Average minimal depth level by predictor (A) and feature (B).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_factor_mindepth.png")

