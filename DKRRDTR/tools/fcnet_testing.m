function estimated = fcnet_testing(algo, X)
n = size(X,1);
if isempty(algo.fc_model) || n==0
    estimated = zeros(n,1);
else
    estimated = predict(algo.fc_model, X);
end
