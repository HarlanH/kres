function [trainErrs, testErrs, trainAccs, k] = hhm08_kove_run(config, reps)
% KOVE_RUN Run the specified KOVE model (which either has knowledge or it
% doesn't) on the HHM08 5-D stimuli. 

% load datasets. We can use Kdataset, but have to be careful. These CSV
% files have 20 features, not 10, so use 1:5 only (6:10 for 10-D case, and
% the rest for the paired nodes not use here). 
trainset = Kdataset('hhm08_training.csv');
testset = Kdataset('hhm08_testing.csv');

% make checking for batch mode faster
if (~isfield(config, 'batch')),
    config.batch = false;
end

ctTrainItems = getLength(trainset);
ctTestItems = getLength(testset);
% ctUsedDims = 5;

trainErrs = zeros(reps, ctTrainItems);
trainAccs = zeros(reps, ctTrainItems*4);
testErrs = zeros(reps, ctTestItems);


% set up training stimuli, run repeatedly, storing
% various things. then run tests. 

% loop over replications
for rep = 1:reps,
    % create network
    k = kove(config);

    % always 4 training blocks
    for block = 1:4,
        % could use Kdataset's randomize function, but then would lose
        % useful per-item information. Instead, use a separate order array.
        %trainset = randomize(trainset);
        trialOrder = randperm(ctTrainItems);
        
        % foreach trial
        for trial = 1:ctTrainItems,
            [in, targ] = getExample(trainset, trialOrder(trial));
            % have to trim in and targ, since KOVE's train doesn't want the
            % unused dimensions, unlike KRES's train. Also,
            % category is coded as 1/-1, so change -1 to 2.
            in = in(1:5);
            % in = (in+1)/2;
            targ = targ(length(targ)-1);
            if (targ==-1), targ=2; end
            
            % train
            [k, P, E] = train(k, in, targ);
            PCR = P(targ); % prob correct response


            % store per-item error rate
            trainErrs(rep, trialOrder(trial)) = trainErrs(rep, trialOrder(trial)) + (1-PCR);
            % store per-trial accuracy
            trainAccs(rep, trial + ctTrainItems*(block-1)) = PCR;

        end

        if (config.batch),
            k = updateWeights(k);
        end

    end
    
    % now do test set
    for trial = 1:ctTestItems,
        % do these in order
        [in, targ] = getExample(testset, trial);
        
        % same trimming, etc.
        in = in(1:5);
        %in = (in+1)/2;
        targ = targ(length(targ)-1);
        if (targ==-1), targ=2; end

        % test
        [k, P, E] = test(k, in, targ);
        PCR = P(targ); % prob correct response

        % store per-item error rate
        testErrs(rep, trial) = testErrs(reps, trial) + (1-PCR);
    end
    
end

% trainErrs = trainErrs ./ reps;
% testErrs = testErrs ./ reps;

% no testing
end
