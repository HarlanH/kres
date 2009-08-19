function K = kove_ed(wD)
% KOVE_ED network setup for wdmm86 task
% wD is distortion strength, or 0 if no distortion

K = [];

% Input Layer
% 4 features, 4 dimensions
K.numFeats = 4;
K.numDims = 4;
K.featToDim = 1:4;
K.alpha = ones(1,K.numDims) .* 1;

% Hidden Layer
% type 1 = feature, type 2 = prior knowledge, type 3 = exemplar
K.hiddenFeats = 0;
K.q = 1;
K.r = 1;
K.c = 3;	% @@@ override this
%K.exemplarDistortion = true;

if wD,
    % distortion matrix has 1 on diagonal, and wD off diagonal, indicating
    % that all features reinforce each other.
    K.trans = eye(K.numFeats) .* (1-wD) + wD;
end

% Output Layer
K.numOut = 2;
K.phi = 2;  % @@@ override this
K.lambdaW = .1; % @@@ override this
K.lambdaAlpha = 0; % @@@ possibly override this

K.B = [0 0 1 0];     % exemplars only
