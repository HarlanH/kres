function [ K ] = kove(K)
% KOVE Constructor for KOVE object
%   Converts the passed-in structure, which may be incomplete, to a legal KOVE object.
%   There are four types of hidden nodes:
%     kc.FEAT (1) - single-feature nodes
%     kc.PK (2) - prior-knowledge nodes
%     kc.EX (3) - exemplar nodes
%     kc.BIAS (4) - bias nodes
%   Required existing fields:
%       numFeats - number of input *features*
%       numDims - number of input *dimensions*
%       featToDim - mapping, of size numFeats, of features to dimensions
%       c - scalar specificity, or size-4 array, if hidden nodes have
%           different c's.
%       numOut - number of output nodes / categories
%       phi - parameter of Luce choice rule
%       lambdaW - learning rate for hidden-output weights
%       lambdaAlpha - learning rate for attention
%   Optional fields:
%       trans - transformation/distortion matrix, default: eye(numFeats)
%       alpha - size numDims array, default: ones(1,numDims)
%       hiddenFeats - 1 if there are hidden nodes for each feature,
%           default: 0
%       q, r - ALCOVE parameters on similarity, defaults: 1
%       PK - prior knowledge nodes, n x numFeats array, default: []
%       B - weighting on *types* of hidden nodes, default: [1 1 1 0]
%       D - delay (in trials) on *types* of hidden nodes, default: [0 0 0 0]
%       s - LR weighting based on PK activation, default: 0
%       batch - batch updates to weights, default: false
%       exemplarAttention - weight exemplars by attention, default: false
%       exemplarDistorted - weight exemplars by distortion, default: false
%   Added internal fields:
%       h - input-hidden weight matrix 
%       w - hidden-output weight matrix
%       aHid - hidden unit activation for current trial
%       aOut - output unit activation for current trial
%       PrK - response probabilities for current trial
%       trainTrials - count of number of training trials so far
%       t - teacher values
%       logging fields:
%       input, target - copies for logging

errMissingField = 'kove:kove:missingField';
errBadField = 'kove:kove:badField';
errNYI = 'kove:kove:notYetImplemented';

% define constants
global kc
kc.FEAT = 1; kc.PK = 2; kc.EX = 3; kc.BIAS = 4;

% INPUT-RELATED PARAMETERS

if isfield(K, 'numFeats'),
    % 
else
    error(errMissingField, 'numFeats field is missing');
end

if isfield(K, 'numDims'),
    %
else
    error(errMissingField, 'numDims field is missing');
end
    
if isfield(K, 'featToDim'),
    if length(K.featToDim) ~= K.numFeats,
        error(errBadField, 'featToDim is not of size numFeats');
    end
else
    error(errMissingField, 'numDims field is missing');
end

if isfield(K, 'trans'),
    if sum(size(K.trans) == [K.numFeats K.numFeats]) ~= 2,
        error(errBadField, 'trans is not of size numFeats X numFeats');
    end
else
    K.trans = eye(K.numFeats);
end

if isfield(K, 'alpha'),
    if length(K.alpha) ~= K.numDims,
        error(errBadField, 'alpha is not of size numDims');
    end
else
    K.alpha = ones(1, K.numDims);
end

% HIDDEN-RELATED PARAMETERS

if isfield(K, 'c'),
    if length(K.c) == 1,
        K.c = ones(1,4) * K.c;
    elseif length(K.c) == 4
        %
    else
        error(errBadField, 'c is not of size 1 or size 4');
    end
else
    error(errMissingField, 'c field is missing');
end

% build up the h matrix. First features, then PK nodes. No exemplars
% initially.

if isfield(K, 'hiddenFeats'),
    %
else
    K.hiddenFeats = 0;
end

if K.hiddenFeats,
    % create an identify matrix, but off-diagonal elements are NaNs
    K.h = eye(K.numFeats);
    K.h(K.h == 0) = NaN;   
    K.hTypes = ones(1,K.numFeats) * kc.FEAT;
else
    K.h = [];
    K.hTypes = [];
end

% now PK nodes
if isfield(K, 'PK'),
    % must be of length numFeats
    if size(K.PK, 2) ~= K.numFeats,
        error(errBadField, 'PK is not of size numFeats');
    end
    
    % append to K.h
    K.h = [K.h; K.PK];
    K.hTypes = [K.hTypes ones(1,size(K.PK,1))*kc.PK];
else
    K.PK = [];  % to prevent class-redefinition errors
end

% now bias. add a bias node if B is non-0 or there are hidden feats
if (K.B(kc.BIAS) || K.hiddenFeats),
    % the node should have NaN weights to the input; c doesn't matter
    K.h = [K.h; NaN * ones(1, K.numFeats)];
    K.hTypes = [K.hTypes kc.BIAS];
    % c needn't be changed, since activation is set manually
end

K.numExemplars = 0;

K.aHid = zeros(1, size(K.h, 1));

if isfield(K, 'q'),
    %
else
    K.q = 1;
end

if isfield(K, 'r'),
    %
else
    K.r = 1;
end

if isfield(K, 'exemplarAttention'),
    %
    error(errNYI, 'exemplarAttention not implemented!');
else
    K.exemplarAttention = false;
end

if isfield(K, 'exemplarDistortion'),
    %
else
    K.exemplarDistortion = false;
end

% OUTPUT-RELATED PARAMETERS

if isfield(K, 'numOut'),
    %
else
    error(errMissingField, 'numOut field is missing');
end

if isfield(K, 'phi'),
    %
else
    error(errMissingField, 'phi field is missing');
end

if isfield(K, 'B'),
    if sum(size(K.B) == [1 4]) ~= 2,
        error(errBadField, 'B is not of size 4');
    end
else
    K.B = [1 1 1 0];
end

if isfield(K, 'D'),
    if sum(size(K.D) == [1 4]) ~= 2,
        error(errBadField, 'D is not of size 4');
    end
else
    K.D = [0 0 0 0];
end

% create the weights
K.w = zeros(size(K.h, 1), K.numOut);

% and the activations
K.aOut = zeros(1, K.numOut);

% and the response probabilities
K.PrK = zeros(1, K.numOut);

% LEARNING-RELATED PARAMETERS

if isfield(K, 'lambdaW'),
    %
else
    error(errMissingField, 'lambdaW field is missing');
end

if isfield(K, 'lambdaAlpha'),
    %
else
    error(errMissingField, 'lambdaAlpha field is missing');
end

if isfield(K, 's'),
    %
else
    K.s = 0;
end

K.t = zeros(1,K.numOut);

K.trainTrials = 0;

% stuff to log
K.log.input = zeros(1,K.numFeats);
K.log.target = 0;
K.log.ASSE = 0;
K.log.SSE = 0;

if isfield(K, 'batch'),
    %
else
    K.batch = false;
end
K.dAlpha = zeros(size(K.alpha));
K.dW = zeros(size(K.w));

% I think that's it!

%disp(K);

% make it a class!
K = orderfields(K); % to prevent issues having to do with the order of fields changing
K = class(K, 'kove');

