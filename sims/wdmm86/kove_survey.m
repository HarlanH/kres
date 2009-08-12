function kove_survey(samples)
% KOVE_SURVEY Survey the parameter space of the KOVE/EI, KRES/ED, and
% KRES/EW models on the Wattenmaker et al. task. Use a Sobel sequence to
% find parameters within a specified region. For each parameter set,
% run 3 times for each model. For each model
% and parameter set, give the actual error counts, plus an ordering for
% LS/U,LS/K,NLS/U,NLS/K, ala [4 3 1 2], which is the target count. If
% errors are separated by less than 10%, count it as a tie, ala [1 1 1 1].

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

% models and tasks
models = {'E', 'EI', 'ED', 'EW'};
%tasks = {'LS', 'NLS'};

% parameter ranges
% LR, c, phi, knowledge param (.01 to .99, scale for KOVE/EI)

psize = [1 5 3 .98];
poffset = [.01 .1 .1 .01];

% random parameter generator
hset = haltonset(4, 'Skip', 1e3, 'Leap', 37);
hset = scramble(hset, 'RR2');
pstream = qrandstream(hset);

for i=1:samples,
    % get random parameters in [0 1], then scale to be in the interval
    ps = qrand(pstream,1) .* psize + poffset;
    lr = ps(1); c = ps(2); phi = ps(3); kp = ps(4);
    
    % generate a model of each
    m = cell(4,1);
    m{1} = kove_ei(0);
    m{2} = kove_ei(kp*10);
    m{3} = kove_ed(kp);
    m{4} = kove_ew(kp);
    
    trainErrs = cell(4,1);
    
    for j = 1:4,
        % assign constant parameters
        m{j}.lambdaW = lr;
        m{j}.c = c;
        m{j}.phi = phi;
        
        % run the model
        trainErrs{j} = kove_run(m{j}, 3);
    end
    
    % print the model, the parameters, the four error counts, and the
    % ordering. Note that we want the following order: LS/U, LS/K, NLS/U,
    % NLS/K.
    eiErrs = reshape([sum(trainErrs{1},2) sum(trainErrs{2},2)]', 4, 1);
    edErrs = reshape([sum(trainErrs{1},2) sum(trainErrs{3},2)]', 4, 1);
    ewErrs = reshape([sum(trainErrs{1},2) sum(trainErrs{4},2)]', 4, 1);
    
    fprintf(1, 'EI ');
    fprintf(1, '%0.2f ', ps);
    fprintf(1, '%0.2f ', eiErrs);
    fprintf(1, '%d ', orderelems(eiErrs, max(eiErrs)/10));
    fprintf(1, '\nED ');
    fprintf(1, '%0.2f ', ps);
    fprintf(1, '%0.2f ', edErrs);
    fprintf(1, '%d ', orderelems(edErrs, max(edErrs)/10));
    fprintf(1, '\nEW ');
    fprintf(1, '%0.2f ', ps);
    fprintf(1, '%0.2f ', ewErrs);
    fprintf(1, '%d ', orderelems(ewErrs, max(ewErrs)/10));
    fprintf(1, '\n');
    
    
    
end


end
