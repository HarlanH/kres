function [ P ] = params( initialization )
%PARAMS Constructor for params object
%   Optionally, pass in eval-able string of function calls, ala:
%    'P = P.setLearningRate(0.01); P = P.setExWeight(1.0);' etc.

% set defaults

P.learningRate = 0.15;
P.inWeight = -1;
P.exWeight = 1;
P.randWeight = 0.1;
P.errorCriterion = 0.10;
P.gain = 4;
P.exempCriterion = 0.0001;
P.exempLearningRate = 1;
P.alpha = 4;
P.jolt = 1;
P.gamma = 1;

% convert to an object
P = class(P, 'params');

% eval initialization, if present
if (nargin > 0),
    eval(initialization);
end
