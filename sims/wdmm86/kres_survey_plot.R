library("ggplot2")

wdmm <- read.csv("kres_survey_plot.csv")

wdmm$Index <- 16:1 # add the correct order

w <- melt(wdmm, id=c("Label", "Index"))

w.dat <- subset(w, subset=variable %in% c("DataU", "DataK"))
w.mod <- subset(w, subset=variable %in% c("ModelU", "ModelK"))
w.datmod <- subset(w, subset=variable %in% c("DataU", "DataK", "ModelU", "ModelK"))

ggplot(w.datmod, aes(Index, value, color=variable[drop=T])) + geom_point(stat="identity", size=3) +
	#coord_flip() +
	scale_x_discrete(name="Item", breaks=1:3, labels=c("1", "2", "3")) + #as.vector(w.datmod$Label[1:16])) +
	scale_y_continuous(name="Errors", limits=c(0,10))


ggplot(wdmm, aes(Index, dataU)) + geom_point() + coord_flip()

