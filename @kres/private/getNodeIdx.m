function [ idx ] = getNodeIdx(K, nodeName )
%GETNODEIDX Get index of a node from its name. nodeName can be a cell array
% of strings, in which case this returns an array of indexes.

if (iscell(nodeName)),
    idx = [];
    for nnIdx = 1:length(nodeName),
        for kNIdx = 1:length(K.nodes),
            if strcmp(K.nodes(kNIdx), nodeName(nnIdx)),
                idx = [idx kNIdx];
                break;
            end
        end
    end
else
    % the normal, degenerate case
    
    for kNIdx = 1:length(K.nodes),
        if strcmp(K.nodes(kNIdx), nodeName),
            idx = kNIdx;
            break;
        end
    end
end