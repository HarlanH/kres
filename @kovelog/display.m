function display(L)
% DISPLAY a log object

fprintf(1, 'Outfilename: %s\n', L.outfilename);

fprintf(1, 'maxHid: %d\n', L.maxHid);

fprintf(1, 'counter: %d\n', L.counter);

fprintf(1, 'iEpoch: %d\n', L.iEpoch);

ft = {'false', 'true'};

fprintf(1, 'bInput: %s\n', ft{L.bInput+1});
fprintf(1, 'bTarget: %s\n', ft{L.bTarget+1});
fprintf(1, 'bActivations: %s\n', ft{L.bActivations+1});
fprintf(1, 'bPrK: %s\n', ft{L.bPrK+1});
fprintf(1, 'bSSE: %s\n', ft{L.bSSE+1});
fprintf(1, 'bASSE: %s\n', ft{L.bASSE+1});
fprintf(1, 'bH: %s\n', ft{L.bH+1});
fprintf(1, 'bW: %s\n', ft{L.bW+1});
fprintf(1, 'bAlpha: %s\n', ft{L.bAlpha+1});
