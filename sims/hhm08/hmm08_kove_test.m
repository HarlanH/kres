function hmm08_kove_test
% HHM08_KOVE_TEST Try a few KOVE models on the Hoffman et al. (2008) task.

path('../..', path)

config = kove_d(0); % no knowledge
config.lambdaW = .1;
config.c = .42;
config.phi = .72;

trainErrs = hhm08_kove_run(config, 1);

disp('KOVE/D:');
disp(trainErrs);
disp(sum(trainErrs,2));

config = kove_d(.5); % knowledge
config.lambdaW = .1;
config.c = .42;
config.phi = .72;

trainErrs = hhm08_kove_run(config, 1);

disp('w/ knowledge');
disp(trainErrs);
disp(sum(trainErrs,2));

