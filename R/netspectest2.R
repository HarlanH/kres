# simple network, two input nodes, one output node
# 
# Author: Harlan
###############################################################################

NS <- list(nodes = list(I=list(I0=c('A0', 'B0'),
            I1=c('A1', 'B1')),
        O=c('X', 'Y')),
    cons = list(c(from='X', to='Y', type='fixed', spread='full', init='inh'),
        c(from='I0', to='I1', type='fixed', spread='121', init='inh'),
        c(from='I0', to='X', type='fixed', spread='full', init='exh'),
        c(from='I1', to='Y', type='fixed', spread='full', init='exh')),
    bias = list(c(node='O', value=-1)));

p <- kresParams()
k <- new("kres", NS, p)

Xin <- c(1, 1, 0, 0, 0, 0) # one per node
Xout <- c(1, 0);

print(test(k, Xin, Xout, p))

