function estimated = fcnet_testing(algo, X)
n = size(X,1);
if isempty(algo.fc_model) || n==0
    estimated = -ones(n,1)*inf;
else
    estimated = predict(algo.fc_model, X);
end