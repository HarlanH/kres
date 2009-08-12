function kove_survey_k
% KOVE_SURVEY_K Given fixed parameters for lr, c, and phi, survey the prior
% knowledge parameter for each of the KOVE models.

path('../..', path);

lr = .03;
c = .75;
phi = 1.5;

reps = 5;

for wK = 0:1:50,
    config = kove_ei(wK);
    config.lambdaW = lr;
    config.c = c;
    config.phi = phi;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(1, 'EI %0.2f %0.2f %0.2f\n', wK, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

for wD = 0:.02:1,
    config = kove_ed(wD);
    config.lambdaW = lr;
    config.c = c;
    config.phi = phi;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(1, 'ED %0.2f %0.2f %0.2f\n', wD, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

for wD = 0:.02:1,
    config = kove_pd(wD);
    config.lambdaW = .04;
    config.c = .75;
    config.phi = 3;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(1, 'PD %0.2f %0.2f %0.2f\n', wD, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

for wW = -5:.5:20,
    config = kove_ew(wW);
    config.lambdaW = lr;
    config.c = c;
    config.phi = phi;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(1, 'EW %0.2f %0.2f %0.2f\n', wW, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

end
