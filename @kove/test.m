function [K, PrK, err] = test(K, aIn, targCat, addExemplarP)
% TEST KOVE test-trial.

global kc

% OK, this should be fairly straightforward...

% sanity test the arguments
if K.numFeats ~= length(aIn),
    error('KOVE:test:argError', 'aIn array not same size as numFeats');
end
if (targCat > K.numOut) || (targCat < 1),
   error('KOVE:test:argError', 'aTarg array not same size as numOut');
end 

% store the input and target for logging
K.log.input = aIn;
K.log.target = targCat;

% distort the input
RaIn = aIn * K.trans;  % breaks with NaN as input!
% normalize @@@ to +1,-1? 
% RaIn = RaIn - min(RaIn);    % smallest to 0
% RaIn = RaIn ./ max(RaIn);   % largest to 1
%max(min(RaIn, 1), -1);

% calculate hidden activations
numHidden = size(K.h,1);

if nargin <= 3,
    addExemplarP = 0;
end

if addExemplarP,
    % is this a new exemplar?
    
    % to check, subtract RaIn from h matrix, and look for 0s. 
    if isempty(K.h),
        exMatch = 0;
    else
        if K.exemplarDistortion,
            exMatch = ((sum(abs(K.h - repmat(RaIn, numHidden, 1)), 2)) == 0) .* (K.hTypes == kc.EX)';
        else
            exMatch = ((sum(abs(K.h - repmat(aIn, numHidden, 1)), 2)) == 0) .* (K.hTypes == kc.EX)';
        end
    end
    
    if (~exMatch),
        % add one!
        if K.exemplarDistortion,
            K = addExemplars(K, RaIn);
        else
            K = addExemplars(K, aIn);
        end
        numHidden = numHidden + 1;
    end
        
end

% Calculate hidden activations.
% For features, take simple sigmoid function of input
% For exemplars and prior knowledge nodes, do the fancy ALCOVE-like
% RBF activation thing.
% For bias node, fix at -1.

% assume everything's an exemplar or PK node for now -- fix later.
% first, make a matrix of differences between the hidden nodes and Rain
z = abs(K.h - repmat(RaIn, numHidden, 1));
% weight by attention (and exp by r)
attn = K.alpha(K.featToDim);
z = repmat(attn, length(K.hTypes), 1) .* (z .^ K.r);
% now sum by rows, ignoring NaN (and exp by q/r)
z(isnan(z)) = 0;
z = sum(z, 2) .^ (K.q/K.r);
% each element is now a hidden node

% weight by -c
cs = K.c(K.hTypes);
K.aHid = exp(-cs .* z');
% great, exemplars and PK are done

% now, fix bias and feature nodes. (Note that implicit beta is fixed at 1.)
K.aHid(K.hTypes == kc.FEAT) = tanh(RaIn(K.hTypes == kc.FEAT));
% force activation of bias nodes to be -1
K.aHid(K.hTypes == kc.BIAS) = -1;


% calculate output stuff

% construct the delay and weighting factors
delay = K.D(K.hTypes) <= K.trainTrials;
weight = K.B(K.hTypes);
% calculate output activation
z = (delay .* weight .* K.aHid) * K.w;
K.aOut = sum(z,1);
K.PrK = exp(K.phi .* K.aOut) ./ sum(exp(K.phi .* K.aOut));
% if any(isnan(K.PrK)),
%     error('NaN in PrK calculation');
% end
PrK = K.PrK;

% targCat should be in 1..numOut
% construct two arrays of size aOut. One changes the max, the other the
% min.
maxT = ones(size(K.aOut)) * -Inf; maxT(targCat) = 1;
minT = ones(size(K.aOut)) * -1; minT(targCat) = Inf;
K.t = max(min(minT, K.aOut), maxT);

err = sum((K.t - K.aOut) .^ 2) / 2;
K.log.SSE = err;
K.log.ASSE = K.log.ASSE + err;

