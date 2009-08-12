function NS = hhm08_5k()
% KRES specifications file for simulations of dimensionality effect
% 5 inputs used, knowledge

NS = [];

NS.nodes = {'all' {'I' {'I0' 'IA0' 'IB0' 'IC0' 'ID0' 'IE0'} 'IF0' 'IG0' 'IH0' 'II0' 'IJ0' ...
					   {'I1' 'IA1' 'IB1' 'IC1' 'ID1' 'IE1'} 'IF1' 'IG1' 'IH1' 'II1' 'IJ1'} ...
				  {'O' 'X' 'Y'}};

NS.cons(1) = struct('from', 'X', 'to', 'Y', 'type', 'fixed', 'spread', 'full', 'init', 'in');
NS.cons(2) = struct('from', 'I0', 'to', 'I1', 'type', 'fixed', 'spread', '121', 'init', 'in');
NS.cons(3) = struct('from', 'I0', 'to', 'O', 'type', 'chl', 'spread', 'full', 'init', 'rand');
NS.cons(4) = struct('from', 'I1', 'to', 'O', 'type', 'chl', 'spread', 'full', 'init', 'rand');
NS.cons(5) = struct('from', 'I0', 'to', 'I0', 'type', 'fixed', 'spread', 'full', 'init', 'ex');
NS.cons(6) = struct('from', 'I1', 'to', 'I1', 'type', 'fixed', 'spread', 'full', 'init', 'ex');

NS.bias(1) = struct('node', 'O', 'value', -1);	
											

