function [ K ] = updateWeights( K )
%UPDATEWEIGHTS Update Alpha and W weights.
%   Run implicitly if batch mode is off, or explicitly by the user if batch
%   mode is on.

% main weights
K.w = K.w + K.dW;
K.dW = zeros(size(K.dW));

% attention weights
K.alpha = max(0,K.alpha + K.dAlpha);
K.dAlpha = zeros(size(K.dAlpha));

