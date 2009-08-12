function [ L ] = kovelog( outfilenameParam, maxHid )
%KOVELOG Constructor for KOVE log object.
%   Log object has the following fields (log objects in Hungarian notation):
%       outfilename
%       fid
%       iEpoch
%       bInput, bTarget, bActivations, bPrK, bSSE, bASSE, bH, bW, bAlpha

L.outfilename = outfilenameParam;
[L.fid, msg] = fopen(L.outfilename, 'w');  % open in (over)write mode, which might be wrong

if (L.fid == -1),
    error('KOVE:kovelog:log', 'Error opening file "%s": %s', L.outfilename, msg);
end

% maximum hidden units to report
L.maxHid = maxHid;

L.counter = 0;  % number of times this log has been written to

L.iEpoch = 0;
L.bInput = false;
L.bTarget = false;
L.bActivations = false;
L.bPrK = false;
L.bSSE = false;
L.bASSE = false;
L.bH = false;
L.bW = false;
L.bAlpha = false;

L = class(L, 'kovelog');

