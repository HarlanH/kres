function NS = wdmm86_ei()
% Wattenmaker et al. (1986), Experiment 1, Related Condition
% KRES/EI

NS = [];

NS.nodes = {'all' {'I' {'I0' 'A0' 'B0' 'C0' 'D0'} {'I1' 'A1' 'B1' 'C1' 'D1'}} ...
    {'P' 'P0' 'P1'} {'E' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8'} {'O' 'X' 'Y'}};
                   
NS.cons(1) = struct('from', 'X', 'to', 'Y', 'type', 'fixed', 'spread', 'full', 'init', 'in');
NS.cons(2) = struct('from', 'I0', 'to', 'I1', 'type', 'fixed', 'spread', '121', 'init', 'in');
NS.cons(3) = struct('from', 'P0', 'to', 'I0', 'type', 'fixed', 'spread', 'full', 'init', 'ex');
NS.cons(4) = struct('from', 'P1', 'to', 'I1', 'type', 'fixed', 'spread', 'full', 'init', 'ex');
NS.cons(5) = struct('from', 'P', 'to', 'O', 'type', 'chl', 'spread', 'full', 'init', 'rand');
NS.cons(6) = struct('from', 'P0', 'to', 'P1', 'type', 'fixed', 'spread', 'full', 'init', 'in');
NS.cons(7) = struct('from', 'I', 'to', 'E', 'type', 'exemp', 'spread', 'full', 'init', 0);
NS.cons(8) = struct('from', 'E', 'to', 'O', 'type', 'exempchl', 'spread', 'full', 'init', 'rand');
NS.cons(9) = struct('from', 'E', 'to', 'E', 'type', 'fixed', 'spread', 'full', 'init', 'in');

% E must be first
NS.bias(1) = struct('node', 'E', 'value', -1); % overwritten
NS.bias(2) = struct('node', 'P', 'value', -1);
NS.bias(3) = struct('node', 'O', 'value', -1);

