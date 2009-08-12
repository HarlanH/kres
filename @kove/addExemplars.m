function K = addExemplars(K, exemplars)
% ADDEXEMPLARS Add exemplars manually to a KRES model.
%   The parameter exemplars can be either a single exemplar (a row vector 
%   representing a stimulus) or a matrix of exemplar columns.

for i = 1:size(exemplars, 1),
    K.h = [K.h; exemplars(i,:)];
    K.hTypes = [K.hTypes 3];
    K.w = [K.w; zeros(1,K.numOut)];
    K.dW = [K.dW; zeros(1,K.numOut)];
    K.numExemplars = K.numExemplars + 1;
end