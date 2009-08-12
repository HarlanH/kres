function X = alcove(Xc, Xphi, Xlambda_w, Xlambda_alpha, Xinputs, Xoutputs, exemplars, eval_string)
% ALCOVE Attention Learning Covering Map object constructor
%  X = alcove(c, phi, lambda_w, lambda_alpha, inputs, output, exemplars, 
%             eval_string)

% fields

% parameters
X.c = Xc;							% specificity
X.phi = Xphi;						% mapping constant
X.lambda_w = Xlambda_w;				% learning rate for weights
X.lambda_alpha = Xlambda_alpha;		% learning rate for attention
X.inputs = Xinputs;					% number of inputs
X.outputs = Xoutputs;				% number of outputs
% fixed parameters
X.q = 1;							% similarity gradient
X.r = 1;							% metric (1 = city block, 2 = euclidian...)
X.alpha_iv = 1;						% initial value of attention
X.w_iv = 0;							% initial value of weights

if (length(eval_string)),
	eval(eval_string);
end

% sanity check
if (X.inputs ~= size(exemplars,2)),
	error('X.inputs ~= size(exemplars,2)!');
end

% data structures

% attention vector
X.alpha = ones(1,X.inputs) * X.alpha_iv;
% exemplar nodes that cover the input space
X.h = exemplars;
X.exemplars = size(X.h,1);
% weight matrix
X.w = ones(X.outputs,X.exemplars) * X.w_iv;

% other fields we'll need later
X.a_hid = [];
X.a_out = [];
X.t = [];

X = class(X, 'alcove');

