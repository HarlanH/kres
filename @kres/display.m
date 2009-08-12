function display( K )
%DISPLAY Display a KRES object.

%   A kres object has the following fields:
%       nodeTree - node tree of node labels (from NS)
%       nodes - flat cell array of node labels, in order
%       w - weight matrix
%       wCHL - binary matrix of learnable weights
%       wExemp - binary matrix of exemplar weights
%       bias - array of node biases

disp('Nodes:');
disp(K.nodes);
disp('Weights:');
disp(K.w);
disp('CHL Weights:');
disp(K.wCHL);
if (sum(sum(K.wExemp ~= 0)) > 0),
    disp('Exemplar Weights:');
    disp(K.wExemp);
end
if (sum(K.bias ~= 0) > 0),
    disp('Bias Weights:');
    disp(K.bias);
end
if (length(K.exempNodeIdxs) > 0),
    disp('Exemplar Node Indexes:');
    disp(K.exempNodeIdxs);
    disp('Exemplar Nodes Activated:');
    disp(K.exempActivated);
    disp('Reserved Exemplar CHL Connectivity:');
    disp(K.exempCHL);
    disp('Reserved Exemplar Connectivity:');
    disp(K.exempExemp);
end

