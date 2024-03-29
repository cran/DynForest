% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot.DynForest}
\alias{plot.DynForest}
\alias{plot.DynForestVarDepth}
\alias{plot.DynForestVIMP}
\alias{plot.DynForestgVIMP}
\alias{plot.DynForestPred}
\title{Plot function in DynForest}
\usage{
\method{plot}{DynForest}(x, tree = NULL, nodes = NULL, id = NULL, max_tree = NULL, ...)

\method{plot}{DynForestVarDepth}(x, plot_level = c("predictor", "feature"), ...)

\method{plot}{DynForestVIMP}(x, PCT = FALSE, ordering = TRUE, ...)

\method{plot}{DynForestgVIMP}(x, PCT = FALSE, ...)

\method{plot}{DynForestPred}(x, id = NULL, ...)
}
\arguments{
\item{x}{Object inheriting from classes \code{DynForest}, \code{DynForestVarDepth}, \code{DynForestVIMP} or \code{DynForestgVIMP}, to respectively plot the CIF, the minimal depth, the variable importance or grouped variable importance.}

\item{tree}{For \code{DynForest} class, integer indicating the tree identifier}

\item{nodes}{For \code{DynForest} class, identifiers for the selected nodes}

\item{id}{For \code{DynForest} and \code{DynForestPred} classes, identifier for a given subject}

\item{max_tree}{For \code{DynForest} class, integer indicating the number of tree to display while using \code{id} argument}

\item{...}{Optional parameters to be passed to the low level function}

\item{plot_level}{For \code{DynForestVarDepth} class, compute the statistic at predictor (\code{plot_level}="predictor") or feature (\code{plot_level}="feature") level}

\item{PCT}{For \code{DynForestVIMP} or \code{DynForestgVIMP} class, display VIMP statistic in percentage. Default value is FALSE.}

\item{ordering}{For \code{DynForestVIMP} class, order predictors according to VIMP value. Default value is TRUE.}
}
\value{
\code{plot()} function displays: \tabular{ll}{
With \code{DynForestVarDepth} \tab the minimal depth for each predictor/feature \cr
\tab \cr
With \code{DynForestVIMP} \tab the VIMP for each predictor \cr
\tab \cr
With \code{DynForestgVIMP} \tab the grouped-VIMP for each given group \cr
}
}
\description{
This function displays a plot of CIF for a given node and tree (for class \code{DynForest}), the most predictive variables with the minimal depth (for class \code{DynForestVarDepth}), the variable importance (for class \code{DynForestVIMP}) or the grouped variable importance (for class \code{DynForestgVIMP}).
}
\examples{
\donttest{
data(pbc2)

# Get Gaussian distribution for longitudinal predictors
pbc2$serBilir <- log(pbc2$serBilir)
pbc2$SGOT <- log(pbc2$SGOT)
pbc2$albumin <- log(pbc2$albumin)
pbc2$alkaline <- log(pbc2$alkaline)

# Sample 100 subjects
set.seed(1234)
id <- unique(pbc2$id)
id_sample <- sample(id, 100)
id_row <- which(pbc2$id\%in\%id_sample)

pbc2_train <- pbc2[id_row,]

timeData_train <- pbc2_train[,c("id","time",
                                "serBilir","SGOT",
                                "albumin","alkaline")]

# Create object with longitudinal association for each predictor
timeVarModel <- list(serBilir = list(fixed = serBilir ~ time,
                                     random = ~ time),
                     SGOT = list(fixed = SGOT ~ time + I(time^2),
                                 random = ~ time + I(time^2)),
                     albumin = list(fixed = albumin ~ time,
                                    random = ~ time),
                     alkaline = list(fixed = alkaline ~ time,
                                     random = ~ time))

# Build fixed data
fixedData_train <- unique(pbc2_train[,c("id","age","drug","sex")])

# Build outcome data
Y <- list(type = "surv",
          Y = unique(pbc2_train[,c("id","years","event")]))

# Run DynForest function
res_dyn <- DynForest(timeData = timeData_train, fixedData = fixedData_train,
                     timeVar = "time", idVar = "id",
                     timeVarModel = timeVarModel, Y = Y,
                     ntree = 50, nodesize = 5, minsplit = 5,
                     cause = 2, ncores = 2, seed = 1234)

# Plot estimated CIF at nodes 17 and 32
plot(x = res_dyn, tree = 1, nodes = c(17,32))

# Run var_depth function
res_varDepth <- var_depth(res_dyn)

# Plot minimal depth
plot(x = res_varDepth, plot_level = "feature")

# Compute VIMP statistic
res_dyn_VIMP <- compute_VIMP(DynForest_obj = res_dyn, ncores = 2)

# Plot VIMP
plot(x = res_dyn_VIMP, PCT = TRUE)

# Compute gVIMP statistic
res_dyn_gVIMP <- compute_gVIMP(DynForest_obj = res_dyn,
                               group = list(group1 = c("serBilir","SGOT"),
                                            group2 = c("albumin","alkaline")),
                               ncores = 2)

# Plot gVIMP
plot(x = res_dyn_gVIMP, PCT = TRUE)

# Sample 5 subjects to predict the event
set.seed(123)
id_pred <- sample(id, 5)

# Create predictors objects
pbc2_pred <- pbc2[which(pbc2$id\%in\%id_pred),]
timeData_pred <- pbc2_pred[,c("id", "time", "serBilir", "SGOT", "albumin", "alkaline")]
fixedData_pred <- unique(pbc2_pred[,c("id","age","drug","sex")])

# Predict the CIF function for the new subjects with landmark time at 4 years
pred_dyn <- predict(object = res_dyn,
                    timeData = timeData_pred, fixedData = fixedData_pred,
                    idVar = "id", timeVar = "time",
                    t0 = 4)

# Plot predicted CIF for subjects 26 and 110
plot(x = pred_dyn, id = c(26, 110))

}

}
\seealso{
\code{\link{DynForest} \link{var_depth} \link{compute_VIMP} \link{compute_gVIMP}}
}
