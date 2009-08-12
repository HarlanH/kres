function [prediction, err, A] = train(A, input, target)
% TRAIN ALCOVE training cycle.
% [prediction, err] = train(A, [1 2 3], 2)
% prediction is the index of the prediction
% err is the absolute error of the ensemble's prediction
% input is a vector, of course
% target is the index of the correct response

% first, do the prediction step
[prediction, err, A] = predict(A, input, target);

% update weight matrix
d_w = A.lambda_w * (A.t - A.a_out) * A.a_hid';

% for speed
Ainputs = A.inputs; Ac = A.c; Aoutputs = A.outputs; At = A.t; Aa_out = A.a_out; Aw = A.w;
Aa_hid = A.a_hid; Ah = A.h; % object methods are slow!
d_alpha = zeros(1, Ainputs);

% update alpha array... tricky... and in icky slow loops
for i = 1:Ainputs,
    inputi = input(i); % for speed
	sum_j = 0;
	for j = 1:A.exemplars,
		sum_k = 0;
		for k = 1:Aoutputs,
			sum_k = sum_k + (At(k) - Aa_out(k)) * Aw(k,j);
		end
		sum_j = sum_j + sum_k * Aa_hid(j) * Ac * abs(Ah(j,i) - inputi);
	end
	d_alpha(i) = - A.lambda_alpha * sum_j;
end

A.w = A.w + d_w;
A.alpha = max(0, A.alpha + d_alpha);

