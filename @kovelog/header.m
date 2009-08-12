function header( L, K )
%HEADER Output the header.
%   Output the header to this log object's file, using the specified
%   objects as necessary to figure out how many of various things there
%   are.
%   Just to make things predictable, header columns are in *alphabetical*
%   order. (With "line" always first.)

first = 1;

% line (always first)
fprintf(L.fid, 'line');

% get node counts
numFeats = getNumFeats(K);
numDims = getNumDims(K);
% maxHid is a property of this object
numOut = getNumOut(K);

% Activations
% aIn, aHid (up to maxHid), and aOut
if L.bActivations,
%     for i = 1:numFeats,
%         %comma();
%         fprintf(L.fid, 'ActIn(%d)', i);
%     end
    for i = 1:L.maxHid,
        %comma();
        fprintf(L.fid, ', ActHid(%d)', i);
    end
    for i = 1:numOut,
        %comma();
        fprintf(L.fid, ', ActOut(%d)', i);
    end
end

% Alpha
% numDims
if L.bAlpha,
    for i = 1:numDims,
        %comma();
        fprintf(L.fid, ', Alpha(%d)', i);
    end
end

% ASSE
if L.bASSE,
    %comma();
    fprintf(L.fid, ', ASSE');
end

% Epoch
if L.iEpoch,
    %comma();
    fprintf(L.fid, ', Epoch');
end

% H
% numInput X numHidden
if L.bH,
    for i = 1:numFeats,
        for j = 1:L.maxHid,
            %comma();
            fprintf(L.fid, ', H(%d-%d)', i, j);
        end
    end
end

% Input
% numFeats
if L.bInput,
    for i = 1:numFeats,
        %comma();
        fprintf(L.fid, ', Input(%d)', i);
    end
end

% PrK
% numOut
if L.bPrK,
    for i = 1:numOut,
        %comma();
        fprintf(L.fid, ', PrK(%d)', i);
    end
end

% SSE
if L.bSSE,
    %comma();
    fprintf(L.fid, ', SSE');
end

% Target
if L.bTarget,
    %comma();
    fprintf(L.fid, ', Target');
end

% W
% numHidden * numOut
if L.bW,
    for i = 1:L.maxHid,
        for j = 1:numOut,
            %comma();
            fprintf(L.fid, ', W(%d-%d)', i, j);
        end
    end
end



% done!
fprintf(L.fid, '\n');




%     function comma
%         if first,
%             first = 0;
%         else
%             fprintf(L.fid, ', ');
%         end
%     end

end
