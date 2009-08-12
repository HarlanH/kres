function [ K ] = kres( NS, P )
%KRES Constructor of KRES object, given netspec and parameters.
%   A kres object has the following fields:
%       nodeTree - node tree of node labels (from NS)
%       nodes - flat cell array of node labels, in order
%       w - weight matrix
%       wCHL - binary matrix of learnable weights
%       wExemp - binary matrix of exemplar weights
%       bias - array of node biases

if nargin < 2,
    error('KRES:kres:kres', 'Not enough arguments to kres constructor!');
end

% copy in nodeTree
K.nodeTree = NS.nodes;

% flatten nodeTree->nodes
K.nodes = tree2leaves(K.nodeTree);

% this will be a list of connections, mostly for the benefit of logging
K.cons = [];

% construct empty weight matrix (and wCHL/wExemp matricies)
% matricies are the size of K.nodes squared
K.w = zeros(length(K.nodes));
K.wCHL = zeros(length(K.nodes));
K.wExemp = zeros(length(K.nodes));

% activation matricies
K.minusAct = [];
K.plusAct = [];

% stuff for exemplar nodes
% first, a list of indexes into the node list of future exemplar nodes
K.exempNodeIdxs = [];
K.exempActivated = 0; % count
% delta matrixes 
K.exempCHL = zeros(size(K.wCHL)); % CHL connections for a reserved exemplar node
K.exempExemp = zeros(size(K.wExemp)); % Exemplar-update connections for a reserved exemplar node

% do fancy algorithm to fill in weight matrix

% iterate over connections
for c = 1:length(NS.cons),
    % foreach connection, expand the to and from
    toList = tree2leaves(subtree(K.nodeTree, NS.cons(c).to));
    fromList = tree2leaves(subtree(K.nodeTree, NS.cons(c).from));
    
    % if one of the lists is 'E', we'll want to keep a copy of that for
    % later.
    if strcmp(NS.cons(c).to, 'E'),
        K.exempNodeIdxs = getNodeIdx(K, toList);
    elseif strcmp(NS.cons(c).from, 'E'),
        K.exempNodeIdxs = getNodeIdx(K, fromList);
    end
    
    if strcmp(NS.cons(c).spread, 'full'),
        % we'll fill in all pairs of the paired lists
        for toNode = 1:length(toList),
            for fromNode = 1:length(fromList),
                % we've got indexes in toList and fromList, but we need
                % indexes into K.nodes
                toNodeIdx = getNodeIdx(K, toList(toNode));
                fromNodeIdx = getNodeIdx(K, fromList(fromNode));
                
                % no self-connections!
                if (toNodeIdx ~= fromNodeIdx),
                    % store the connections for use by logging
                    K.cons(length(K.cons)+1).from = char(fromList(fromNode));
                    K.cons(length(K.cons)).to = char(toList(toNode));

                    setWeights(fromNodeIdx, toNodeIdx);
                end
            end
        end
        
    else % spread eq 121
        % just a bijection
        if (length(toList) ~= length(fromList)),
            error('KRES:kres:kres', 'Connection #%d is one-to-one, but sizes are different!', c);
        end
        
        for nodeIdx = 1:length(toList),
            % again, we've got indexes in toList etc, need into K.nodes
            toNodeIdx = getNodeIdx(K, toList(nodeIdx));
            fromNodeIdx = getNodeIdx(K, fromList(nodeIdx));
            
            % no self-connections!
            if (toNodeIdx ~= fromNodeIdx),
                % store the connections for use by logging
                K.cons(length(K.cons)+1).from = char(fromList(nodeIdx));
                K.cons(length(K.cons)).to = char(toList(nodeIdx));

                setWeights(fromNodeIdx, toNodeIdx);
            end
        end
    end
    
    %disp(c);
    %disp(toList);
    %disp(fromList);
end

% construct bias array
K.bias = zeros(size(K.nodes));
for b = 1:max(size(NS.bias)),
    % foreach bias, expand the node
    nodeList = tree2leaves(subtree(K.nodeTree, NS.bias(b).node));
    
    for nodeIdx = 1:length(nodeList),
        idx = getNodeIdx(K, nodeList(nodeIdx));
        K.bias(idx) = NS.bias(b).value;
    end
end


% stuff for logging
K.log.ACoherence = 0;
% use minusAct and plusAct for activations
K.log.ASSE = 0;
K.log.Coherence = 0;
K.log.DW = 0;
K.log.Input = [];
K.log.Outputs = [];
K.log.SettleTime = 0;
K.log.SSE = 0;
% weights we got!


% all constructed -- make it a class and we're done!
K = class(K, 'kres');






% this is a *nested* function, not a *subfunction*, for scoping purposes
    function setWeights(fromN, toN)
        % set w matrix
        % value is conditional
        switch NS.cons(c).init
            case 'in'
                wval = getInWeight(P);
            case 'ex'
                wval = getExWeight(P);
            case 'rand'
                wval = rand(1)*getRandWeight(P)*2 - getRandWeight(P);
            otherwise
                if isnumeric(NS.cons(c).init),
                    wval = NS.cons(c).init;
                else
                    wval = 0;
                end
        end
        
        if strcmp(NS.cons(c).type, 'exemp'),
            % actually, don't use wval now...
            wval = 0;
            % instead, add this to exempExemp
            K.exempExemp(fromN,toN) = 1;
            K.exempExemp(toN,fromN) = 1;
        end
        
        if strcmp(NS.cons(c).type, 'exempchl'),
            % for CHL connections to exemplar nodes, put wval into the
            % exempCHL matrix, but then reset to 0, so it doesn't go into
            % the weight matrix yet.
            K.exempCHL(fromN,toN) = wval;
            K.exempCHL(toN,fromN) = wval;
            wval = 0;
        end
                
        K.w(fromN,toN) = wval;
        K.w(toN,fromN) = wval;

        % if type eq chl, set wCHL
        if strcmp(NS.cons(c).type, 'chl'),
            K.wCHL(fromN,toN) = 1;
            K.wCHL(toN,fromN) = 1;
        end

        % wExemp is set only when exemplar nodes are used
    end

    

end % main function


