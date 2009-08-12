function [ act, cycles ] = converge( K, in, P )
%CONVERGE Constraint satisfaction phase of KRES algorithm.
%   K - KRES network object
%   in - input vector
%   P - params
%   returns act - activation vector
%       cycles - number of cycles before settling

harmony = 0;
dHarmony = 1;

% make sure our sizes are OK
% size(in) = size(getBias(K)) = length(getW(K))
if (length(in) ~= length(K.bias)) || (length(in) ~= length(K.w)),
    error('KRES:kres:converge', 'Sizes seem wrong!');
end

% net_input starts out at 0
net_input = zeros(size(in));
adj_input = zeros(size(in));

cycles = 0;
gain = getGain(P); % cache to save a bit of time
alpha = getAlpha(P); % ditto

% while harmony is high and we haven't done a ridiculous number of cycles
while (dHarmony > 0.00001) && (cycles < 1000000), % @@@ param?
    % calculate total_input
    total_input = net_input + in + K.bias;
    
    % do gain thing
    adj_input = adj_input + (total_input - adj_input) ./ gain; 
           
    % calculate activation
    act = 1 ./ (1 + exp(-alpha .* adj_input));
%     fprintf(1, '%0.2f ', act);
%     fprintf(1, '\n');
    
    % calculate net_input
    net_input = act * K.w;
    
    % calculate harmony
    newHarmony = sum(act .* net_input);
    dHarmony = abs(harmony - newHarmony);
    harmony = newHarmony;
    
    cycles = cycles + 1;
end
