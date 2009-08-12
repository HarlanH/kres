function [ K, out ] = test( K, Xin, Xout, P )
%TEST Test the network on the specified exemplar.
%   K - the network
%   Xin - the example, input
%   Xout - the example, target
%   P - parameters

if (nargin ~= 4),
    error('KRES:kres:train', 'Not enough arguments!');
end

% OK! Here's how this will work. First, converge with just Xin as input,
% and save the activations. 

[K.minusAct, K.log.SettleTime] = converge(K, Xin, P);
%disp(K.log.SettleTime);
%K.plusAct = converge(K, Xin+Xout, P); needed?

% Now, figure out the ensemble's prediction and error. 

% Use the node tree in K to get the output nodes. Use those to figure out
% which elements of K.minusAct belong in the output vector.
% Then, do LCR on that to get.

outList = tree2leaves(subtree(K.nodeTree, 'O'));
outAct = zeros(size(outList));
for i = 1:length(outAct),
    outAct(i) = K.minusAct(getNodeIdx(K, outList(i)));
end

K.log.Outputs = outAct ./ sum(outAct);
out = K.log.Outputs;

% and for logging...
K.log.Input = Xin + Xout;
