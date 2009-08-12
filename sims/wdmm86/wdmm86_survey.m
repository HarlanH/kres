function wdmm86_survey(reps)
% WDMM86_SURVEY Survey the parameter space of the KRES/E, KRES/EI, and
% KRES/ED models on the Wattenmaker et al. task. 


if (nargin == 0),
    reps = 2;
end

path('../../', path);


% orderings (convert from binary sorted order to A1 sorted order)
orderLS = [8 5 7 3 6 1 2 4];
orderNLS = [5 6 8 4 2 3 7 1];

% empirical data (in A1 sorted order)
dataLSU = [5.9 6.2 5.7 4.6 7 6.2 5.5 7.5];
dataNLSU = [5.9 8.7 5.2 6 2.6 4.4 8.3 3.2];
dataLSK = [3.5 3 2.1 3.3 4.1 3.4 4.2 3.5];
dataNLSK = [6.4 3.9 3.5 4.8 3.1 4.5 7.6 3.6];

% net specs
nsE = wdmm86_e();
nsEI = wdmm86_ei();
nsED = wdmm86_ed();

% models and tasks
models = {'E', 'EI', 'ED'};
%tasks = {'LS', 'NLS'};

% parameters
% LR, exemplar LR, alpha, inhib wt, excit wt

lrs = [.25 .35 .65];
elrs = [.25 .6 1];
alphas = [1 1.5 2];
inws = [-1.5 -2 -3];
exws = [.5 .75 1];

% generate a matrix where each row is a combination of params
allparams = allcomb(lrs, elrs, alphas, inws, exws);

for ip=1:length(allparams),
    ps = allparams(ip,:);
    lr = ps(1); elr = ps(2); alpha = ps(3); inw = ps(4); exw = ps(5);
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
    
    for imodel = 1:3,
        if strcmp(models{imodel}, 'E'),
            ns = nsE;
        elseif strcmp(models{imodel}, 'EI'),
            ns = nsEI;
        else
            ns = nsED;
        end
        
        % this creates the data files in the out/ subdir
        wdmm86_run(ns, p, reps);
        
        % analyze the data
        
        % first LS condition
        cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-1-*.dat';
        [stat res] = unix(cmdline);
        LSerrs = sscanf(res, '%f');
        
        % if nsE, compare to dataLSU, otherwise to dataLSK
        if strcmp(models{imodel}, 'E'),
            LSMSE = sum((LSerrs(orderLS)' - dataLSU).^2)./length(dataLSU);
        else
            LSMSE = sum((LSerrs(orderLS)' - dataLSK).^2)./length(dataLSK);
        end
        
        % now the NLS condition
        cmdline = './wdmm86_item_errors.pl -terse out/log-train-trial-2-*.dat';
        [stat res] = unix(cmdline);
        NLSerrs = sscanf(res, '%f');
        
        % if nsE, compare to dataNLSU, otherwise to dataNLSK
        if strcmp(models{imodel}, 'E'),
            NLSMSE = sum((NLSerrs(orderNLS)' - dataNLSU).^2)./length(dataNLSU);
        else
            NLSMSE = sum((NLSerrs(orderNLS)' - dataNLSK).^2)./length(dataNLSK);
        end
        
        % output two lines, one for each task
        % model task lr inw alpha e1 e2 ... e10 mse
        
        fprintf(1, '%s %s %0.2f %0.2f %0.2f %0.2f %0.2f ', models{imodel}, 'LS', ...
            lr, elr, alpha, inw, exw);
        fprintf(1, '%0.3f ', LSerrs);
        fprintf(1, '%0.3f\n', LSMSE);
        
        fprintf(1, '%s %s %0.2f %0.2f %0.2f %0.2f %0.2f ', models{imodel}, 'NLS', ...
            lr, elr, alpha, inw, exw);
        fprintf(1, '%0.3f ', NLSerrs);
        fprintf(1, '%0.3f\n', NLSMSE);
        
    end
            
            
    
    
end


end
