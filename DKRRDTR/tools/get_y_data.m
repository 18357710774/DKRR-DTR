function [retY] = get_y_data(d,ind,fInd)
 
%   get_y(DATA)         returns Y matrix of the data object 
%   get_y(DATA,INDEXES) returns Y matrix of the data object for given indexes
  
if (nargin==1) || isempty(ind)
    ind = 1:size(d.Y,1);  
end   
if nargin < 3 || isempty(fInd)
    fInd = 1:size(d.Y,2);
end
if ~isempty(d.Y)  
    retY = d.Y(ind,fInd);
else
    retY = []; 
end