library("ggplot2")

d <- read.csv("kove_survey_k_plot.csv", sep="\t")

d2 <- melt(d, id=c("Model", "p"))

# put Models in the right order
d2$Model = factor(d2$Model, levels=c("EI","ED","EW"))

U <- data.frame(p = c(0, 0), value = c(53.9, 49.6), variable=c("LS", "NLS"))
K <- data.frame(p = c(0, 0), value = c(29.4, 40.6), variable=c("LS", "NLS"))

theme_set(theme_bw())
p <- qplot(p, value, data=d2, color=variable, geom="line") + facet_grid(. ~ Model, scales="free_x")
p <- p + xlab("Knowledge Parameter") + scale_y_continuous("Training Errors", limits=c(5,70))
p <- p + geom_point(data=U, size=3) 
p <- p + geom_hline(data=K, aes(yintercept=value, color=variable), size=2)
p <- p + geom_hline(aes(yintercept=64), color="black", linetype=2, size=.5)
p <- p + scale_colour_manual("Structure", values = c("black","grey70")) 
p <- p + opts(title = "KOVE Model", plot.title = theme_text(size=12) )
p

ggsave("kove_survey_k_plot.pdf", dpi=72)

