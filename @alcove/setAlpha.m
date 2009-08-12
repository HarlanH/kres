function ret = setAlpha(Alcove, alpha)
% SETALPHA Set attention vector
%  Alcove1 = setAlpha(Alcove1, getAlpha(Alcove2))

if (size(alpha) == size(Alcove.alpha)),
	Alcove.alpha = alpha;
else
	error('size(alpha) ~= size(Alcove.alpha)!');
end

ret = Alcove;

