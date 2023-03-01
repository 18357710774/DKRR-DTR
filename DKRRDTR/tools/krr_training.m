function algo = krr_training(X, T, sigma, lambda)

KerPara.KernelType = 4;
KerPara.para = sigma;
% alphaj = krr_training_inner(X, T, lambda, KerPara);  

N = size(X, 1);
% Compute K(x,x') on training set  
Ktr = KernelComputation(X, X, KerPara);
Ktr = (Ktr+Ktr')/2;

% Compute alpha
alphaj = (Ktr + lambda*eye(N)*N)^(-1)*T;

algo.x = X;
algo.alpha = alphaj;
algo.sigma = sigma;
algo.lambda = lambda;



