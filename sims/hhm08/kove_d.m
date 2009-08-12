function K = kove_d(d)
% KOVE_D network setup for hhm08 task, KOVE/PD model
% d is distortion strength, or 0 if no distortion

K = [];

% Input Layer
% 5 features, 5 dimensions
K.numFeats = 5;
K.numDims = 5;
K.featToDim = [1:5];
K.alpha = ones(1,K.numDims) .* 1;

% Hidden Layer
K.hiddenFeats = 1; % copy of input
K.q = 1;
K.r = 1;
K.c = 3;	% @@@ override this

if d,
    % want activation of each node to positively activate nodes of the same
    % bank, and negatively activate nodes of the opposite parity
    
    di = 1; %1-d*(K.numFeats-1);
    K.trans = eye(K.numDims) * (di - d) + d;
    
%     K.trans = [di d d d d -d -d -d -d -d; ...
%                d di d d d -d -d -d -d -d; ...
%                d d di d d -d -d -d -d -d; ...
%                d d d di d -d -d -d -d -d; ...
%                d d d d di -d -d -d -d -d; ...
%                -d -d -d -d -d di d d d d; ...
%                -d -d -d -d -d d di d d d; ...
%                -d -d -d -d -d d d di d d; ...
%                -d -d -d -d -d d d d di d; ...
%                -d -d -d -d -d d d d d di];

end

% Output Layer
K.numOut = 2;
K.phi = 2;  % @@@ override this
K.lambdaW = .1; % @@@ override this
K.lambdaAlpha = 0; % @@@ possibly override this

% type 1 = feature, 2 = prior knowledge, 3 = exemplar, 4 = bias
K.B = [1 0 0 1];     % direct connections and bias only
