function L = close( L )
%CLOSE Close the log file.
%   To prevent errors from being thrown, fid is set to 2, stderr.

fclose(L.fid);
L.fid = 2;

