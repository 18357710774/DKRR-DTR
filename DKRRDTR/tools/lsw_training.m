function algo = lsw_training(X, T)

[n,p] = size(X);
w = ones(n,1);
    
A = [ones(n,1),X];
if rank(A)<p+1
    sol = pinv(A'*diag(w)*A)*A'*diag(w)*T;
else
    sol = lscov(A,T);
end
algo.b0 = sol(1);
algo.beta = sol(2:end);
