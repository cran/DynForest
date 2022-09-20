## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## -----------------------------------------------------------------------------
#  # load package
#  library(DynForest)
#  
#  # load data
#  data(pbc2)
#  
#  # Split the data for training and prediction steps
#  set.seed(1234)
#  id <- unique(pbc2$id)
#  id_sample <- sample(id, length(id)*2/3)
#  id_row <- which(pbc2$id%in%id_sample)
#  pbc2_train <- pbc2[id_row,]
#  pbc2_pred <- pbc2[-id_row,]

## -----------------------------------------------------------------------------
#  # Build predictors objects
#  timeData_train <- pbc2_train[,c("id","time",
#                                  "serBilir","SGOT",
#                                  "albumin","alkaline")]
#  fixedData_train <- unique(pbc2_train[,c("id","age","drug","sex")])

## -----------------------------------------------------------------------------
#  # Create object with longitudinal association for each predictor
#  timeVarModel <- list(serBilir = list(fixed = serBilir ~ time,
#                                       random = ~ time),
#                       SGOT = list(fixed = SGOT ~ time + I(time^2),
#                                   random = ~ time + I(time^2)),
#                       albumin = list(fixed = albumin ~ time,
#                                      random = ~ time),
#                       alkaline = list(fixed = alkaline ~ time,
#                                       random = ~ time))

## -----------------------------------------------------------------------------
#  # Build outcome object
#  Y <- list(type = "surv",
#            Y = unique(pbc2_train[,c("id","years","event")]))

## -----------------------------------------------------------------------------
#  # Build the random forest
#  res_dyn <- DynForest(timeData = timeData_train, fixedData = fixedData_train,
#                       timeVar = "time", idVar = "id", timeVarModel = timeVarModel,
#                       ntree = 200, nodesize = 5, minsplit = 5, cause = 2,
#                       Y = Y, seed = 1234)

## -----------------------------------------------------------------------------
#  head(res_dyn$rf[,1]$V_split)
#  
#  tail(res_dyn$rf[,1]$V_split)

## -----------------------------------------------------------------------------
#  # Display CIF for cause of interest
#  plot(res_dyn$rf[,1]$Y_pred[[192]]$`2`, type = "l", col = "red",
#       xlab = "Years", ylab = "CIF", ylim = c(0,1))

## -----------------------------------------------------------------------------
#  # Compute OOB error
#  res_dyn_OOB <- compute_OOBerror(DynForest_obj = res_dyn)

## -----------------------------------------------------------------------------
#  # Get summary
#  summary(res_dyn_OOB)

## -----------------------------------------------------------------------------
#  # Build data for prediction
#  id_pred <- unique(pbc2_pred$id[which(pbc2_pred$years>4)])
#  pbc2_pred <- pbc2_pred[which(pbc2_pred$id%in%id_pred),]
#  timeData_pred <- pbc2_pred[,c("id", "time", "serBilir", "SGOT", "albumin", "alkaline")]
#  fixedData_pred <- unique(pbc2_pred[,c("id","age","drug","sex")])
#  
#  # Prediction step
#  pred_dyn <- predict(object = res_dyn,
#                      timeData = timeData_pred, fixedData = fixedData_pred,
#                      idVar = "id", timeVar = "time",
#                      t0 = 4)

## -----------------------------------------------------------------------------
#  plot_CIF(DynForestPred_obj = pred_dyn,
#           id = c(102, 260))

## -----------------------------------------------------------------------------
#  # Compute VIMP statistic
#  res_dyn_VIMP <- compute_VIMP(DynForest_obj = res_dyn_OOB)
#  
#  # Plot VIMP statistic
#  plot_VIMP(res_dyn_VIMP)

## -----------------------------------------------------------------------------
#  # Define groups
#  group <- list(group1 = c("serBilir","SGOT"),
#                group2 = c("albumin","alkaline"))
#  
#  # Compute gVIMP statistic
#  res_dyn_gVIMP <- compute_gVIMP(DynForest_obj = res_dyn_OOB,
#                                 group = group)
#  
#  # Plot gVIMP statistic
#  plot_gVIMP(res_dyn_gVIMP)

## -----------------------------------------------------------------------------
#  # Extract tree building information
#  depth_dyn <- var_depth(res_dyn)
#  
#  # Plot average minimal depth by predictor
#  plot_mindepth(var_depth_obj = depth_dyn,
#                plot_level = "predictor")
#  
#  # Plot average minimal depth by feature
#  plot_mindepth(var_depth_obj = depth_dyn,
#                plot_level = "feature")

## -----------------------------------------------------------------------------
#  err.OOB <- vector("numeric", 7)
#  
#  for (i in 1:7){
#  
#    set.seed(i)
#  
#    res_dyn_mtry <- DynForest(timeData = timeData_train, fixedData = fixedData_train,
#                              timeVar = "time", idVar = "id",
#                              timeVarModel = timeVarModel, Y = Y,
#                              ntree = 200, mtry = i, nodesize = 2, minsplit = 3,
#                              cause = 2)
#  
#    res_dyn_mtry_OOB <- compute_OOBerror(DynForest_obj = res_dyn_mtry)
#  
#    err.OOB[i] <- mean(res_dyn_mtry_OOB$xerror, na.rm = T)
#  
#  }

## -----------------------------------------------------------------------------
#  library(ggplot2)
#  ggplot(data.frame(mtry = seq(7), OOB.error = err.OOB), aes(x = mtry, y = OOB.error)) +
#    geom_line(color = "red") +
#    geom_point(color = "red", size = 1) +
#    ylab("OOB error") +
#    theme_bw()

