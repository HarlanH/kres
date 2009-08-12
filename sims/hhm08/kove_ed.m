function K = kove_ed(wD)
% KOVE_ED network setup for hhm08 task
% wD is distortion strength, or 0 if no distortion

K = [];

% Input Layer
% 5 features, 5 dimensions
K.numFeats = 5;
K.numDims = 5;
K.featToDim = 1:5;
K.alpha = ones(1,K.numDims) .* 1;

% Hidden Layer
% type 1 = feature, type 2 = prior knowledge, type 3 = exemplar
K.hiddenFeats = 0;
K.q = 1;
K.r = 1;
K.c = 3;	% @@@ override this

if wD,
    K.trans = eye(K.numFeats) .* (1-wD) + wD;
end

% Output Layer
K.numOut = 2;
K.phi = 2;  % @@@ override this
K.lambdaW = .1; % @@@ override this
K.lambdaAlpha = 0; % @@@ possibly override this

K.B = [0 0 1];     % exemplars only
