function kove_survey_k
% KOVE_SURVEY_K Given fixed parameters for lr, c, and phi, survey the prior
% knowledge parameter for each of the KOVE models. Output goes to a file.

path('../..', path);

% best for distorted (non-veridical) exemplars
%lr = .03;
%c = .75;
%phi = 1.5;
% best found for veridical exemplars
lr = .0264;
c = .5517;
phi = 1.621;

reps = 5;

outfilename = 'kove_survey_k.dat';

outfile = fopen(outfilename, 'w');

% header
fprintf(outfile, 'Model\tp\tLS\tNLS\n');

for wK = 0:.5:25,
    config = kove_ei(wK);
    config.lambdaW = lr;
    config.c = c;
    config.phi = phi;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(outfile, 'EI\t%0.3f\t%0.3f\t%0.3f\n', wK, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

for wD = 0:.02:1,
    config = kove_ed(wD);
    config.lambdaW = lr;
    config.c = c;
    config.phi = phi;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(outfile, 'ED\t%0.3f\t%0.3f\t%0.3f\n', wD, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

for wD = 0:.02:1,
    config = kove_pd(wD);
    config.lambdaW = .04;
    config.c = .75;
    config.phi = 3;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(outfile, 'PD\t%0.3f\t%0.3f\t%0.3f\n', wD, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

for wW = -5:.5:20,
    config = kove_ew(wW);
    config.lambdaW = lr;
    config.c = c;
    config.phi = phi;
    
    trainErrs = kove_run(config, reps);
    
    fprintf(outfile, 'EW\t%0.3f\t%0.3f\t%0.3f\n', wW, sum(trainErrs(1,:)), sum(trainErrs(2,:)));
end

	fclose(outfile);
end
