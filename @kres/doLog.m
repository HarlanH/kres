function L = doLog( K, L )
%DOLOG Write a log entry to the log file.

% this method is similar in many ways to log.header...

first = 1;
fid = getFID(L);

% line (always first)
comma();
[tick, L] = tickCounter(L);
fprintf(fid, '%d', tick);

% ACoherence
if getACoherence(L),
    comma();
    fprintf(fid, '%0.5f', K.log.ACoherence);
end
    
% Activations -- tricky one! 
if getActivations(L),
    for i = 1:length(K.minusAct), 
        comma();
        fprintf(fid, '%0.5f', K.minusAct(i));
    end
end

% ASSE
if getASSE(L),
    comma();
    fprintf(fid, '%0.5f', K.log.ASSE);
end

% Coherence
if getCoherence(L),
    comma();
    fprintf(fid, '%0.5f', K.log.Coherence);
end

% DW
if getDW(L),
    comma();
    fprintf(fid, '%0.5f', K.log.DW);
end

if getEpoch(L) > 0,
    comma();
    fprintf(fid, '%d', ceil(tick / getEpoch(L)));
end

% Input -- tricky one! needs input variables
if getInput(L),
    % loop over all input/output in the dataset
    for i = 1:length(K.log.Input),
        comma();
        fprintf(fid, '%0.5f', K.log.Input(i));
    end
end

% Outputs -- tricky one! needs output variables
if getOutputs(L),
    % loop over all output variables in the dataset
    %h = getHeader(DS);
    %m = getTargetmask(DS);
    for i = 1:length(K.log.Outputs),
        %if m(i) == 1,   % IS a target
        comma();
        fprintf(fid, '%0.5f', K.log.Outputs(i));
        %end
    end
end

% SettleTime
if getSettleTime(L),
    comma();
    fprintf(fid, '%d', K.log.SettleTime);
end

% SSE
if getSSE(L),
    comma();
    fprintf(fid, '%0.5f', K.log.SSE);
end

% Weights -- tricky one! needs connections
if getWeights(L),
    c = getCons(K);
    for i = 1:length(c),
        comma();
        fprintf(fid, '%0.5f', K.w(getNodeIdx(K,c(i).from), getNodeIdx(K,c(i).to)));
    end
end

% done!
fprintf(fid, '\n');


    function comma
        if first,
            first = 0;
        else
            fprintf(fid, ', ');
        end
    end

end
