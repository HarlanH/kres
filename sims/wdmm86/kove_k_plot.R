library("ggplot2")
library("reshape")

d <- read.csv("kove_survey_k.dat", sep="\t")

d2 <- melt(d, id=c("Model", "p"))

# we want EI and ED, in that order
d2 <- subset(d2, d2$Model %in% c("EI", "ED"))
d2$Model = factor(d2$Model, levels=c("EI","ED"))

U <- data.frame(p = c(0, 0), value = c(53.9, 49.6), variable=c("LS", "NLS"))
K <- data.frame(p = c(0, 0), value = c(29.4, 40.6), variable=c("LS", "NLS"))

theme_set(theme_bw())
p <- qplot(p, value, data=d2, colour=variable, geom="line") + facet_grid(. ~ Model, scales="free_x")
p <- p + xlab("Knowledge Parameter") + scale_y_continuous("Training Errors", limits=c(5,70))
p <- p + geom_point(data=U, size=3) 
p <- p + geom_hline(data=K, aes(yintercept=value, color=variable), size=2)
p <- p + geom_hline(aes(yintercept=64), color="black", linetype=2, size=.5)
p <- p + scale_colour_manual("Structure", values = c("black","grey70")) 
p <- p + opts(title = "KOVE Model", plot.title = theme_text(size=12) )
p

ggsave("kove_survey_k.pdf", dpi=72)

