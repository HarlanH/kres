function L = doLog( K, L )
%DOLOG Write a log entry to the log file.
%   NB: returns a new *log*, not a new *KOVE*!

% this method is similar in many ways to log.header...

first = 1;
fid = getFID(L);

% line (always first)
%if first, first = 0; else fprintf(fid, ', '); end %comma();
[tick, L] = tickCounter(L);
fprintf(fid, '%d', tick);

% get node counts
numFeats = getNumFeats(K);
numDims = getNumDims(K);
maxHid = getMaxHid(L);  % maxHid is a property of log  object
numOut = getNumOut(K);

% Activations
% aIn, aHid (up to maxHid), and aOut
if getActivations(L),
%     for i = 1:numFeats,
%         comma();
%         fprintf(fid, '%0.5f', K.aIn(i));
%     end
    aHid = K.aHid;  % for speed
    lenAHid = length(aHid);
    aOut = K.aOut;
    for i = 1:maxHid,
        %fprintf(fid, ', '); %comma();
        if i <= lenAHid,
            fprintf(fid, ', %0.5f', aHid(i));
        else
            fprintf(fid, ', 0');
        end
    end
    for i = 1:numOut,
        %fprintf(fid, ', '); %comma();
        fprintf(fid, ', %0.5f', aOut(i));
    end
end

% Alpha
% numDims
if getAlpha(L),
    for i = 1:numDims,
        %fprintf(fid, ', '); %comma();
        fprintf(fid, ', %0.5f', K.alpha(i));
    end
end

% ASSE
if getASSE(L),
    %fprintf(fid, ', '); %comma();
    fprintf(fid, ', %0.5f', K.log.ASSE);
end

% Epoch
if getEpoch(L) > 0,
    %fprintf(fid, ', '); %comma();
    fprintf(fid, ', %d', ceil(tick / getEpoch(L)));
end

% H
% numInput X numHidden
if getH(L),
    lenAHid = length(K.aHid);   % speed!
    h = K.h;
    for i = 1:numFeats,
        for j = 1:maxHid,
            %fprintf(fid, ', '); %comma();
            if j <= lenAHid,
                fprintf(fid, ', %0.5f', h(j,i));
            else
                fprintf(fid, ', 0');
            end
        end
    end
end

% Input
% numFeats
if getInput(L),
    input = K.log.input;
    for i = 1:numFeats,
        %fprintf(fid, ', '); %comma();
        fprintf(fid, ', %0.5f', input(i));
    end
end

% PrK
% numOut
if getPrK(L),
    PrK = K.PrK;
    for i = 1:numOut,
        %fprintf(fid, ', '); %comma();
        fprintf(fid, ', %0.5f', PrK(i));
    end
end

% SSE
if getSSE(L),
    %fprintf(fid, ', '); %comma();
    fprintf(fid, ', %0.5f', K.log.SSE);
end

% Target
if getTarget(L),
    %fprintf(fid, ', '); %comma();
    fprintf(fid, ', %d', K.log.target);
end

% W
% numHidden * numOut
if getW(L),
    lenAHid = length(K.aHid);
    w = K.w;
    for i = 1:maxHid,
        for j = 1:numOut,
            %fprintf(fid, ', '); %comma();
            if i <= lenAHid,
                fprintf(fid, ', %0.5f', w(i,j));
            else
                fprintf(fid, ', 0');
            end
        end
    end
end



% done!
fprintf(fid, '\n');

% 
%     function comma
%         if first, first = 0; else fprintf(fid, ', '); end
%     end

end
