function qdata = q_data(X,Y) 

qdata.X = []; 
qdata.Y = [];
qdata.index = []; 
qdata.findex = [];

if nargin >= 1 
    qdata.X = X; 
    qdata.index = 1:size(X,1);
    qdata.findex = 1:size(X,2);
end
if nargin >= 2 
    qdata.Y = Y; 
end