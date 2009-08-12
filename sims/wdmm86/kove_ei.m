function K = kove_ei(wK)
% wdmm86_EI KOVE/EI network setup for wdmm86 task
% wK is PK node weighting, or 0 if no knowledge

K = [];

% Input Layer
% 4 features, 4 dimensions
K.numFeats = 4;
K.numDims = 4;
K.featToDim = 1:4;
K.alpha = ones(1,K.numDims) .* 1;

% Hidden Layer
% type 1 = feature, type 2 = prior knowledge, type 3 = exemplar
% want feature connections, no exemplars
K.hiddenFeats = 0;
K.q = 1;
K.r = 1;
K.c = 3;	% @@@ override this


% Output Layer
K.numOut = 2;
K.phi = 2;  % @@@ override this
K.lambdaW = .1; % @@@ override this
K.lambdaAlpha = 0; % @@@ possibly override this

if wK,
    K.PK = [-1 -1 -1 -1; ...
            1 1 1 1];
    K.B = [0 wK 1 0]; % PK nodes and exemplars
else
    K.B = [0 0 1 0];     % exemplars only
end
