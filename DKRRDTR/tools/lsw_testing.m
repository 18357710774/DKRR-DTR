function estimated = lsw_testing(algo, X)

n = size(X,1);
if isempty(algo.beta) || n==0
    estimated = -ones(n,1)*inf;
else  
    estimated = X*algo.beta + ones(n,1)*algo.b0;
end

% U_sumU = get_y_data(dat);
% retdat = q_data(estimated, U_sumU); 