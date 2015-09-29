#' getEstimationInfo
#'
#' This function acts on an object of class StandardOutputObject 
#' and presents information to the user about the estimation process.  
#' 
#' Depending on the target software and estimation method, values 
#' such as Objective Function Value (OFV), -2*log-likelihood and/or Information criteria
#' such as AIC, DIC, BIC may be returned. In addition, any warnings, errors and info messages 
#' from the log will also be stored in the returned output. If there are any errors of warnings, 
#' these will also be printed to the console.   
#'
#' @param object an object of class StandardOutputObject, the output from an 
#' estimation task.
#'
#' @return A nested list with two elements:.
#'         \describe{
#'  \item{"Liklihood"}{All information from the Liklihood slot of the SOObject}
#'  \item{"Messages"}{A nested list for each message grouped by message type ("Info", "Error", and/or "Warning" if present)}
#' }
#'
#' @examples getEstimationInfo(object)
#'
#' @export 
getEstimationInfo <- function(SOObject){
  
  if (!isS4(SOObject) && class(SO) == "StandardOutputObject") {
    stop(paste0("getEstimationInfo expected a StandardOutputObject as input, got a ", class(SOObject), '.'))
  }

  # Fetch Liklihood information
  likelihood <- SOObject@Estimation@Likelihood
  if ("IndividualContribToLL" %in% names(likelihood)) {
    likelihood[["IndividualContribToLL"]] = likelihood[["IndividualContribToLL"]][["data"]]
  } 
  # Format as numeric 
  if ("InformationCriteria" %in% names(likelihood)) {
    likelihood[["InformationCriteria"]] = lapply(likelihood$InformationCriteria, as.numeric)
  }

  # Fetch Messages 
  info.msgs <- list()
  for (elem in (SOObject@TaskInformation$Messages$Info)) { 
    info.msgs[[elem$Name]] <- elem$Content
  }
  err.msgs <- list()
  for (elem in (SOObject@TaskInformation$Messages$Errors)) { 
    err.msgs[[elem$Name]] <- elem$Content
  }
  warn.msgs <- list()
  for (elem in (SOObject@TaskInformation$Messages$Warnings)) { 
    warn.msgs[[elem$Name]] <- elem$Content
  }
  # Drop and list that does not contain messages
  temp.list <- list(Info=info.msgs, Errors=err.msgs, Warnings=warn.msgs)
  messages <- list()
  for (msg.list.name in names(temp.list)) {
    if (length(temp.list[[msg.list.name]]) > 0 ) {
      messages[[msg.list.name]] <- temp.list[[msg.list.name]]
    }
  }

  # Print out any errors in the SO Object to the R console to make it obvious if execution failed
  if (length(SOObject@TaskInformation$Messages$Errors) > 0) {
    message("\nThe following ERRORs were raised during the job execution:", file=stderr())
    for (e in (SOObject@TaskInformation$Messages$Errors)) { 
      message(paste0(" ", e$Name, ": ", str_trim(e$Content)), file=stderr()) 
    }
  }
  if (length(SOObject@TaskInformation$Messages$Warnings) > 0) {
    message("\nThe following WARNINGs were raised during the job execution:", file=stderr())
    for (e in (SOObject@TaskInformation$Messages$Warnings)) { 
      message(paste0(" ", e$Name, ": ", str_trim(e$Content)), file=stderr()) 
    }
  }

  list(Likelihood=likelihood, Messages=messages)
}



# Lower Level Getter functions: Not Currently used  #
# ------------------------------------------------- #

# #' Create a method to fetch the value of Likelihood Slot
# setGeneric(name="getLikelihood",
#            def=function(SOObject)
#            {
#               standardGeneric("getLikelihood")
#            }
# )
# setMethod(f="getLikelihood",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#           { 
#            Likelihood <- SOObject@Estimation@Likelihood

