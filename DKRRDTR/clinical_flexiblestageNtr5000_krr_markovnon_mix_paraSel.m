% parameter selection step for krr (non-markov + joint case)
% the kernel width σ and the coefficient λ of ℓ2 regularization are tuned parameters

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
n_train = 5000;                      % the number of training samples
n_test = 1000;                       % the number of testing samples
ExNum = 100;                         % the number of simulations

% ------------------ The settings for generating trajectories -----------------------
example.actions = [0.5, 0.1;         % Constants in the eqations of wellness and tumor size for action A
                   0.25, 0.2];       % Constants in the eqations of wellness and tumor size for action B
                                     % The term in (30) of the paper should be replaced with T(u_i)/(5W(u_i))
example.Wdot = 0.5;                  % The dynamic for the wellness: W(t)=W(0)+(1-W(0))*(1-2^{-Wdot*time}) in eqaution (31)
example.c0 = 0.15;                   % The failure time distributed exp(example.c0*  (W+example.c1)/M
example.c1 = 2;
example.Mdot = 2; 
example.max = 5;                     % length of trial
example.failure = 0.2;               % The threshold of wellness for failure point

example = clinical_flexstages_params(example);

% ------------------ Set training mode ------------------------------
opt.fea_mode = 'markov_non';
opt.action_mode = 'mix'; 
opt.num_stages = 3;
opt.algoname = 'krr';

% ------------------- Set parameters ranges --------------------------
sigma_seq = exp(linspace(log(0.001), 0, 20));
m2 = 50;
q = 2;
lambda_seq = Lambda_q(q, q, m2);
lambda_seq(lambda_seq<1/(2*n_train)) = [];
para = zeros(2, length(sigma_seq)*length(lambda_seq));
count = 0;
for sigma = sigma_seq
    for lambda = lambda_seq
        count = count+1;
        para(:,count) = [sigma; lambda];        
    end
end

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end

savefile = [cd '\SynResults\clinical_flexiblestagesNtr' num2str(n_train) ...
            '_' opt.algoname  '_markovnon_mix' '_paraSel.mat'];

e_train = example;
e_train.n = n_train;
e_test = example;
e_test.n = n_test;

mean_time_hat = zeros(ExNum, size(para,2));

for Ex = 1:ExNum
    e_train.seed = Ex;
    e_test.seed = Ex;
    qt = clinical_flexstages_generate(e_train, opt);

    for k = 1:size(para,2)
        opt.algoparams(1) = para(1,k);         % KRR: the fisrt parameter is width of kernel, 
        opt.algoparams(2) = para(2,k);         %      the second parameter is regularization
        tic;
        valgo = vfunction_training(qt, opt);                        
        time_hat_tmp = example_dynamics(valgo, e_test, opt);
        mean_time_hat(Ex, k) = mean(time_hat_tmp);
        t = toc;
        disp(['Ex#' num2str(Ex)  '  sigma=' num2str(para(1,k)) '  lambda=' ...
             num2str(para(2,k))  '     mean_time_hat=' num2str(mean_time_hat(Ex, k)) ...
             '      time_cost=' num2str(t) 'seconds']);
    end
end
m_mean_time_hat = mean(mean_time_hat, 1);
[m_mean_time_hat_opt, ind_opt] = max(m_mean_time_hat);
sigma_opt = para(1,ind_opt);
lambda_opt = para(2,ind_opt);

save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', 'sigma_seq', ...
               'lambda_seq', 'para', 'mean_time_hat', 'm_mean_time_hat', ...
               'lambda_opt', 'sigma_opt');
