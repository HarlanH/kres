# just one plot

library("ggplot2")

# load data
act <- read.csv("test.csv", sep="\t")
act2 <- melt(act, id="Input")
# add columns for 0/1 and A-E
act2$Dimension <- substr(act2$variable,1,1)
act2$Bank <- substr(act2$variable,2,2)

theme_set(theme_bw(base_size=14)) 

p <- ggplot(act2, aes(Dimension, value, group=Input)) + facet_grid(. ~ Bank)
p <- p + geom_line(aes(linetype=Input, color=Input), size=2)
p <- p + scale_linetype_manual(values=c(2,2,1))
p <- p + scale_colour_manual(values = c("red","black", "black"))
p <- p + geom_point(size=4)
p <- p + scale_y_continuous("Activation", limits=c(0,1), breaks=(0:4)/4)
p <- p + geom_hline(aes(yintercept=c(.32,.68)), linetype=2)
p <- p + opts(legend.key.size =   unit(2.5, "lines"))
p

ggsave("hhm08-testing.pdf", dpi=72)

p.acc <- ggplot(acc, aes(Block, SSE)) + geom_jitter(position=position_jitter(width=.2,height=0)) 
p.acc <- p.acc + stat_summary(fun.y=mean, geom="line", size=1.5)
p.acc <- p.acc + scale_x_continuous(limits=c(.5,4.5), breaks=1:4)
p.acc <- p.acc + scale_y_continuous(limits=c(0,.6), breaks=c(0,.2,.4,.6))
#p.acc

# now the weights plot
wts <- read.csv("train_wt.csv", sep="\t")
wts$ASSE <- NULL # drop this, unneeded
wts2 <- melt(wts, id="Block")
# add columns for 0/1 and X/Y
wts2$InputBank <- 1
wts2$OutputNode <- "O"
wts2$InputBank[grep(0,wts2$variable)]=0
wts2$InputBank[grep(1,wts2$variable)]=1
wts2$OutputNode[grep("X",wts2$variable)]="X"
wts2$OutputNode[grep("Y",wts2$variable)]="Y"

wts0 <- data.frame(x = .8, xend=.8, y=-.2, yend=.2)
p.wts <- ggplot(wts2, aes(Block, value, group=variable)) + geom_line(size=1.5) #stat_summary(fun.y=mean, geom="line", size=2)
p.wts <- p.wts + facet_grid(InputBank ~ OutputNode)
p.wts <- p.wts + geom_segment(data=wts0, aes(x=x, y=y, yend=yend, xend=xend, group=NULL), size=2, color="grey")
p.wts <- p.wts + scale_x_continuous(breaks=1:4)
p.wts <- p.wts + scale_y_continuous("Weight", breaks=c(0,.5,1))
#p.wts

# and now the activation plot
act <- read.csv("train_act.csv", sep="\t")
act2 <- melt(act, id="Block")

p.act <- ggplot(act2, aes(Block, value)) 
p.act <- p.act + geom_line(aes(group=variable), size=1.5)
p.act <- p.act + scale_x_continuous(limits=c(1,4.9), breaks=1:4)
p.act <- p.act + scale_y_continuous("Activation")
act.labels <- data.frame(x=4.5, y=c(.75,.56,.23,.09), l=c("B1-E1","A0","A1","B0-E0"))
p.act <- p.act + geom_text(aes(x=x, y=y, label=l), size=4, data=act.labels)
#p.act

# now, plot them all together!
pdf("training.pdf", width = 10, height = 3)
grid.newpage()
pushViewport(viewport(layout = grid.layout(1, 3)))
vplayout <- function(x, y)
  viewport(layout.pos.row = x, layout.pos.col = y)
print(p.acc, vp = vplayout(1, 1))
print(p.wts, vp = vplayout(1, 2))
print(p.act, vp = vplayout(1, 3))
dev.off()

