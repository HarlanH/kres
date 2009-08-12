function sanityCheck( DS, verbosity )
%SANITYCHECK Check the dataset for inconsistencies.
%   First, display warnings if there are values other than -1, 0, or 1.
%   Then, find all pairs of headers of the form *0/*1, and make sure they
%   sum to 0. 
%   Default verbosity is 1. If 0, only do the second check.

% default
if nargin == 1,
    verbosity = 1;
end

% warnings for unusual inputs
if (verbosity == 1),
   numunusual = sum(sum(((DS.data == -1) + (DS.data == 1) + (DS.data == 0)) == 0));
   
   if (numunusual > 0)
       warning('KRES:Kdataset:sanityCheck', '%d Non-(-1,1,0) elements found in dataset!', numunusual);
   end
end

% find pairs, check for sum
seen = zeros(length(DS.header),1);
for i = 1:length(DS.header),
    % if this was part of an earlier set, ignore
    if (seen(i) == 1), 
        continue;
    end
    
    seen(i) = 1;
    
    % get prefix
    leftH = DS.header(i);
    % strip digits
    leftHPrefix = regexp(leftH, '\D', 'match');
    leftHPrefix = char(leftHPrefix{1});    % cell array -> string, grr.
    
    % get the column vector, and sum
    Hsum = DS.data(:,i);
    
    % look at further-right elements
    solo = 1;
    for j = i+1:length(DS.header),
        rightH = DS.header(j);
        rightHPrefix = regexp(rightH, '\D', 'match');
        rightHPrefix = char(rightHPrefix{1});
        
        if (leftHPrefix == rightHPrefix),
            % bingo!
            seen(j) = 1;    % mark it
            solo = 0;
            Hsum = Hsum + DS.data(:,j);
            
        end
    end
       
    % OK, we've got a set. Hsum better be 0s.
    if (~isequal(Hsum, zeros(size(Hsum))) && ~solo),
        warning('KRES:dataset:sanityCheck', 'Set "%s" does not sum to 0!', leftHPrefix);
    end
end
        
        
    
