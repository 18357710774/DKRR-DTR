function Aret = expend_matrix(A,j)

if nargin == 1 
    j = 2;
end

Aret = repelem(A, 1, j);


% Aret = [];
% if nargin == 1 
%     j=2;
% end
% 
% for i = 1:size(A,2)
%     for k = 1:j
%         Aret = [Aret,A(:,i)];
%     end
% end