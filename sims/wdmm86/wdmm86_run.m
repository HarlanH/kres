function wdmm86_run( ns, p, reps )
% WDMM86_RUN Run the specified KRES model (which either has knowledge or it
% doesn't) on the LS and NLS stimuli, a specified number of times.

% two conditions:
% LS/NLS stimuli 

% load datasets
ds(1) = Kdataset('wdmm86_ls.csv');
ds(2) = Kdataset('wdmm86_nls.csv');

% wipe the output directory
delete('out/*.dat');

% loop over replications
for rep = 1:reps,
    for cond = 1:2,
        % create network
        k = kres(ns, p);
        d = ds(cond);
                
        % set up logging
        l_block = log(['out/log-train-block-' int2str(cond) '-' int2str(rep) '.dat']);
        l_block = setWeights(l_block, true);
        l_block = setASSE(l_block, true);
        header(l_block, d, k);
        l_trial = log(['out/log-train-trial-' int2str(cond) '-' int2str(rep) '.dat']);
        l_trial = setInput(l_trial, true);
        l_trial = setOutputs(l_trial, true);
        l_trial = setActivations(l_trial, true);
        l_trial = setSSE(l_trial, true);
        l_trial = setSettleTime(l_trial, true);
        l_trial = setEpoch(l_trial, getLength(d));
        header(l_trial, d, k);

        % always 16 training blocks
        for block = 1:16,
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
        
        close(l_block);
        close(l_trial);
    end
end

% no testing



