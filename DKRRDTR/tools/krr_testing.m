function estimated = krr_testing(algo, X)
n = size(X,1);
if isempty(algo.alpha) || n==0
    estimated = -ones(n,1)*inf;
else
    KerPara.KernelType = 4;
    KerPara.para = algo.sigma;
    train_x = algo.x;
    alpha = algo.alpha;                           
    
    Kte = KernelComputation(X, train_x, KerPara);
    estimated = Kte * alpha;
end