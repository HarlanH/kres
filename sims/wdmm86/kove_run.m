function trainErrs = kove_run(config, reps)
% KOVE_RUN Run the specified KOVE model (which either has knowledge or it
% doesn't) on the LS and NLS stimuli, a specified number of times. Return
% ???

% two conditions:
% LS/NLS stimuli 

% load datasets (checking for bias)
[stims(1,:,:), targs(1,:)] = kove_stim(0);   % LS training data
[stims(2,:,:), targs(2,:)] = kove_stim(1);   % NLS training data

% make checking for batch mode faster
if (~isfield(config, 'batch')),
    config.batch = false;
end

% % wipe the output directory
% delete('out/*.dat');

trainErrs = zeros(2, length(targs(1,:)));

% loop over conditions/replications
for cond = 1:2,
    stim = squeeze(stims(cond,:,:)); % get rid of the extra dimension...
    targ = targs(cond,:,:);
        
% %     if we have 5 dims instead of 4, add bias
%     if config.numFeats == 5,
%         stim = [stim -1*ones(8,1)];
%     end

    for rep = 1:reps,
        % create network
        k = kove(config);

        % always 16 training blocks
        for block = 1:16,
            % randomize the trials
            ordering = randperm(size(targ,2));
            
            % foreach trial
            for trial = 1:length(ordering),
                % train
                [k, P, E] = train(k, stim(ordering(trial),:), targ(ordering(trial)));
                PCR = P(targ(ordering(trial))); % prob correct response


                % store per-item error rate
                trainErrs(cond, ordering(trial)) = trainErrs(cond, ordering(trial)) + (1-PCR);

            end
            
            if (config.batch),
                k = updateWeights(k);
            end

        end
        
    end
end

trainErrs = trainErrs ./ reps;

% no testing
end
