## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----message = FALSE----------------------------------------------------------
library("DynForest")
data(data_simu1)
head(data_simu1)

## -----------------------------------------------------------------------------
data(data_simu2)
head(data_simu2)

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
#  res_dyn <- dynforest(timeData = timeData_train,
#                       fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id",
#                       timeVarModel = timeVarModel,
#                       mtry = 10, Y = Y,
#                       ncores = 7, seed = 1234)

## ----eval = FALSE-------------------------------------------------------------
#  res_dyn_OOB <- compute_ooberror(dynforest_obj = res_dyn)

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  summary(res_dyn_OOB)
#  
#  dynforest executed for continuous outcome
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
#  dynforest summary
#  	Average depth per tree: 9.06
#  	Average number of leaves per tree: 126.47
#  	Average number of subjects per leaf: 1
#  ----------------
#  Out-of-bag error based on Mean square error
#  	Out-of-bag error: 4.3713
#  ----------------
#  Computation time
#  	Number of cores used: 7
#  	Time difference of 8.261093 mins
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

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  head(print(pred_dyn))
#  
#           1          2          3          4          5          6
#   5.2184031 -1.2786887  0.8591368  1.5115312  5.2984117  7.9073981

## ----eval = FALSE, echo = TRUE, fig.show='hide'-------------------------------
#  depth_dyn <- compute_vardepth(dynforest_obj = res_dyn)
#  p1 <- plot(depth_dyn, plot_level = "predictor")
#  p2 <- plot(depth_dyn, plot_level = "feature")

## ----eval = FALSE, echo = TRUE------------------------------------------------
#  plot_grid(p1, p2, labels = c("A", "B"))

## ----DynForestRdepthscalar, fig.cap = "Figure 1: Average minimal depth level by predictor (A) and by feature (B).", eval = TRUE, echo = FALSE, out.width="70%"----
knitr::include_graphics("Figures/DynForestR_reg_mindepth.png")

