function [ ST ] = subtree( T, head )
%SUBTREE Get the subtree of T rooted at head.
%   Recursive algorithm:
%       if root == head, return tree
%       foreach child of root
%           ret = recurse
%           if ret is not null, return ret
%       end
%       return null

ST = {};

if (strcmp(T{1}, head)),
    ST = T;
else
    for i = 1:length(T),
        if (iscell(T{i})),
            ret = subtree(T{i}, head);
        else % it's a string
            if strcmp(T{i}, head),
                ret = T{i};
            else
                ret = {};
            end
        end
        if (length(ret) > 0),
            ST = ret;
            break;
        end
    end
end

