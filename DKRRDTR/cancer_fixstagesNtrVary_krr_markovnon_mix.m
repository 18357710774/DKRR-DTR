% S-KRR-DTR with the selected parameters  (non-markov case)

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
mCross = 2:2:100;
n_test = 1000;                        % the number of testing samples
ExNum = 100;                          % the number of simulations

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

loadfile = [cd '\SynResults\cancer_fixstagesNtrVary_' ...
            opt.algoname  '_markovnon_paraSel.mat'];

load(loadfile, 'lambda_opt_all', 'sigma_opt_all', 'n_train_seq');

savefile = [cd '\SynResults\cancer_fixstagesNtrVary_' ...
            opt.algoname  '_markovnon_baseline.mat'];

e_test = example;
e_test.n = n_test;

CSP_mean = zeros(opt.num_stages+1, length(mCross), ExNum);
W_mean = zeros(opt.num_stages+1, length(mCross), ExNum);
M_mean = zeros(opt.num_stages+1, length(mCross), ExNum);
WM_mean = zeros(opt.num_stages+1, length(mCross), ExNum);
R_mean = zeros(opt.num_stages, length(mCross), ExNum);
Death_mean = zeros(opt.num_stages+1, length(mCross), ExNum);
Cured_mean = zeros(opt.num_stages+1, length(mCross), ExNum);
AtRisk_mean = zeros(opt.num_stages+1, length(mCross), ExNum);

train_time = zeros(opt.num_stages, length(mCross), ExNum);
test_time = cell(ExNum, length(mCross));

kk = 0;
for m = mCross
    kk = kk+1;
    n_train = ceil(20000/m);
    e_train = example;
    e_train.n = n_train;

    % % ------------------- Set parameters ranges --------------------------
    ind_n = find(n_train_seq==n_train);    
    opt.algoparams(1) = sigma_opt_all(ind_n);          % KRR: the fisrt parameter is width of kernel, 
    opt.algoparams(2) = lambda_opt_all(ind_n);         %      the second parameter is regularization

    for Ex = 1:ExNum
        e_train.seed = Ex;
        e_test.seed = Ex;
    
        t1 = clock;
        qt = cancer_fixstages_generate(e_train, opt);    
        [valgo, ~, train_time_tmp] = cancer_vfunction_training(qt, opt);   
        train_time(:, kk, Ex) = train_time_tmp;
    
        [CSP_tmp, test_time_tmp, W_tmp, M_tmp, WM_tmp, R_tmp, Death_tmp, Cured_tmp, AtRisk_tmp] = ...
                                cancer_example_dynamics_allstages(valgo, e_test, opt);
        CSP_mean(:, kk, Ex) = CSP_tmp;
        W_mean(:, kk, Ex) = W_tmp;
        M_mean(:, kk, Ex) = M_tmp;
        WM_mean(:, kk, Ex) = WM_tmp;
        R_mean(:, kk, Ex) = R_tmp;
        Death_mean(:, kk, Ex) = Death_tmp;
        Cured_mean(:, kk, Ex) = Cured_tmp;
        AtRisk_mean(:, kk, Ex) = AtRisk_tmp;
        test_time{Ex, kk} = test_time_tmp;
        t2 = clock;
        t = etime(t2, t1);
    
        disp(['ntr#' num2str(n_train) '   Ex#' num2str(Ex)  ...
             '   CSP_mean=' num2str(CSP_mean(end, kk, Ex)) ...
             '   WM_mean=' num2str(WM_mean(end, kk, Ex)) ...
             '   time_cost=' num2str(t) 'seconds']);
    end
    save(savefile, 'example', 'n_train_seq', 'n_test', 'ExNum','opt', ...
           'CSP_mean', 'W_mean', 'M_mean', 'WM_mean', 'R_mean', ...
           'Death_mean', 'Cured_mean', 'AtRisk_mean', ...
           'train_time', 'test_time');
end

train_time_results.time_stages = train_time;
train_time_results.time_total = squeeze(sum(train_time, 1));
train_time_results.time_total_mean = mean(train_time_results.time_total, 2);
train_time_results.time_total_std = std(train_time_results.time_total, [], 2);

test_time_action_predict = zeros(opt.num_stages, length(mCross), ExNum);
test_time_state_compute = zeros(opt.num_stages, length(mCross), ExNum);
for kk = 1:length(mCross)
    for Ex = 1:ExNum
        for i = 1:opt.num_stages
            test_time_action_predict(i,kk,Ex) = test_time{Ex, kk}(i).time_action_predict;
            test_time_state_compute(i, kk,Ex) = test_time{Ex, kk}(i).time_state_compute;
        end
    end
end

test_time_results.time_action_predict = test_time_action_predict;
test_time_results.time_state_compute = test_time_state_compute;
test_time_results.time_action_predict_mean = mean(test_time_action_predict, 3);
test_time_results.time_state_compute_mean = mean(test_time_state_compute, 3);
test_time_results.time_total = sum(test_time_action_predict+test_time_state_compute, 1);
test_time_results.time_total_mean = mean(test_time_results.time_total);
test_time_results.time_total_std = std(test_time_results.time_total);

CSP_mean_Exmean = mean(CSP_mean, 3);
W_mean_Exmean = mean(W_mean, 3);
M_mean_Exmean = mean(M_mean, 3);
WM_mean_Exmean = mean( WM_mean, 3);
R_mean_Exmean = mean(R_mean, 3);
Death_mean_Exmean = mean(Death_mean, 3);
Cured_mean_Exmean = mean(Cured_mean, 3);
AtRisk_mean_Exmean = mean(AtRisk_mean, 3);
    
save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'CSP_mean', 'W_mean', 'M_mean', 'WM_mean', 'R_mean', ...
               'Death_mean', 'Cured_mean', 'AtRisk_mean', ...
               'CSP_mean_Exmean', 'W_mean_Exmean', 'M_mean_Exmean', ...
               'WM_mean_Exmean','R_mean_Exmean', 'Death_mean_Exmean',...
               'Cured_mean_Exmean', 'AtRisk_mean_Exmean',...
               'train_time_results', 'test_time_results');

