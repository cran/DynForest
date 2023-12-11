## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
#  timeData_train <- data_simu1[,c("id","time",
#                                  paste0("marker",seq(6)))]
#  timeVarModel <- lapply(paste0("marker",seq(6)),
#                         FUN = function(x){
#                           fixed <- reformulate(termlabels = "time",
#                                                response = x)
#                           random <- ~ time
#                           return(list(fixed = fixed, random = random))
#                         })
#  fixedData_train <- unique(data_simu1[,c("id",
#                                          "cont_covar1","cont_covar2",
#                                          "bin_covar1","bin_covar2")])

## ----eval = FALSE-------------------------------------------------------------
#  Y <- list(type = "numeric",
#            Y = unique(data_simu1[,c("id","Y_res")]))

## ----eval = FALSE-------------------------------------------------------------
#  res_dyn <- DynForest(timeData = timeData_train,
#                       fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id",
#                       timeVarModel = timeVarModel,
#                       mtry = 10,
#                       Y = Y, seed = 1234)

## ----eval = FALSE-------------------------------------------------------------
#  res_dyn_OOB <- compute_OOBerror(DynForest_obj = res_dyn)
#  summary(res_dyn_OOB)
#  
#  DynForest executed with regression mode
#  	Splitting rule: Minimize weighted within-group variance
#  	Out-of-bag error type: Mean square error
#  	Leaf statistic: Mean
#  ----------------
#  Input
#  	Number of subjects: 200
#  	Longitudinal: 6 predictor(s)
#  	Numeric: 2 predictor(s)
#  	Factor: 2 predictor(s)
#  ----------------
#  Tuning parameters
#  	mtry: 10
#  	nodesize: 1
#  	ntree: 200
#  ----------------
#  ----------------
#  DynForest summary
#  	Average depth by tree: 9.06
#  	Average number of leaves by tree: 126.47
#  	Average number of subjects by leaf: 3.03
#  ----------------
#  Out-of-bag error based on Mean square error
#  	Out-of-bag error: 4.3663
#  ----------------
#  Time to build the random forest
#  	Time difference of 4.74484 mins
#  ----------------

## ----eval = FALSE-------------------------------------------------------------
#  timeData_pred <- data_simu2[,c("id","time",
#                                 paste0("marker",seq(6)))]
#  fixedData_pred <- unique(data_simu2[,c("id","cont_covar1","cont_covar2",
#                                         "bin_covar1","bin_covar2")])
#  pred_dyn <- predict(object = res_dyn,
#                      timeData = timeData_pred,
#                      fixedData = fixedData_pred,
#                      idVar = "id", timeVar = "time")

## ----eval = FALSE-------------------------------------------------------------
#  head(pred_dyn$pred_indiv)
#  
#           1          2          3          4          5          6
#   5.2117462 -1.2899651  0.8591368  1.5115133  5.2957749  7.9194240

## ----eval = FALSE-------------------------------------------------------------
#  depth_dyn <- var_depth(DynForest_obj = res_dyn)
#  plot(x = depth_dyn, plot_level = "predictor")
#  plot(x = depth_dyn, plot_level = "feature")

## ----fig.cap = "Figure 1: Average minimal depth level by predictor (A) and by feature (B).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_mindepth_scalar.png")

