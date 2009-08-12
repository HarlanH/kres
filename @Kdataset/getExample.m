function [ Input, Target ] = getExample( DS, i )
%GETEXAMPLE Get example i from the dataset.
%   Returns the input vector and target vector as separate zero-padded arrays.
%   So, if DS.data(i) = [1 2 3 4 5 6] and columns 2 and 5 are target
%   values, this will return:
%   Input = [1 0 3 4 0 6];
%   Target =[0 2 0 0 5 0];
%   That way, the arrays can be cleanly added in to the KRES data structure
%   without requiring padding or lookups.

Target = DS.data(i,:) .* DS.targetmask;
Input = DS.data(i,:) .* (1 - DS.targetmask);


