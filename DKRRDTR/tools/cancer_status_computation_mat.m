function [Wa, Ma, R, AtRiska, Deatha, Cureda] =  cancer_status_computation_mat(W, W0, M, M0, example, A, AtRisk, Death, Cured)
                            
n_col = size(M,2);
M0m = repmat(M0, 1, n_col);
W0m = repmat(W0, 1, n_col);

Wa = W + example.states(1,1)*max(M, M0m)...
        + example.states(1,2)*(A-example.states(1,3));                       % W(t+1) = W(t) + example.states(1,1)*max(M(:,t), M(:,1)) + example.state(1,2)*(A(:,t)-example.state(1,3))


Ma = M + (example.states(2,1)*max(W, W0m)... 
        - example.states(2,2)*(A-example.states(2,3))).*double(M>0);         % M(t+1) = M(t) + example.states(2,1)*max(W(:,t), W(:,1)) - example.state(2,2)*(A(:,t)-example.state(2,3))
Ma = Ma.*double(Ma>0);

delta_lambda = exp(example.mu(1)+example.mu(2)*Wa+example.mu(3)*Ma);   % lambda(s) = exp(mu0+mu1*W(s)+mu2*M(s))  for s \in (t-1, t]
                                                                       % delta_lambda(t) = integral_{t-1}^t lambda(s)ds
death_p = 1 - exp(-delta_lambda);                                      % the death probability: p = 1-exp(-delta_lambda(t))

randnumber = rand(example.n, n_col);

Deatha = Death | (Cured & (randnumber <= death_p)) ...                 % the patient with tumor size equalling to zero also has the probability of death
               | (AtRisk & (randnumber <= death_p));                   % the patient with tumor size larger than zero has the probability of death

Cureda = (Cured & (randnumber > death_p)) |  ...                       % the patient with tumor size equalling to zero (i.e., cured patient) survivals
         (AtRisk & (randnumber > death_p) & (Ma==0));                  % uncured patient (not dead) at last stage is cured in current stage

AtRiska = AtRisk & (randnumber > death_p) & Ma>0;        
                                      
R = reward_compute_mat({W, Wa}, {M, Ma}, AtRiska, Deatha, Cureda, example);




 

    