#           L = list()
#           if ("LogLikelihood" %in% names(Likelihood)) {
#             A = list(LogLikelihood=Likelihood[["LogLikelihood"]])
#             L <- c(L, A)
#           }
#           if ("Deviance" %in% names(Likelihood)) {
#             B <- list(Deviance=Likelihood[["Deviance"]]) 
#             L <- c(L, B)
#           }
#           if ("IndividualContribToLL" %in% names(Likelihood)) {
#             C <- list(IndividualContribToLL=Likelihood[["IndividualContribToLL"]][["data"]]) 
#             L <- c(L, C)
#           }          
#           if ("AIC" %in% names(Likelihood[["InformationCriteria"]])) {
#             D <- list(AIC=Likelihood[["InformationCriteria"]][["AIC"]])
#             L <- c(L, D)
#           }   
#           if ("BIC" %in% names(Likelihood[["InformationCriteria"]])) {
#             E <- list(BIC=Likelihood[["InformationCriteria"]][["BIC"]])
#             L <- c(L, E)
#           } 
#           if ("DIC" %in% names(Likelihood[["InformationCriteria"]])) {
#             F <- list(DIC=Likelihood[["InformationCriteria"]][["DIC"]])
#             L <- c(L, F)
#           }       
#            pprintList(L, "Likelihood")
#           }
# )



# #' Create a method to fetch the value of SoftwareMessages Slot
# setGeneric(name="getSoftwareMessages",
#                        def=function(SOObject)
#                        {
#                           standardGeneric("getSoftwareMessages")
#                        }
#                        )
# setMethod(f="getSoftwareMessages",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#           {                              
#            SoftwareMessages <- SOObject@TaskInformation
#            pprintList(SoftwareMessages, "Software Messages")
#           }
# )

# ================ #
# Getter Methods   #
# ================ #

# #' Create a method to fetch the value of ToolSetting Slot
# setGeneric(name="getToolSettings",
#            def=function(SOObject)
#            {
#                    standardGeneric("getToolSettings")
#            }
# )
# setMethod(f="getToolSettings",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#           {                              
#             ToolSettings <- SOObject@ToolSettings
#             pprintList(ToolSettings, title="Tool Settings")
#           }
# )


# #' Create a method to fetch the value of RawResults Slot
# setGeneric(name="getRawResults",
#            def=function(SOObject)
#            {
#                    standardGeneric("getRawResults")
#            }
# )
# setMethod(f="getRawResults",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#           {                              
#             DataFiles <- SOObject@RawResults@DataFiles
#             GraphicsFiles <- SOObject@RawResults@GraphicsFiles

#             L = c(DataFiles, GraphicsFiles)
#             pprintList(L, title="Raw Result Files")  
#           }
# )


# #' Create a method to fetch the value of PopulationEstimates Slot
# setGeneric(name="getPopulationEstimates",
#            def=function(SOObject)
#            {
#               standardGeneric("getPopulationEstimates")
#            }
# )
# setMethod(f="getPopulationEstimates",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#           {     
#           PopulationEstimates <- SOObject@Estimation@PopulationEstimates
          
#           L = list()
#           if ("MLE" %in% names(PopulationEstimates)) {
#             L[["MLE"]] <- PopulationEstimates[["MLE"]]
#           } 
#           if ("Bayesian" %in% names(PopulationEstimates)) {
#             B <- PopulationEstimates[["Bayesian"]]
#             names(B) <- paste0('Bayes:', names(B))
#             L <- c(L, B)
#           }

#           # Pretty print a list of data table elements 
#           pprintDefTable(L, title="Population Estimates")
#           }
# )


# #' Create a method to fetch the value of PrecisionPopulationEstimates Slot
# setGeneric(name="getPrecisionPopulationEstimates",
#            def=function(SOObject)
#            {
#               standardGeneric("getPrecisionPopulationEstimates")
#            }
# )
# setMethod(f="getPrecisionPopulationEstimates",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#           {                              
#           PrecisionPopulationEstimates <- SOObject@Estimation@PrecisionPopulationEstimates
          
