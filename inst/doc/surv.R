## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  library("DynForest")
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
#  Y <- list(type = "surv",
#            Y = unique(pbc2[,c("id","years","event")]))

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn <- DynForest(timeData = timeData_train,
#                       fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id",
#                       timeVarModel = timeVarModel, Y = Y,
#                       ntree = 200, mtry = 3, nodesize = 2, minsplit = 3,
#                       cause = 2, seed = 1234)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  summary(res_dyn)
#  
#  DynForest executed with survival (competing risk) mode
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
#  DynForest summary
#  	Average depth by tree: 6.61
#  	Average number of leaves by tree: 28.01
#  	Average number of subjects by leaf: 4.71
#  	Average number of events of interest by leaf: 1.91
#  ----------------
#  Out-of-bag error based on Integrated Brier Score
#  	Out-of-bag error: Not computed!
#  ----------------
#  Time to build the random forest
#  	Time difference of 3.000176 mins
#  ----------------

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  head(res_dyn$rf[,1]$V_split)
#  
#            type id_node var_split feature   threshold   N Nevent depth
#  1 Longitudinal       1         3       1 -0.21993804 129     49     1
#  2 Longitudinal       2         2       1  5.57866304  26     21     2
#  3      Numeric       3         1      NA 61.83057715 103     28     2
#  4 Longitudinal       4         2       3  1.42021938  18     13     3
#  5       Factor       5         1      NA          NA   8      8     3
#  6 Longitudinal       6         3       2 -0.01010312  92     22     3

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  tail(res_dyn$rf[,1]$V_split)
#  
#             type id_node var_split feature threshold N Nevent depth
#  48         Leaf     192        NA      NA        NA 4      2     8
#  49         Leaf     193        NA      NA        NA 2      2     8
#  50         Leaf     194        NA      NA        NA 2      1     8
#  51 Longitudinal     195         4       1 -27.58024 4      3     8
#  52         Leaf     390        NA      NA        NA 2      1     9
#  53         Leaf     391        NA      NA        NA 2      2     9

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  plot(res_dyn$rf[,1]$Y_pred[[192]]$`2`, type = "l", col = "red",
#       xlab = "Years", ylab = "CIF", ylim = c(0,1))

## ---- fig.cap = "Figure 1: Estimated cumulative incidence functions of death before transplantation for subject 104 over 9 trees.", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestRPaper_CIF.png")

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn_OOB <- compute_OOBerror(DynForest_obj = res_dyn)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  mean(res_dyn_OOB$oob.err)
#  
#  [1] 0.1238627

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  id_pred <- unique(pbc2_pred$id[which(pbc2_pred$years>4)])
#  pbc2_pred_tLM <- pbc2_pred[which(pbc2_pred$id%in%id_pred),]
#  timeData_pred <- pbc2_pred_tLM[,c("id","time",
#                                    "serBilir","SGOT",
#                                    "albumin","alkaline")]
#  fixedData_pred <- unique(pbc2_pred_tLM[,c("id","age","drug","sex")])
#  pred_dyn <- predict(object = res_dyn,
#                      timeData = timeData_pred,
#                      fixedData = fixedData_pred,
#                      idVar = "id", timeVar = "time",
#                      t0 = 4)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  plot_CIF(DynForestPred_obj = pred_dyn,
#           id = c(102, 260))

## ---- fig.cap = "Figure 2: Predicted cumulative incidence function for subjects 102 and 260 from landmark time of 4 years (represented by a dashed line).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_predCIF.png")

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn_VIMP <- compute_VIMP(DynForest_obj = res_dyn, seed = 123)
#  plot(x = res_dyn_VIMP, PCT = TRUE)

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  group <- list(group1 = c("serBilir","SGOT"),
#                group2 = c("albumin","alkaline"))
#  res_dyn_gVIMP <- compute_gVIMP(DynForest_obj = res_dyn,
#                                 group = group, seed = 123)
#  plot(x = res_dyn_gVIMP, PCT = TRUE)

## ---- fig.cap = "Figure 3: Using VIMP statistic (A), we observe that `serBilir` and `albumin` are the most predictive predictors. Using grouped-VIMP statistic (B), group1 (`serBilir` and `SGOT`) has more predictive ability than group2 (`albumin` and `alkaline`).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_VIMP_gVIMP.png")

## ---- eval = FALSE, echo = TRUE-----------------------------------------------
#  res_dyn_max <- DynForest(timeData = timeData_train,
#                           fixedData = fixedData_train,
#                           timeVar = "time", idVar = "id",
#                           timeVarModel = timeVarModel, Y = Y,
#                           ntree = 200, mtry = 7, nodesize = 2, minsplit = 3,
#                           cause = 2, seed = 1234)
#  depth_dyn <- var_depth(DynForest_obj = res_dyn_max)
#  plot(x = depth_dyn, plot_level = "predictor")
#  plot(x = depth_dyn, plot_level = "feature")

## ---- fig.cap = "Figure 4: Average minimal depth level by predictor (A) and feature (B).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_mindepth.png")

## ---- fig.cap = "Figure 5: OOB error according to `mtry` hyperparameter. The optimal value was found for `mtry` = 7.", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_mtrytuned.png")

