function [K, PrK, err] = train(K, aIn, targCat)
% TRAIN KOVE train-trial.

global kc

% to train, first test, then use the activations to change weights

[K, PrK, err] = test(K, aIn, targCat, K.B(kc.EX));  % only add exemplars if we'll use them later

% figure out learning rates

% old:
%lrFactor = prod(exp((K.hTypes == 2) .* K.s .* K.aHid));
%lrFactor = max(exp((1 - K.aHid(find(K.hTypes==2))) .* K.s));

% if s > 0, PK activation can increase LR;
% if s = 0, PK has no effect;
% if s < 0, PK activation can decrease LR.
% threshold at 10 to prevent blowup
if (any(K.hTypes==kc.PK)),
    lrFactor = min(10, (1-max(K.aHid(K.hTypes==kc.PK)))^(-K.s));
else
    lrFactor = 1;
end
lrW = K.lambdaW * lrFactor;
lrA = K.lambdaAlpha * lrFactor;

% fprintf(1, '%+d ', aIn);
% fprintf(1, '%d %0.4f\n', targCat, lrFactor);

% change weights
delay = K.D(K.hTypes) <= K.trainTrials;
weight = K.B(K.hTypes);
K.dW = K.dW + lrW .* ((K.aHid .* delay .* weight)' * (K.t - K.aOut));

% change attention (this is BROKEN if you have feature nodes!)

if any(lrA),
    if any(K.hTypes == kc.FEAT),
        error('KOVE:train', 'If using feature nodes, lambdaAlpha must be 0');
    end

    % Here's how this works. Each feature gets a delta, which is then mapped to
    % the dimensions for attention changes. 

    % prep work
    numHidden = size(K.h,1);
    RaIn = aIn * K.trans; % move to test and store?

    % compute the innermost loop (over the output nodes) once, giving a vector
    % over j hidden nodes
    % sum_k (t_k - a^out_k) w_kj
    outerr = sum(repmat((K.t - K.aOut), numHidden, 1) .* K.w, 2)';

    % compute the summation over i, which gives a vector over j hidden nodes
    % so, duplicate RaIn so we can subtract from h, do the same with alpha, and
    % sum over features
    % sum_i alpha_d_i abs(h_ji - Ra^in_i)^r
    % first, do the subtraction and zero the NaNs
    match1 = realpow(abs(K.h - repmat(RaIn, numHidden, 1)), K.r);  % used later too!
    match1(isnan(match1)) = 0;
    % now do the attention multiply and sum to get us to hidden nodes
    %hidmatch = sum(repmat(K.alpha(K.featToDim), numHidden, 1) .* match1, 2)';
    hidmatch = K.alpha(K.featToDim) * match1';
    %if (hidmatch ~= hidmatch2), error('hidmatch ~= hidmatch2'); end

    % now, multiply everything together to get the gradient at the hidden nodes
    hidgrad = outerr .* delay .* weight .* K.aHid .* K.c(K.hTypes) .* (K.q/K.r) ...
        .* realpow(hidmatch, ((K.q-K.r)/K.r));

    % and finally, multiply that to get deltas for each feature
    deltaAlphaFeat = -lrA .* (hidgrad * match1);

    % and do the actual update
    a = zeros(size(K.alpha));
    ftd = K.featToDim;
    for i = 1:K.numFeats,   % can't be matricized...?
        a(ftd(i)) = a(ftd(i)) + deltaAlphaFeat(i);
    end
    K.dAlpha = K.dAlpha + a;
end

% if we're in incremental (not batch) mode, so the weight updates now
if (~K.batch),
    K = updateWeights(K);
end
    

K.trainTrials = K.trainTrials + 1;
