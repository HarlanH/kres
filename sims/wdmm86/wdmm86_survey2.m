function wdmm86_survey2(samples)
% WDMM86_SURVEY Survey the parameter space of the KRES/E, KRES/EI, and
% KRES/ED models on the Wattenmaker et al. task. Use a Sobel sequence to
% find parameters within a specified region. For each parameter set,
% run one iteration for each model. If total errors are less than 60, then
% run four more iterations to get a more stable estimate. For each model
% and parameter set, give the actual error counts, plus an ordering for
% LS/U,LS/K,NLS/U,NLS/K, ala [4 3 1 2], which is the target count. If
% errors are separated by less than 5%, count it as a tie, ala [1 1 1 1].

path('../../', path);


% % orderings (convert from binary sorted order to A1 sorted order)
% orderLS = [8 5 7 3 6 1 2 4];
% orderNLS = [5 6 8 4 2 3 7 1];
% 
% % empirical data (in A1 sorted order)
% dataLSU = [5.9 6.2 5.7 4.6 7 6.2 5.5 7.5];
% dataNLSU = [5.9 8.7 5.2 6 2.6 4.4 8.3 3.2];
% dataLSK = [3.5 3 2.1 3.3 4.1 3.4 4.2 3.5];
% dataNLSK = [6.4 3.9 3.5 4.8 3.1 4.5 7.6 3.6];

% net specs
nsE = wdmm86_e();
nsEI = wdmm86_ei();
nsED = wdmm86_ed();

% models and tasks
models = {'E', 'EI', 'ED'};
%tasks = {'LS', 'NLS'};

% parameter ranges
% LR, exemplar LR, alpha, inhib wt, excit wt

psize = [3 2 4 5 3];
poffset = [.01 .1 .25 -5.1 .1];

hset = haltonset(5, 'Skip', 1e3, 'Leap', 37);
hset = scramble(hset, 'RR2');
pstream = qrandstream(hset);

for i=1:samples,
    % get random parameters in [0 1], then scale to be in the interval
    ps = qrand(pstream,1) .* psize + poffset;
    lr = ps(1); elr = ps(2); alpha = ps(3); inw = ps(4); exw = ps(5);
    
    % set those parameters
    p = params;
    p = setLearningRate(p, lr);
    p = setExempLearningRate(p, elr);
    p = setAlpha(p, alpha);
    p = setInWeight(p, inw);
    p = setExWeight(p, exw);
    p = setErrorCriterion(p, 0); % never stop early
    
    % set the exemplar biases for all models
    nsE.bias(1).value = -2*log(8-1)/getAlpha(p);
    nsEI.bias(1).value = -2*log(8-1)/getAlpha(p);
    nsED.bias(1).value = -2*log(8-1)/getAlpha(p);
    
    % now, run each of the models. For each, we get two numbers, the LS and
    % NLS errors. End up printing the data like this:
    % EI p1 p2 p3 p4 p5 U/LS U/NLS K/LS K/NLS
    % ED same...
    
    totalerrs = zeros(3,2);
    
    for imodel = 1:3,
        if strcmp(models{imodel}, 'E'),
            ns = nsE;
        elseif strcmp(models{imodel}, 'EI'),
            ns = nsEI;
        else
            ns = nsED;
        end
        
        % this creates the data files in the out/ subdir
        wdmm86_run(ns, p, 1);
        
        % analyze the data
        
        % first LS condition
        cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-1-*.dat';
        [stat res] = unix(cmdline);
        LSerrs = sscanf(res, '%f');
        totalerrs(imodel,1) = sum(LSerrs);
        
        % now the NLS condition
        cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-2-*.dat';
        [stat res] = unix(cmdline);
        NLSerrs = sscanf(res, '%f');
        
        totalerrs(imodel,2) = sum(NLSerrs);

        
%         % output two lines, one for each task
%         % model task lr inw alpha e1 e2 ... e10 mse
%         
%         fprintf(1, '%s %s %0.2f %0.2f %0.2f %0.2f %0.2f ', models{imodel}, 'LS', ...
%             lr, elr, alpha, inw, exw);
%         fprintf(1, '%0.3f ', LSerrs);
%         fprintf(1, '%0.3f\n', LSMSE);
%         
%         fprintf(1, '%s %s %0.2f %0.2f %0.2f %0.2f %0.2f ', models{imodel}, 'NLS', ...
%             lr, elr, alpha, inw, exw);
%         fprintf(1, '%0.3f ', NLSerrs);
%         fprintf(1, '%0.3f\n', NLSMSE);
        
    end
    
    eiErrs = totalerrs([1 2], :);
    eiErrs = eiErrs(1:4);
    edErrs = totalerrs([1 3], :);
    edErrs = edErrs(1:4);
    fprintf(1, 'EI ');
    fprintf(1, '%0.2f ', ps);
    fprintf(1, '%0.2f ', eiErrs);
    fprintf(1, '%d ', orderelems(eiErrs, max(eiErrs)/10));
    fprintf(1, '\nED ');
    fprintf(1, '%0.2f ', ps);
    fprintf(1, '%0.2f ', edErrs);
    fprintf(1, '%d ', orderelems(edErrs, max(edErrs)/10));
    fprintf(1, '\n');
    
    
    
end


end
