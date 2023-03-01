% parameter selection step for krr (non-markov case)
% the kernel width σ and the coefficient λ of ℓ2 regularization are tuned parameters

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
n_train_seq = ceil(20000./(2:2:100));   % the number of training samples
n_train_seq = unique(n_train_seq);
n_test = 1000;                          % the number of testing samples
ExNum = 20;                             % the number of simulations

% ------------------ The settings for generating trajectories -----------------------
example.states =  [0.1, 1.2, 0.5;       % Constants in the eqations of wellness and tumor size
                   0.15, 1.2, 0.5];       
example.mu = [-4.5, 1, 1];              % The cofficients in the hazard function \lambda(t)
example.c0 = 0.5;                       % The threshold in reward function
example.IW = [0, 2];                    % The endpoints of the interval for initial wellness
example.IM = [0, 2];                    % The endpoints of the interval for initial tumor size
example.actions1 = [0.5, 1];            % The endpoints of the interval for drug level at stage 1
example.actions2 = [0, 1];              % The endpoints of the interval for drug level at stage k (k>1)
example.increment = 0.01;               % The increments of discrete doge levels
example.death_r = -6;                   % The reward for death
example.cure_r = 1.5;                   % The reward for cured patient
example.other_r = 0.5;                  % The reward for other results  
example = clinical_fixstages_params(example);

% ------------------ Set training mode ------------------------------
opt.fea_mode = 'markov_non'; 
opt.action_mode = 'mix';
opt.num_stages = 6;
opt.algoname = 'krr';

% % ------------------- Set parameters ranges --------------------------
sigma_seq = exp(linspace(log(0.01), log(10), 20));
% sigma_seq(sigma_seq>5) = [];
% sigma_seq(sigma_seq<0.5) = [];
if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end

e_test = example;
e_test.n = n_test;

sigma_opt_all = zeros(1, length(n_train_seq));
lambda_opt_all = zeros(1, length(n_train_seq));
m_mean_CSP_hat_opt_all = zeros(1, length(n_train_seq));
m_mean_W_hat_opt_all = zeros(1, length(n_train_seq));
m_mean_M_hat_opt_all = zeros(1, length(n_train_seq));
m_mean_WM_hat_opt_all = zeros(1, length(n_train_seq));

kk = 0;
for n_train = n_train_seq
    kk = kk+1;
    e_train = example;
    e_train.n = n_train;

    m2 = 50;
    q = 2;
    lambda_seq = Lambda_q(q, q, m2);
    lambda_seq(lambda_seq<1/(10*n_train)) = [];
    lambda_seq(lambda_seq>100/n_train) = [];
    para = zeros(2, length(sigma_seq)*length(lambda_seq));
    count = 0;
    for sigma = sigma_seq
        for lambda = lambda_seq
            count = count+1;
            para(:,count) = [sigma; lambda];        
        end
    end

    savefile = [cd '\SynResults\cancer_fixstagesNtr' num2str(n_train) ...
                '_' opt.algoname  '_markovnon_paraSel.mat'];

    mean_CSP_hat = zeros(ExNum, size(para,2));
    mean_W_hat = zeros(ExNum, size(para,2));
    mean_M_hat = zeros(ExNum, size(para,2));
    mean_WM_hat = zeros(ExNum, size(para,2));
    
    for Ex = 1:ExNum
        e_train.seed = Ex;
        e_test.seed = Ex;
        qt = cancer_fixstages_generate(e_train, opt);
    
        for k = 1:size(para,2)
            opt.algoparams(1) = para(1,k);         % KRR: the fisrt parameter is width of kernel, 
            opt.algoparams(2) = para(2,k);         %      the second parameter is regularization
            t1 = clock;        
            valgo = cancer_vfunction_training(qt, opt);                 
            [CSP_tmp, ~, W_tmp, M_tmp, WM_tmp] = cancer_example_dynamics(valgo, e_test, opt);
            mean_CSP_hat(Ex, k) = CSP_tmp;
            mean_W_hat(Ex, k) = mean(W_tmp);
            mean_M_hat(Ex, k) = mean(M_tmp);
            mean_WM_hat(Ex, k) = mean(WM_tmp);
            t2 = clock;
            t = etime(t2, t1);     
            disp(['ntr#' num2str(n_train)  '   Ex#' num2str(Ex) '  sigma=' num2str(para(1,k)) ...
                  '  lambda=' num2str(para(2,k))  '  mean_CSP_hat=' num2str(mean_CSP_hat(Ex, k)) ...
                  '  mean_WM_hat=' num2str(mean_WM_hat(Ex, k)) '  time_cost=' num2str(t) 'seconds']);                
        end
    end
    m_mean_CSP_hat = mean(mean_CSP_hat, 1);
    m_mean_W_hat = mean(mean_W_hat, 1);
    m_mean_M_hat = mean(mean_M_hat, 1);
    m_mean_WM_hat = mean(mean_WM_hat, 1);
    
    [m_mean_CSP_hat_opt, ind_opt] = max(m_mean_CSP_hat);
    sigma_opt = para(1,ind_opt);
    lambda_opt = para(2,ind_opt);
    m_mean_W_hat_opt = m_mean_W_hat(ind_opt);
    m_mean_M_hat_opt = m_mean_M_hat(ind_opt);
    m_mean_WM_hat_opt = m_mean_WM_hat(ind_opt);

    sigma_opt_all(kk) = sigma_opt;
    lambda_opt_all(kk) = lambda_opt;
    m_mean_CSP_hat_opt_all(kk) = m_mean_CSP_hat_opt;
    m_mean_W_hat_opt_all(kk) = m_mean_W_hat_opt;
    m_mean_M_hat_opt_all(kk) = m_mean_M_hat_opt;
    m_mean_WM_hat_opt_all(kk) = m_mean_WM_hat_opt;
    
    save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', 'para', ...
                   'sigma_seq','lambda_seq', 'lambda_opt', 'sigma_opt',...         
                   'mean_CSP_hat', 'm_mean_CSP_hat', 'm_mean_CSP_hat_opt', ...
                   'mean_W_hat', 'm_mean_W_hat', 'm_mean_W_hat_opt', ...
                   'mean_M_hat', 'm_mean_M_hat', 'm_mean_M_hat_opt', ... 
                   'mean_WM_hat', 'm_mean_WM_hat', 'm_mean_WM_hat_opt');
    clear lambda_seq para lambda_opt sigma_opt mean_CSP_hat m_mean_CSP_hat ...
          m_mean_CSP_hat_opt mean_W_hat m_mean_W_hat m_mean_W_hat_opt ...
          mean_M_hat m_mean_M_hat m_mean_M_hat_opt mean_WM_hat ... 
          m_mean_WM_hat m_mean_WM_hat_opt
end
savefile = [cd '\SynResults\cancer_fixstagesNtrVary_' ...
            opt.algoname  '_markovnon_paraSel.mat'];

save(savefile, 'example', 'n_train_seq', 'n_test', 'ExNum', 'opt', ...
               'lambda_opt_all', 'sigma_opt_all', 'm_mean_CSP_hat_opt_all',...
               'm_mean_W_hat_opt_all', 'm_mean_M_hat_opt_all', ...
               'm_mean_WM_hat_opt_all');