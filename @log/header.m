function header( L, DS, K )
%HEADER Output the header.
%   Output the header to this log object's file, using the specified
%   objects as necessary to figure out how many of various things there
%   are.
%   Just to make things predictable, header columns are in *alphabetical*
%   order. (With "line" always first.)

first = 1;

% line (always first)
comma();
fprintf(L.fid, 'line');

% ACoherence
if L.bACoherence,
    comma();
    fprintf(L.fid, 'ACoherence');
end
    
% Activations -- tricky one! needs list of nodes
if L.bActivations,
    n = getNodes(K);
    for i = 1:length(n),
        comma();
        fprintf(L.fid, 'Activations(%s)', n{i});
    end
end

% ASSE
if L.bASSE,
    comma();
    fprintf(L.fid, 'ASSE');
end

% Coherence
if L.bCoherence,
    comma();
    fprintf(L.fid, 'Coherence');
end

% DW
if L.bDW,
    comma();
    fprintf(L.fid, 'DW');
end

% Epoch
if L.iEpoch > 0,
    comma();
    fprintf(L.fid, 'Epoch');
end

% Input -- tricky one! needs input variables
if L.bInput,
    % loop over all input/output nodes in the dataset
    h = getHeader(DS);
    %m = getTargetmask(DS);
    for i = 1:length(h),
        %if m(i) == 0,   % NOT a target
            comma();
            fprintf(L.fid, 'Input(%s)', char(h(i)));
        %end
    end
end

% Outputs -- tricky one! needs output variables
if L.bOutputs,
    % loop over all output variables in the dataset
    h = getHeader(DS);
    m = getTargetmask(DS);
    for i = 1:length(h),
        if m(i) == 1,   % IS a target
            comma();
            fprintf(L.fid, 'Output(%s)', char(h(i)));
        end
    end
end

% SettleTime
if L.bSettleTime,
    comma();
    fprintf(L.fid, 'SettleTime');
end

% SSE
if L.bSSE,
    comma();
    fprintf(L.fid, 'SSE');
end

% Weights -- tricky one! needs connections
if L.bWeights,
    c = getCons(K);
    for i = 1:length(c),
        comma();
        fprintf(L.fid, 'Weights(%s-%s)', c(i).from, c(i).to);
    end
end

% done!
fprintf(L.fid, '\n');




    function comma
        if first,
            first = 0;
        else
            fprintf(L.fid, ', ');
        end
    end

end
