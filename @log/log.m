function [ L ] = log( outfilenameParam )
%LOG Constructor for log object.
%   Log object has the following fields (log objects in Hungarian notation):
%       outfilename
%       fid
%       iEpoch
%       bInput, bWeights, bActivations, bOutputs, bSSE, bASSE, bCoherence,
%       bACoherence, bSettleTime, bDW

L.outfilename = outfilenameParam;
[L.fid, msg] = fopen(L.outfilename, 'w');  % open in (over)write mode, which might be wrong

if (L.fid == -1),
    error('KRES:log:log', 'Error opening file "%s": %s', L.outfilename, msg);
end

L.counter = 0;  % number of times this log has been written to

L.iEpoch = 0;
L.bInput = false;
L.bWeights = false;
L.bActivations = false;
L.bOutputs = false;
L.bSSE = false;
L.bASSE = false;
L.bCoherence = false;
L.bACoherence = false;
L.bSettleTime = false;
L.bDW = false;

L = class(L, 'log');

