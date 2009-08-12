function display( P )
%DISPLAY Display of Params object.

% get a cell array of field names
fields = sort(fieldnames(P));

for f = 1:length(fields),
    disp(fields(f));
    disp(P.(char(fields(f))));
    
    %fprintf(1, '%s = %s\n', char(fields(f)), P.(char(fields(f))));
end
