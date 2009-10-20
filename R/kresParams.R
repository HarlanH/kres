# kresParams.R
# 
# Create a named list with default parameters.
#
# Author: Harlan
###############################################################################

kresParams <- function(learningRate = 0.15, inWeight = -1,
            exWeight = 1, randWeight = 0.1, errorCriterion = 0.10,
            gain = 4, exempCriterion = 0.0001, exempLearningRate = 1,
            alpha = 4, jolt = 1,gamma = 1) 
{
  list(learningRate=learningRate,
        inWeight=inWeight,
        exWeight=exWeight,
        randWeight=randWeight,
        errorCriterion=errorCriterion,
        gain=gain,
        exempCriterion=exempCriterion,
        exempLearningRate=exempLearningRate,
        alpha=alpha,
        jolt=jolt,
        gamma=gamma)
}

