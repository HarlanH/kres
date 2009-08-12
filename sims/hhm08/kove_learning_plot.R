# 

library("ggplot2")
library("reshape")

# load the data
uaccW <- read.table("hhm08_kove_uacc.dat", sep="")
kaccW <- read.table("hhm08_kove_kacc.dat", sep="")

# pour it into the right form
acc <- melt(uaccW)
acc$trial <- as.integer(substring(acc$variable, 2))
acc$block <- ceiling(acc$trial / 20)
acc$condition <- "Unrelated"
kacc <- melt(kaccW)
kacc$trial <- as.integer(substring(kacc$variable, 2))
kacc$block <- ceiling(kacc$trial / 20)
kacc$condition <- "Knowledge"
acc <- rbind(acc, kacc)

# and plot it

theme_set(theme_bw(base_size=14)) 

p <- ggplot(acc, aes(trial, value))
p <- p + facet_grid(. ~ condition)
p <- p + geom_jitter(alpha=.1)
# + stat_summary(fun.data = "mean_cl_boot", geom="smooth", size=1.5)
p <- p + scale_y_continuous("Accuracy", breaks=(5:10)/10)
p <- p + scale_x_continuous("Trial", breaks=c(0,20,40,60,80))
p <- p + coord_cartesian(ylim=c(.45,1.01))
#p <- p + scale_color_hue("Condition")
p


