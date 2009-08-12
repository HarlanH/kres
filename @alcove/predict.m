function [prediction, err, A] = predict(A, input, target)
% PREDICT ALCOVE prediction.
% [prediction, err] = predict(A, [1 2 3], 2)
% prediction is the index of the prediction
% err is the absolute error of the ensemble's prediction
% input is a vector, of course
% target is an index into the possible categories

% we'll keep some fields around for use in case we're called by the train
% function: a_hid, a_out, 

% calculate activation of exemplar nodes
A.a_hid = abs(repmat(input, A.exemplars,1) - A.h);
A.a_hid = sum(repmat(A.alpha,A.exemplars,1) .* (A.a_hid .^ A.r), 2); 
			% above sums across rows        
A.a_hid = exp(-A.c * (A.a_hid .^ (A.q/A.r)));
																	
% calculate output/category node activation
A.a_out = A.w * A.a_hid;
																	
% do Luce choice to get Pr(K)
Pr_K = exp(A.phi * A.a_out);
Pr_K = Pr_K / sum(Pr_K);
																	
% choose a response
% build a cumulative array from Pr_K
Pr_K_cum = tril(ones(length(Pr_K))) * Pr_K;
% gen a random number
ra = rand;
% find the index of the smallest response greater than ra
% this is O(n) -- could be O(sqrt(n))
K = -1;
for i = 1:length(Pr_K),
	if (ra <= Pr_K_cum(i)),
		K = i;          % K is the response index into the output array
		break;
	end
end
if (K == -1),
    disp(Pr_K_cum);
    disp(ra);
    error('could not calculate response?!? huh!?!');
end

% and create the response array
prediction = K;
																	
% compute teacher values (not penalizing abs(output) > 1)
% first, the incorrect responses
A.t = min(-1, A.a_out);
% then, the correct response
A.t(target) = max(1, A.a_out(target));
																	
%disp(A.t');
%disp(A.a_out');

% compute SSE
err = .5 * sum((A.t - A.a_out) .^ 2);
																	
% compute ensemble absolute error 
%if (target == K),
	%err = 0;
%else
	%err = 1;
%end

% report response and actual error
%fprintf(ofid,'%d %d ', block, trial);
%fprintf(ofid, '%0.4f ', traindata(trial,:));
%fprintf(ofid, '%0.4f %0.4f %0.4f\n', traintarget(trial), K, E);

