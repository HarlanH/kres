function display(K)
% DISPLAY 

% number of nodes
fprintf(1, 'Network structure: %d/%d-(%d,%d,%d)-%d\n\n', K.numFeats, K.numDims, ...
    K.hiddenFeats * K.numFeats, size(K.PK,1), K.numExemplars, K.numOut);

% matricies
disp('Input->Hidden weights:');
disp(K.h);

disp('Hidden->Output weights:');
disp(K.w);

disp('Attention weights');
disp(K.alpha);