#           L = list()
#           if ("MLE" %in% names(PrecisionPopulationEstimates)) {
#             A = PrecisionPopulationEstimates[["MLE"]]
#             names(A) <- paste0('MLE:', names(A))
#             L <- c(L, A)
#           } 
#           if ("Bayesian" %in% names(PrecisionPopulationEstimates)) {
#             B <- PrecisionPopulationEstimates[["Bayesian"]]
#             names(B) <- paste0('Bayes:', names(B))
#             L <- c(L, B)
#           }
#           if ("Bootstrap" %in% names(PrecisionPopulationEstimates)) {
#             C <- PrecisionPopulationEstimates[["Bayesian"]]
#             names(C) <- paste0('Bootstrap:', names(C))
#             L <- c(L, C)
#           }

#           # Pretty print a list of data table elements 
#           pprintDefTable(L, title="Precision Population Estimates")
#           }
# )


# #' Create a method to fetch the value of IndividualEstimates Slot
# setGeneric(name="getIndividualEstimates",
#            def=function(SOObject)
#            {
#               standardGeneric("getIndividualEstimates")
#            }
# )
# setMethod(f="getIndividualEstimates",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#       {  
#           IndividualEstimates <- SOObject@Estimation@IndividualEstimates
        
#           L = list()
#           if ("EtaShrinkage" %in% names(IndividualEstimates)) {
#             A = IndividualEstimates[["EtaShrinkage"]]
#             L <- c(L, A)
#           } 
#           if ("RandomEffects" %in% names(IndividualEstimates)) {
#             B <- IndividualEstimates[["RandomEffects"]]
#             names(B) <- paste0('RandomEffects:', names(B))
#             L <- c(L, B)
#           }
#           if ("Estimates" %in% names(IndividualEstimates)) {
#             C <- IndividualEstimates[["Estimates"]]
#             names(C) <- paste0('Estimates:', names(C))
#             L <- c(L, C)
#           }

#           # Pretty print a list of data table elements
#           pprintDefTable(L, "Individual Estimates")
#       }                              
# )


# #' Create a method to fetch the value of PrecisionIndividualEstimates Slot
# setGeneric(name="getPrecisionIndividualEstimates",
#            def=function(SOObject)
#            {
#               standardGeneric("getPrecisionIndividualEstimates")
#            }
# )
# setMethod(f="getPrecisionIndividualEstimates",
#                       signature="StandardOutputObject",
#                       definition=function(SOObject)
#    {                          
#       PrecisionIndividualEstimates <- SOObject@Estimation@PrecisionIndividualEstimates
#       pprintList(PrecisionIndividualEstimates, "Precision Individual Estimates")
#    }                                                     
# )


# #' Create a method to fetch the value of Residuals Slot
# setGeneric(name="getResiduals",
#            def=function(SOObject)
#            {
#               standardGeneric("getResiduals")
#            }
# )
# setMethod(f="getResiduals",
#                       signature="StandardOutputObject",
#                       definition=function(SOObject)
#     {
#           Residuals <- SOObject@Estimation@Residuals

#           L = list()
#           if ("EpsShrinkage" %in% names(Residuals)) {
#             A = Residuals[["EpsShrinkage"]]
#             L <- c(L, A)
#           } 
#           if ("ResidualTable" %in% names(Residuals)) {
#             B <- Residuals[["ResidualTable"]]
#             L <- c(L, B)
#           }

#           # Pretty print a list of data table elements
#           pprintDefTable(L, "Residuals")
#     }
# )


# #' Create a method to fetch the value of Predictions Slot
# setGeneric(name="getPredictions",
#            def=function(SOObject)
#            {
#               standardGeneric("getPredictions")
#            }
# )
# setMethod(f="getPredictions",
#           signature="StandardOutputObject",
#           definition=function(SOObject)
#          {
#            Predictions <- SOObject@Estimation@Predictions
#            pprintDefTable(Predictions, "Predictions")
#          }                              
# )








