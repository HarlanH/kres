function [uTrainAcc, kTrainAcc] = hhm08_kove_test
% HHM08_KOVE_TEST Try a few KOVE models on the Hoffman et al. (2008) task.

path('../..', path)

reps = 25;

config = kove_d(0); % no knowledge
config.lambdaW = .05;
config.c = 1;
config.phi = 1.25;

[trainErrs, testErrs, uTrainAcc, k] = hhm08_kove_run(config, reps);

disp('KOVE/PD (wD = 0)');
dispResults();

wD = .3;
config = kove_d(wD); % knowledge
config.lambdaW = .05;
config.c = 1;
config.phi = 1.25;

[trainErrs, testErrs, kTrainAcc, k] = hhm08_kove_run(config, reps);

fprintf(1, '\n\n');
disp(['KOVE/PD (wD = ' num2str(wD) ')']);
dispResults();

function dispResults
    disp('Per-item training errors:');
    fprintf(1, '%0.2f ', mean(trainErrs));
    fprintf(1, '\n');
    disp('Total training errors:');
    disp(mean(sum(trainErrs,2)));
    disp('Test mean accuracy:');
    % Proto = 1:5, 11:15; WI = 6:10, 16:20; SF = 21:25; 31:35
    testAcc = 1 - testErrs;
    fprintf(1, 'P: %0.2f\tWI: %0.2f\tSF: %0.2f\n', mean(mean(testAcc(:,[1:5 11:15]))), ...
        mean(mean(testAcc(:, [6:10 16:20]))), ...
        mean(mean(testAcc(:, [21:25 31:35]))));
    disp('Final weights (1 model, features->1 output):');
    w = getWeights(k);
    w = w(1:5);
    fprintf(1, '%0.3f ', w);
    fprintf(1, '\n');
    fprintf(1, 'M = %0.3f (SD=%0.3f)\n', mean(abs(w)), std(abs(w))); 
end
end

