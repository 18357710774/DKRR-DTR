function [Nvec, indjCell] = EqualSplitData(Ntr, m)   

idxrand = randperm(Ntr);
Nvec = zeros(m,1);
indjCell = cell(m,1);
n = floor(Ntr/m); 
idx_begin = 0;
for k = 1:m-1
    Nvec(k) = n;
    indjCell{k} = idxrand(idx_begin+1:idx_begin+n);
    idx_begin = idx_begin + n;
end
Nvec(m) = Ntr-n*(m-1);
indjCell{m} = idxrand(idx_begin+1:end);