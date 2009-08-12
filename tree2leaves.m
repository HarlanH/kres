function [ L ] = tree2leaves( T )
%TREE2LEAVES Convert a tree-structured cell array to a cell-array of the
%leaves.
%   T must be in format:
%   T = {'A' {'B' 'C' 'D'} 'E' 'F' {'G' 'H' 'I'}};
%   giving:
%   L = {'C' 'D' 'E' 'F' 'H' 'I'};
%
%   Recursive algorithm:
%       if T is just a string, return it as a cell array
%       split T into first/rest
%       foreach item in rest
%           res = recurse
%           L = L . res
%       end

% this would be much easier in LISP!
% damnable cell arrays...

if ischar(T),
    L = {T};
else
    F = T{1};   % ignore
    R = T(2:length(T));
    
    L = {};
    
    for i = 1:length(R),
        % copy chars, recurse then copy cells
        if ischar(R{i}),
            L{length(L)+1} = R{i};
        else
            R2 = tree2leaves(R{i});
            for j = 1:length(R2),
                L{length(L)+1} = R2{j};
            end
        end
    end
end
