function display( DS )
%DISPLAY Dataset object displayer

disp('Fields:');
disp(DS.header);
disp('Data:')
disp(DS.data)
disp('Targets:')
disp(DS.targets);
disp(DS.targetidxs);


