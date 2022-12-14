#' Grow random survival tree using multivariate longitudinal endogenous covariates
#'
#' @param Y A list of output which should contain: \code{type} defines the nature of the outcome, can be "\code{surv}", "\code{numeric}" or "\code{factor}"; \code{Y} is the output variable; \code{id} is the vector of the identifiers for each individuals, they should be the same as the identifiers of the inputs.
#' @param Longitudinal A list of longitudinal predictors which should contain: \code{X} a dataframe with one row for repeated measurement and as many columns as markers; \code{id} is the vector of the identifiers for the repeated measurements contained in \code{X}; \code{time} is the vector of the measurement times contained in \code{X}.
#' @param Numeric A list of numeric predictors which should contain: \code{X} a dataframe with as many columns as numeric predictors; \code{id} is the vector of the identifiers for each individual.
#' @param Factor A list of factor predictors which should contain: \code{X} a dataframe with as many columns as factor predictors; \code{id} is the vector of the identifiers for each individual.
#' @param mtry Number of candidate variables randomly drawn at each node of the trees. This parameter should be tuned by minimizing the OOB error. Default is `NULL`.
#' @param nsplit_option A character indicates how the values are chosen to build the two groups for the splitting rule (only for continuous predictors). Values are chosen using deciles (\code{nsplit_option}="quantile") or randomly (\code{nsplit_option}="sample"). Default value is "quantile".
#' @param nodesize Minimal number of subjects required in both child nodes to split. Cannot be smaller than 1.
#' @param minsplit (Only with survival outcome) Minimal number of events required to split the node. Cannot be smaller than 2.
#' @param cause (Only with competing events) Number indicates the event of interest.
#' @param seed Seed to replicate results
#'
#' @import stringr
#' @import survival
#' @import prodlim
#' @importFrom splines ns
#'
#' @keywords internal
DynTree_surv <- function(Y, Longitudinal = NULL, Numeric = NULL, Factor = NULL, mtry = 1,
                         nsplit_option = "quantile", nodesize = 1, minsplit = 2, cause = 1,
                         seed = 1234){

  Inputs <- read.Xarg(c(Longitudinal,Numeric,Factor))

  V_split <- data.frame(type = character(), id_node = integer(), var_split = integer(),
                        feature = integer(), threshold = numeric(), N = integer(),
                        Nevent = integer(), stringsAsFactors = FALSE)
  hist_nodes <- list()
  model_param <- list()
  model_init <- list()
  set.seed(seed) # set seed for bootstrap
  id_boot <- unique(sample(unique(Y$id), length(unique(Y$id)), replace=TRUE))
  boot <- id_boot
  num_split <- 1

  wXLongitudinal <- NULL
  wXNumeric <- NULL
  wXFactor <- NULL
  wY <- NULL

  wY <- which(Y$id%in%id_boot)
  if (!is.null("Longitudinal")) wXLongitudinal <- which(Longitudinal$id%in%id_boot)
  if (!is.null("Numeric")) wXNumeric <- which(Numeric$id%in%id_boot)
  if (!is.null("Factor")) wXFactor <- which(Factor$id%in%id_boot)

  Y_pred <- list()

  # bootstrap inputs
  if (!is.null("Longitudinal")) Longitudinal_boot <- list(type = Longitudinal$type,
                                                          X = Longitudinal$X[wXLongitudinal,, drop=FALSE],
                                                          id = Longitudinal$id[wXLongitudinal], time = Longitudinal$time[wXLongitudinal],
                                                          model = Longitudinal$model)
  if (!is.null("Numeric")) Numeric_boot <- list(type = Numeric$type,
                                                X = Numeric$X[wXNumeric,, drop=FALSE],
                                                id = Numeric$id[wXNumeric])
  if (!is.null("Factor")) Factor_boot <- list(type = Factor$type,
                                              X = Factor$X[wXFactor,, drop=FALSE],
                                              id = Factor$id[wXFactor])
  # bootstrap output
  Y_boot <- list(type=Y$type,Y=Y$Y[wY], id=Y$id[wY], comp=Y$comp)

  imp_nodes <- list()
  imp_nodes[[1]] <- Inf
  impur <- Inf

  # root node 1
  id_leaf <- rep(1,length(Y_boot$id))
  id_leaf_prime <- id_leaf
  current_leaves <- unique(id_leaf)
  final_leaves <- NULL

  for (p in 1:(length(unique(Y_boot$id))/2-1)){

    count_split <- 0

    for (i in 1:length(current_leaves)){

      V <- unlist(sapply(Inputs, FUN = function(x) return(rep(get(x)$type, ncol(get(x)$X)))))

      # mtry for each nature of input
      set.seed(seed+p*i)
      variables <- sample(V,mtry)
      split.spaces <- unique(variables)

      w <- which(id_leaf==current_leaves[i])
      wXLongitudinal <- NULL
      wXNumeric <- NULL
      wXFactor <- NULL

      if (!is.null("Longitudinal")) wXLongitudinal <- which(Longitudinal_boot$id%in%unique(Y_boot$id[w]))
      if (!is.null("Numeric")) wXNumeric <- which(Numeric_boot$id%in%unique(Y_boot$id[w]))
      if (!is.null("Factor")) wXFactor <- which(Factor_boot$id%in%unique(Y_boot$id[w]))

      if (length(unique(Y_boot$id[w]))>1 & imp_nodes[[current_leaves[i]]] >0){

        # Drawn mtry predictors

        if (is.element("Longitudinal",split.spaces)==TRUE){

          tirageLongitudinal <- sample(1:ncol(Longitudinal$X),length(which(variables=="Longitudinal")))
          Longitudinal_current <- list(type = Longitudinal_boot$type, X=Longitudinal_boot$X[wXLongitudinal,tirageLongitudinal, drop=FALSE], id=Longitudinal_boot$id[wXLongitudinal, drop=FALSE], time=Longitudinal_boot$time[wXLongitudinal, drop=FALSE],
                                       model = Longitudinal_boot$model[tirageLongitudinal])

          current_node <- current_leaves[i]

          if (current_node > 1){
            model_init <- getParamMM(current_node = current_node, markers = colnames(Longitudinal_current$X),
                                     params = model_init)
          }else{
            model_init[[current_node]] <- lapply(Longitudinal$model, FUN = function(x) x$init.param)
          }

        }

        if (is.element("Numeric",split.spaces)==TRUE){

          tirageNumeric <- sample(1:ncol(Numeric$X),length(which(variables=="Numeric")))
          Numeric_current <- list(type = Numeric_boot$type, X=Numeric_boot$X[wXNumeric,tirageNumeric, drop=FALSE], id=Numeric_boot$id[wXNumeric, drop=FALSE])
        }

        if (is.element("Factor",split.spaces)==TRUE){

          tirageFactor <- sample(1:ncol(Factor$X),length(which(variables=="Factor")))
          Factor_current <- list(type = Factor_boot$type, X=Factor_boot$X[wXFactor,tirageFactor, drop=FALSE], id=Factor_boot$id[wXFactor, drop=FALSE])
        }

        Y_current <- list(type=Y_boot$type, Y=Y_boot$Y[w], id=Y_boot$id[w], comp=Y$comp)

        F_SPLIT <- data.frame(TYPE = character(), Impurity = numeric(), stringsAsFactors = FALSE)
        num_split <- 0

        Nevent_current <- sum(Y_current$Y[,2]==cause)
        N_current <- length(Y_current$id)

        if (Nevent_current >= minsplit & N_current >= nodesize*2){

          # Try best split on mtry factor predictors
          if (is.element("Factor",split.spaces)==TRUE){

            leaf_split_Factor <- var_split_surv(X = Factor_current, Y = Y_current,
                                                cause = cause, nodesize = nodesize)

            if (leaf_split_Factor$Pure==FALSE){
              F_SPLIT <- merge(F_SPLIT,
                               data.frame(TYPE = "Factor", Impurity = leaf_split_Factor$impur,
                                          stringsAsFactors = FALSE),
                               all = T)
              num_split <- num_split +1
            }
          }

          # Try best split on mtry Longitudinal predictors
          if (is.element("Longitudinal",split.spaces)==TRUE){

            leaf_split_Longitudinal <- var_split_surv(X = Longitudinal_current, Y = Y_current,
                                                      nsplit_option = nsplit_option,
                                                      cause = cause, nodesize = nodesize,
                                                      init = model_init[[current_leaves[i]]])

            if (leaf_split_Longitudinal$Pure==FALSE){
              model_init[[current_leaves[i]]] <- leaf_split_Longitudinal$init # update initial values at current node
              F_SPLIT <- merge(F_SPLIT,
                               data.frame(TYPE = "Longitudinal", Impurity = leaf_split_Longitudinal$impur,
                                          stringsAsFactors = FALSE),
                               all = T)
              num_split <- num_split +1
            }
          }

          # Try best split on mtry Numeric predictors
          if (is.element("Numeric",split.spaces)==TRUE){

            leaf_split_Numeric <- var_split_surv(X = Numeric_current, Y = Y_current,
                                                 nsplit_option = nsplit_option,
                                                 cause = cause, nodesize = nodesize)

            if (leaf_split_Numeric$Pure==FALSE){
              F_SPLIT <- merge(F_SPLIT,
                               data.frame(TYPE = "Numeric", Impurity = leaf_split_Numeric$impur,
                                          stringsAsFactors = FALSE),
                               all = T)
              num_split <- num_split +1
            }


          }

        }else{
          final_leaves <- c(final_leaves, current_leaves[i])

          Nevent <- sum(Y_current$Y[,2]==cause) # nb event

          # add leaves to V_split
          V_split_node <- data.frame(type = "Leaf", id_node = current_leaves[i], var_split = NA,
                                     feature = NA, threshold = NA, N = length(Y_current$id),
                                     Nevent = Nevent, stringsAsFactors = FALSE)

          V_split <- merge(V_split, V_split_node, all = T)

          next()
        }

        if (num_split>0){

          TYPE <- F_SPLIT[which.min(F_SPLIT[,2]),1]
          X <- get(TYPE)
          X_boot <- get(paste(TYPE,"_boot",sep=""))

          # Get best partition

          leaf_split <- get(paste("leaf_split_",TYPE, sep=""))
          vsplit_space <- get(paste("tirage",TYPE, sep=""))[leaf_split$variable]

          gauche_id <- unique(Y_current$id)[which(leaf_split$split==1)]
          droit_id <- unique(Y_current$id)[which(leaf_split$split==2)]

          if (sum(is.na(leaf_split$split)) > 0){
            na_id <- unique(Y_current$id)[which(is.na(leaf_split$split))]
          }else{
            na_id <- NULL
          }

          LN <- length(gauche_id)
          RN <- length(droit_id)

          if (LN>=nodesize & RN>=nodesize){
            imp_nodes[[2*current_leaves[i]]] <- Inf
            imp_nodes[[2*current_leaves[i]+1]] <- Inf
          }else{
            final_leaves <- c(final_leaves, current_leaves[i])
            Nevent <- sum(Y_current$Y[,2]==cause) # nb event

            # add leaves to V_split
            V_split_node <- data.frame(type = "Leaf", id_node = current_leaves[i], var_split = NA,
                                       feature = NA, threshold = NA, N = length(Y_current$id),
                                       Nevent = Nevent, stringsAsFactors = FALSE)

            V_split <- merge(V_split, V_split_node, all = T)

            next()
          }

          Nevent <- sum(Y_current$Y[,2]==cause) # nb event

          # add node split to V_split
          V_split_node <- data.frame(type = TYPE, id_node = current_leaves[i],
                                     var_split = vsplit_space, feature = leaf_split$variable_summary,
                                     threshold = leaf_split$threshold, N = length(Y_current$id),
                                     Nevent = Nevent, stringsAsFactors = FALSE)

          V_split <- merge(V_split, V_split_node, all = T)

          model_param[[current_leaves[i]]] <- leaf_split$model_param

          w_gauche <- which(X_boot$id%in%gauche_id)
          wY_gauche <- which(Y_boot$id%in%gauche_id)

          w_droit <- which(X_boot$id%in%droit_id)
          wY_droit <- which(Y_boot$id%in%droit_id)

          if (!is.null(na_id)){
            wY_na <- which(Y_boot$id%in%na_id)
            id_leaf_prime[wY_na] <- NA
          }

          id_leaf_prime[wY_gauche] <- 2*(current_leaves[i])
          id_leaf_prime[wY_droit] <- 2*(current_leaves[i])+1

          if (X$type=="Longitudinal"){
            # trajG <- as.data.frame(cbind(X_boot$id[w_gauche], X_boot$time[w_gauche], X_boot$X[w_gauche,vsplit_space]))
            # trajD <- as.data.frame(cbind(X_boot$id[w_droit], X_boot$time[w_droit], X_boot$X[w_droit,vsplit_space]))
            # meanFg <- as.matrix(kmlShape::meanFrechet(trajG))
            # meanFd <- as.matrix(kmlShape::meanFrechet(trajD))
            meanFg <- NA
            meanFd <- NA
          }

          if (X$type=="Factor"){
            meanFg <- unique(X_boot$X[w_gauche, vsplit_space])
            meanFd <- unique(X_boot$X[w_droit,vsplit_space])
          }

          if (X$type=="Numeric"){
            meanFg <- mean(X_boot$X[w_gauche,vsplit_space])
            meanFd <- mean(X_boot$X[w_droit,vsplit_space])
          }


          hist_nodes[[2*(current_leaves[i])]] <- meanFg
          hist_nodes[[2*(current_leaves[i])+1]] <- meanFd
          count_split <- count_split+1

        }
      }else{

        final_leaves <- c(final_leaves, current_leaves[i])

        Nevent <- sum(Y_current$Y[,2]==cause) # nb event

        # add leaves to V_split
        V_split_node <- data.frame(type = "Leaf", id_node = current_leaves[i], var_split = NA,
                                   feature = NA, threshold = NA, N = length(Y_current$id),
                                   Nevent = Nevent, stringsAsFactors = FALSE)

        V_split <- merge(V_split, V_split_node, all = T)

      }
    }

    id_leaf <- id_leaf_prime
    current_leaves <- setdiff(unique(na.omit(id_leaf_prime)), final_leaves)

    if (count_split ==0){

      V_split <- V_split[order(V_split$id_node),]
      V_split$depth <- floor(log(V_split$id_node, base = 2)) + 1 # depth level
      rownames(V_split) <- seq(nrow(V_split))

      for (q in unique(id_leaf)){
        w <- which(id_leaf == q)

        datasurv <- data.frame(time_event = Y_boot$Y[w][,1], event = Y_boot$Y[w][,2])
        fit <- prodlim(Hist(time_event, event)~1, data = datasurv,
                       type = "risk")

        if (is.null(fit$cuminc)){
          pred <- list()
          current.cause <- as.character(unique(datasurv$event[which(datasurv$event!=0)])) # num cause

          if (length(current.cause)==0){
            current.cause <- "1"
          }

          pred[[current.cause]] <- data.frame(times=fit$time, traj=1-fit$surv) # 1-KM

          if (is.null(pred[[as.character(cause)]])){
            pred[[as.character(cause)]] <- data.frame(times=fit$time, traj = 0) # no event => no risk
          }

        }else{
          pred <- lapply(fit$cuminc, FUN = function(x) return(data.frame(times=fit$time, traj=x))) # CIF Aalen-Johansen
        }

        Y_pred[[q]] <- lapply(pred, function(x){
          combine_times(pred = x, newtimes = unique(Y$Y[,1]), type = "risk")
        })

      }

      return(list(leaves = id_leaf, idY = Y_boot$id, Ytype = Y_boot$type,
                  V_split = V_split, hist_nodes = hist_nodes,
                  Y_pred = Y_pred, Y = Y, boot = boot,
                  model_param = model_param))
    }
  }

  V_split <- V_split[order(V_split$id_node),]
  V_split$depth <- floor(log(V_split$id_node, base = 2)) + 1 # depth level
  rownames(V_split) <- seq(nrow(V_split))

  for (q in unique(id_leaf)){

    w <- which(id_leaf == q)

    datasurv <- data.frame(time_event = Y_boot$Y[w][,1], event = Y_boot$Y[w][,2])
    fit <- prodlim(Hist(time_event, event)~1, data = datasurv,
                   type = "risk")

    if (is.null(fit$cuminc)){
      pred <- list()
      current.cause <- as.character(unique(sort(datasurv$event))[-1])

      if (length(current.cause)==0){
        current.cause <- "1"
      }

      pred[[current.cause]] <- data.frame(times=fit$time, traj=1-fit$surv) # 1-KM

      if (is.null(pred[[as.character(cause)]])){
        pred[[as.character(cause)]] <- data.frame(times=fit$time, traj = 0) # no event => no risk
      }

    }else{
      pred <- lapply(fit$cuminc, FUN = function(x) return(data.frame(times=fit$time, traj=x))) # CIF Aalen-Johansen
    }

    Y_pred[[q]] <- lapply(pred, function(x){
      combine_times(pred = x, newtimes = unique(Y$Y[,1]), type = "risk")
    })


  }

  return(list(leaves = id_leaf, idY=Y_boot$id, Ytype = Y_boot$type, V_split = V_split,
              hist_nodes = hist_nodes, Y_pred= Y_pred, Y = Y, boot = boot,
              model_param = model_param))
}
