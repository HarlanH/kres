function wdmm86_test
% WDMM86_TEST Test out the WDMM86_RUN script. We're going to want a KRES/E
% (exemplar nodes, no knowledge), a KRES/EI (prior knowledge nodes) and a 
% KRES/ED (lateral input weights)

path('../../', path);

% orderings (convert from binary sorted order to A1 sorted order)
orderLS = [8 5 7 3 6 1 2 4];
orderNLS = [5 6 8 4 2 3 7 1];

% empirical data (in A1 sorted order) @@@ use the averaged data instead
dataLSU = [5.9 6.2 5.7 4.6 7 6.2 5.5 7.5];
dataNLSU = [5.9 8.7 5.2 6 2.6 4.4 8.3 3.2];
dataLSK = [3.5 3 2.1 3.3 4.1 3.4 4.2 3.5];
dataNLSK = [6.4 3.9 3.5 4.8 3.1 4.5 7.6 3.6];

% KRES/E
ns = wdmm86_e();
p = params();
p = setLearningRate(p, .63);
p = setExempLearningRate(p, .81);
p = setErrorCriterion(p, 0); % never stop early
p = setAlpha(p, 1.24);
p = setInWeight(p, -1.43);
%p = setExWeight(p, 1); unused w/out knowledge

ns.bias(1).value = -2*log(8-1)/getAlpha(p); % over-ride exemplar unit bias, 
    % so that activation with no inputs is 1/n, where n is the number of 
    % input nodes.

% run the model
wdmm86_run(ns, p, 10);

% collect the data from log files

% linearly separable
cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-1-*.dat';
[stat res] = unix(cmdline);
errs = sscanf(res, '%f');
fprintf(1, 'E : ');
fprintf(1, '%0.2f ', errs(orderLS)); 
fprintf(1, '  %0.2f %0.2f    ', sum(errs), sum((errs(orderLS)' - dataLSU).^2)/length(dataLSU));

% nonlinearly separable
cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-2-*.dat';
[stat res] = unix(cmdline);
errs = sscanf(res, '%f');
fprintf(1, '%0.2f ', errs(orderNLS)); 
fprintf(1, '  %0.2f %0.2f    ', sum(errs), sum((errs(orderNLS)' - dataNLSU).^2)/length(dataNLSU));
fprintf(1, '\n');



% KRES/EI
ns = wdmm86_ei();
p = params();
p = setLearningRate(p, .63);
p = setExempLearningRate(p, .81);
p = setErrorCriterion(p, 0); % never stop early
p = setAlpha(p, 1.24);
p = setInWeight(p, -1.43);
p = setExWeight(p, 0.16);

ns.bias(1).value = -2*log(8-1)/getAlpha(p); % over-ride exemplar unit bias, 
    % so that activation with no inputs is 1/n, where n is the number of 
    % input nodes.

% run the model
wdmm86_run(ns, p, 10);

% collect the data from log files

% linearly separable
cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-1-*.dat';
[stat res] = unix(cmdline);
errs = sscanf(res, '%f');
fprintf(1, 'EI: ');
fprintf(1, '%0.2f ', errs(orderLS)); 
fprintf(1, '  %0.2f %0.2f    ', sum(errs), sum((errs(orderLS)' - dataLSK).^2)/length(dataLSK));

% nonlinearly separable
cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-2-*.dat';
[stat res] = unix(cmdline);
errs = sscanf(res, '%f');
fprintf(1, '%0.2f ', errs(orderNLS)); 
fprintf(1, '  %0.2f %0.2f    ', sum(errs), sum((errs(orderNLS)' - dataNLSK).^2)/length(dataNLSK));
fprintf(1, '\n');


% KRES/ED
ns = wdmm86_ed();
p = params();
p = setLearningRate(p, 1.49);
p = setExempLearningRate(p, .59);
p = setErrorCriterion(p, 0); % never stop early
p = setAlpha(p, 1.26);
p = setInWeight(p, -4.14);
p = setExWeight(p, .32);

ns.bias(1).value = -2*log(8-1)/getAlpha(p); % over-ride exemplar unit bias, 
    % so that activation with no inputs is 1/n, where n is the number of 
    % input nodes.

% run the model
wdmm86_run(ns, p, 10);

% collect the data from log files

% linearly separable
cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-1-*.dat';
[stat res] = unix(cmdline);
errs = sscanf(res, '%f');
fprintf(1, 'ED: ');
fprintf(1, '%0.2f ', errs(orderLS)); 
fprintf(1, '  %0.2f %0.2f    ', sum(errs), sum((errs(orderLS)' - dataLSK).^2)/length(dataLSK));

% nonlinearly separable
cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-2-*.dat';
[stat res] = unix(cmdline);
errs = sscanf(res, '%f');
fprintf(1, '%0.2f ', errs(orderNLS)); 
fprintf(1, '  %0.2f %0.2f    ', sum(errs), sum((errs(orderNLS)' - dataNLSK).^2)/length(dataNLSK));
fprintf(1, '\n');



end
