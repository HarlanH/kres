function [x,fval,exitflag,output] = kove_U_fit
% KOVE_U_FIT Use fminsearch to find parameters that give a good fit to the
% per-item errors of the unrelated/no-knowledge conditions of WDMM86. 

path('../..', path);

exp1 = [5.9 6.2 5.7 4.6 7 6.2 5.5 7.5;  5.9 8.7 5.2 6 2.6 4.4 8.3 3.2];
exp2 = [7.65 6.5 6.05 6.5 6.9 8.7 7.15 7.05;  7.15 6.3 5.85 7.25 5.35 5.65 8.2 6.55];
empirical = (exp1 + exp2) ./ 2;

x0 = [.03 .75 1.5]; % lr, c, phi

opts = optimset('Display', 'iter', 'MaxFunEvals', 1000, 'TolFun', .01);

[x,fval,exitflag,output] = fminsearch(@kove_U_err, x0, opts);


function E = kove_U_err(p)

    % construct a config to pass to kove_run
    config = kove_ei(0); % no knowledge
    config.lambdaW = p(1);
    config.c = p(2);
    config.phi = p(3);
    config.batch = true; % still not perfectly deterministic, because 
                          % exemplars are added immediately, but better
                          % than nothing...
    
    trainErrs = kove_run(config, 3); % 3 reps to reduce variance
    
    E = sum(sum((trainErrs - empirical).^2));

end

end
