function kove_test
% KOVE_TEST Try a few KOVE models on the Wattenmaker et al. (1986) task.

path('../..', path);

% set up the network. lambdaW is learning rate, c is specificity, phi is
% exponent on output layer, and B is weighting on types of hidden nodes, as
% [feature copy, PK nodes, exemplars]. 

% KOVE/EI

config = kove_ei(0); % no knowledge
config.lambdaW = .03;
config.c = .75;
config.phi = 1.5;
%config.batch = true;

trainErrs = kove_run(config, 5);

disp('KOVE/EI:');
disp(trainErrs);
disp(sum(trainErrs,2));

config = kove_ei(7); % knowledge
config.lambdaW = .03;
config.c = .75;
config.phi = 1.5;

trainErrs = kove_run(config, 5);

disp('w/ knowledge');
disp(trainErrs);
disp(sum(trainErrs,2));


% % KOVE/ED
% 
% config = kove_ed(0); % no knowledge
% config.lambdaW = .1;
% config.c = .42;
% config.phi = .72;
% 
% trainErrs = kove_run(config, 1);
% 
% disp('KOVE/ED:');
% disp(trainErrs);
% disp(sum(trainErrs,2));
% 
% config = kove_ed(.5); % knowledge
% config.lambdaW = .1;
% config.c = .42;
% config.phi = .72;
% 
% trainErrs = kove_run(config, 1);
% 
% disp('w/ knowledge');
% disp(trainErrs);
% disp(sum(trainErrs,2));
% 
% 
% % KOVE/PD
% 
% config = kove_pd(0); % no knowledge
% config.lambdaW = .01;
% config.c = .25;
% config.phi = 2;
% 
% trainErrs = kove_run(config, 1);
% 
% disp('KOVE/PD:');
% disp(trainErrs);
% disp(sum(trainErrs,2));
% 
% config = kove_pd(.5); % knowledge
% config.lambdaW = .01;
% config.c = .25;
% config.phi = 2;
% 
% trainErrs = kove_run(config, 1);
% 
% disp('w/ knowledge');
% disp(trainErrs);
% disp(sum(trainErrs,2));
% 
% % KOVE/EW
% 
% config = kove_ew(0); % no knowledge
% config.lambdaW = .4;
% config.c = .5;
% config.phi = .75;
% 
% trainErrs = kove_run(config, 5);
% 
% disp('KOVE/EW:');
% disp(trainErrs);
% disp(sum(trainErrs,2));
% 
% config = kove_ew(.25); % knowledge
% config.lambdaW = .4;
% config.c = .5;
% config.phi = .75;
% 
% trainErrs = kove_run(config, 5);
% 
% disp('w/ knowledge');
% disp(trainErrs);
% disp(sum(trainErrs,2));


end