# #' Create a method to fetch the value of Simulation : SimulationBlock(s) : SimulatedProfiles slot
# setGeneric(name="getSimulatedProfiles",
# 		def=function(SOObject)
# 		{
# 			standardGeneric("getSimulatedProfiles")
# 		}
# )
# setMethod(f="getSimulatedProfiles",
# 		signature="StandardOutputObject",
# 		definition=function(SOObject)
# 		{
# 			simulationBlocks <- SOObject@Simulation@SimulationBlock
			
# 			SimulatedProfiles <- lapply(simulationBlocks, function(n) { n@SimulatedProfiles })
# 			names(SimulatedProfiles) <- rep("SimulatedProfiles", length(SimulatedProfiles))  # the names of the elements in the named list are incorrect after the lapply()
			
# 			pprintList(SimulatedProfiles, "Simulation : Simulation Block(s) : Simulated Profiles")
# 		}                                                     
# )


# #' Create a method to fetch the value of Simulation : SimulationBlock(s) : IndivParameters slot
# setGeneric(name="getSimulationIndividualParameters",
# 		def=function(SOObject)
# 		{
# 			standardGeneric("getSimulationIndividualParameters")
# 		}
# )
# setMethod(f="getSimulationIndividualParameters",
# 		signature="StandardOutputObject",
# 		definition=function(SOObject)
# 		{
# 			simulationBlocks <- SOObject@Simulation@SimulationBlock
			
# 			IndivParameters <- lapply(simulationBlocks, function(n) { n@IndivParameters })
# 			names(IndivParameters) <- rep("IndivParameters", length(IndivParameters))  # the names of the elements in the named list are incorrect after the lapply()
			
# 			pprintList(IndivParameters, "Simulation : Simulation Block(s) : Individual Parameters")
# 		}
# )


# #' Create a method to fetch the value of Simulation : SimulationBlock(s) : PopulationParameters slot
# setGeneric(name="getSimulationPopulationParameters",
# 		def=function(SOObject)
# 		{
# 			standardGeneric("getSimulationPopulationParameters")
# 		}
# )
# setMethod(f="getSimulationPopulationParameters",
# 		signature="StandardOutputObject",
# 		definition=function(SOObject)
# 		{
# 			simulationBlocks <- SOObject@Simulation@SimulationBlock
			
# 			PopulationParameters <- lapply(simulationBlocks, function(n) { n@PopulationParameters })
# 			names(PopulationParameters) <- rep("PopulationParameters", length(PopulationParameters))  # the names of the elements in the named list are incorrect after the lapply()
			
# 			pprintList(PopulationParameters, "Simulation : Simulation Block(s) : Population Parameters")
# 		}
# )


# #' Create a method to fetch the value of Simulation : SimulationBlock(s) : RawResultsFile slot
# setGeneric(name="getSimulationRawResultsFiles",
# 		def=function(SOObject)
# 		{
# 			standardGeneric("getSimulationRawResultsFiles")
# 		}
# )
# setMethod(f="getSimulationRawResultsFiles",
# 		signature="StandardOutputObject",
# 		definition=function(SOObject)
# 		{
# 			simulationBlocks <- SOObject@Simulation@SimulationBlock
			
# 			RawResultsFiles <- lapply(simulationBlocks, function(n) { n@RawResultsFile })
# 			names(RawResultsFiles) <- rep('RawResultsFile', length(RawResultsFiles))  # the names of the elements in the named list are incorrect after the lapply()
			
# 			pprintList(RawResultsFiles, "Simulation : Simulation Block(s) : Raw Results File")
# 		}
# )


# #' Create a method to fetch the value of Simulation : OriginalDataSet slot
# setGeneric(name="getSimulationOriginalDataset",
# 		def=function(SOObject)
# 		{
# 			standardGeneric("getSimulationOriginalDataset")
# 		}
# )
# setMethod(f="getSimulationOriginalDataset",
# 		signature="StandardOutputObject",
# 		definition=function(SOObject)
# 		{
# 			OriginalDataset <- SOObject@Simulation@OriginalDataset
			
# 			pprintList(OriginalDataset, "Simulation : Original Data Set")
# 		}
# )