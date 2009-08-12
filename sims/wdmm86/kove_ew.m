function K = kove_ew(w)
% wdmm86_EW KOVE/EW network setup for wdmm86 task
% w is weighting strength, or 0 if no weighgtin

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

% Output Layer
K.numOut = 2;
K.phi = 2;  % @@@ override this
K.lambdaW = .1; % @@@ override this
K.lambdaAlpha = 0; % @@@ possibly override this

K.B = [0 0 1 0];     % output connections from exemplars only

K.PK = [0 0 0 0; ...    % these aren't used directly, just for weighting
            1 1 1 1];
K.s = w;            % weighting param

