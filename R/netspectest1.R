# Attempt to figure out how to define a KRES netspec in R. (From wdmm86_ei.m)
# 
# Author: Harlan
###############################################################################

NS <- list(nodes = list(I=list(I0=c('A0', 'B0', 'C0', 'D0'),
                               I1=c('A1', 'B1', 'C1', 'D1')),
                        P=c('P0', 'P1'),
                        E=c('E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8'),
                        O=c('X', 'Y')),
           cons = list(c(from='X', to='Y', type='fixed', spread='full', init='inh'),
                       c(from='I0', to='I1', type='fixed', spread='121', init='inh'),
                       c(from='P0', to='I0', type='fixed', spread='full', init='ex'),
                       c(from='P1', to='I1', type='fixed', spread='full', init='ex'),
                       c(from='P', to='O', type='chl', spread='full', init='rand'),
                       c(from='P0', to='P1', type='fixed', spread='full', init='in'),
                       c(from='I', to='E', type='exemp', spread='full', init=0),
                       c(from='E', to='O', type='exempchl', spread='full', init='rand'),
                       c(from='E', to='E', type='fixed', spread='full', init='in')),
           bias = list(c(node='E', value=-1),
                       c(node='P', value=-1),
                       c(node='O', value=-1)));

