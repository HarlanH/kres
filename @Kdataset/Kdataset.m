function [ DS ] = Kdataset( infilename )
%KDATASET Constructor for KRES dataset object
%   Loads the file into this internal data structure.

% Strip out the header line into a string array. Remove + from headers,
% storing in a list of target column indexes.
% Store everything else as a simple matrix.
% possibly:
% create hashes for the columns?

[fid, msg] = fopen(infilename, 'r');

if (fid == -1)
    error('KRES:Kdataset:Kdataset', 'File open error: %s: %s', infilename, msg);
end

% get the header field names
% this would be much easier in Perl...
headerline = fgetl(fid);
DS.header = [];
DS.targets = [];
DS.targetidxs = [];
DS.targetmask = [];
i = 1;
numtargets = 0;
while true,
    % get the next token only, with strtok...
   [str, headerline] = strtok(headerline, ', ');
   if isempty(str),  break;  end
   
   % if this is a target, strip the + and store the info
   DS.targetmask(i) = 0;
   if (strfind(str, '+')),
       str = strrep(str, '+', '');
       numtargets = numtargets + 1;
       DS.targets{numtargets} = str;
       DS.targetidxs = [DS.targetidxs, i];
       DS.targetmask(i) = 1;
   end
   
   DS.header{i} = str;
   
   i = i + 1;
end

% loop over the rest, and dump it into a matrix
DS.data = [];
nextline = fgetl(fid);
while (nextline ~= -1),
    % collect into a row vector, then append to matrix
    newrow = [];
    while true,
        [str, nextline] = strtok(nextline, ', ');
        if isempty(str), break; end
        
        newrow = [newrow str2num(str)]; 
    end
    DS.data = [DS.data; newrow];

    nextline = fgetl(fid);
end

% close the file
fclose(fid);

% further post-processing?

% make it a class!
DS = class(DS, 'Kdataset');
