function [order] = orderelems(elems, tolerance)
% ORDERELEMS Return ordering of numbers within a tolerance.
% 	For example, given [.1 .3 6 4 5] with tolerance 0.5, this returns
% 	[1 1 4 2 3]. Order is always increasing.

[sorted, idxs] = sort(elems);

level = 1;
best = min(elems);
order = zeros(size(idxs));

% for each index
for i = 1:length(idxs),
	%fprintf(1, '%d:\n', i);
	nextidx = find(elems == sorted(i));
	%fprintf(1, 'nextidx = %d\n', nextidx);
	%fprintf(1, 'sorted(i) = %f\n', sorted(i));
	%fprintf(1, 'best = %f\n', best);
	%fprintf(1, 'pre order = ');
	%fprintf(1, '%d ', order);
	%fprintf(1, '\n');

	% if the element is less than tolerance from the previous level
	if (sorted(i) < best + tolerance),
		% use the ordering of the previous level
		order(nextidx) = level;
	% otherwise
	else
		% create a new level, and use its ordering
		level = level + 1;
		best = sorted(i);
		order(nextidx) = level;
	end
	%fprintf(1, 'post order = ');
	%fprintf(1, '%d ', order);
	%fprintf(1, '\n');
end


