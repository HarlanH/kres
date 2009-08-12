function [ ret ] = hhm08_script(Xarch, Xdims, Xlr, Xalpha, Xinw, Xexw, Xrandw, Xreps)
%HHM08_SCRIPT Simulate a particular condition of the dimensionality effect
%experiments.

path('../..', path);

% everything is within subjects.

if (nargin >= 1),
    arch = Xarch;
else
    arch = '';
end

if (nargin >= 2),
    dimensions = Xdims;
else
    dimensions = 10;
end

% load appropriate network specs
if (arch == 'k'),
    if dimensions == 5,
        ns = hhm08_5k();
    elseif dimensions == 10,
        ns = hhm08_10k();
    else
        error('dimensions not supported, yo!');
    end
else
    if dimensions == 5,
        ns = hhm08_5();
    elseif dimensions == 10,
        ns = hhm08_10();
    else
        error('dimensions not supported, yo!');
    end
end

% set output directory
outdir = 'out/';

% set default parameters
lr = .1;
alpha = 1.5;
inw = -1;
exw = 1;
randw = .5;
    
% clear the output directory
delete([outdir '*.dat']);

if nargin == 8,
    replications = Xreps;
else
    replications = 1;
end

maxblocks = 4;

% use passed-in parameters if available
if (nargin >= 7),
    lr = Xlr;
    alpha = Xalpha;
    inw = Xinw;
    exw = Xexw;
    randw = Xrandw;
end

% set up parameters
p = params;
p = setGain(p, 4);
p = setErrorCriterion(p, 0);    % never break early -- error counts won't be affected

% these are user-set
p = setLearningRate(p, lr);
p = setAlpha(p, alpha);
p = setInWeight(p, inw); 
p = setExWeight(p, exw);        
p = setRandWeight(p, randw);

% load datasets
trainset = Kdataset('hhm08_training.csv');
testset = Kdataset('hhm08_testing.csv');

% don't adjust the biases for this simulation
        
%trainblocks = zeros(replications,length(ns));

% loop over replications
for rep = 1:replications,
    % create network
    k = kres(ns,p);
    d = trainset;

    % set up logging
    l_block = log([outdir 'log-train-block-' arch int2str(dimensions) '-' int2str(rep) '.dat']);
    l_block = setWeights(l_block, true);
    l_block = setASSE(l_block, true);
    header(l_block, d, k);
    l_trial = log([outdir 'log-train-trial-' arch int2str(dimensions) '-' int2str(rep) '.dat']);
    l_trial = setInput(l_trial, true);
    l_trial = setOutputs(l_trial, true);
    l_trial = setActivations(l_trial, true);
    l_trial = setSSE(l_trial, true);
    l_trial = setSettleTime(l_trial, true);
    l_trial = setEpoch(l_trial, getLength(d));
    header(l_trial, d, k);
    l_test = log([outdir 'log-test-trial-' arch int2str(dimensions) '-' int2str(rep) '.dat']);
    l_test = setInput(l_test, true);
    l_test = setOutputs(l_test, true);
    l_test = setActivations(l_test, true);
    l_test = setSSE(l_test, true);
    l_test = setSettleTime(l_test, true);
    l_test = setEpoch(l_test, getLength(testset));
    header(l_test, testset, k);

    % train blocks until SSE gets low enough (or 16 max)
    for block = 1:maxblocks,
        % for each block...

        % randomize the examples
        d = randomize(d);

        % for each example
        for ex = 1:getLength(d),
            % train
            [in, targ] = getExample(d, ex);
            k = train(k, in, targ, p);

            % log
            l_trial = doLog(k, l_trial);
        end

        % log
        l_block = doLog(k, l_block);

        k = resetASSE(k);


    end

    % test once, at the end

    % for each example
    for ex = 1:getLength(testset),
        % train
        [in, targ] = getExample(testset, ex);
        k = test(k, in, targ, p);

        % log
        l_test = doLog(k, l_test);
    end

    close(l_block);
    close(l_trial);
    close(l_test);

end

%disp('Learning curves:');
[status, res] = unix(['./hhm08_train_summary.pl ' outdir]);
trainres = sscanf(res, '%f');
%disp(trainres);
%disp(ret);
%disp('item acc          SF acc          item ST         SF ST           act dims learned');
[status, res] = unix(['./hhm08_test_summary.pl ' int2str(dimensions) ' ' outdir]);
%disp(ret);
testres = sscanf(res, '%f');
%disp(testres);

ret = [trainres([2 5 8 11]); testres([1 2 5])]';

% return the four learning curve numbers, then the 1st, 2nd, and 5th test
% numbers (item accuracy, single feature accuracy, and actual dimensions
% learned)


