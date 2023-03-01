% S-KRR-DTR with the selected parameters  (single + separate case)

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
mCross = 5:5:500;
n_test = 1000;                       % the number of testing samples
ExNum = 500;                         % the number of simulations

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
opt.fea_mode = 'markov_single';
opt.action_mode = 'separate'; 
opt.num_stages = 3;
opt.algoname = 'krr';

loadfile = [cd '\SynResults\clinical_flexiblestagesNtrVary_' ...
            opt.algoname  '_markovsingle_separ_paraSel.mat'];

load(loadfile, 'lambda_opt_all', 'sigma_opt_all', 'n_train_seq');

savefile = [cd '\SynResults\clinical_flexiblestagesNtrVary_' ...
            opt.algoname  '_markovsingle_separ' '_baseline.mat'];

e_test = example;
e_test.n = n_test;

mean_time_hat = zeros(ExNum, length(mCross));
mean_trial_hat = zeros(ExNum, length(mCross));
mean_actions_hat = zeros(ExNum, length(mCross));

train_time = zeros(opt.num_stages, length(mCross), ExNum);
test_time = cell(ExNum, length(mCross));

kk = 0;
for m = mCross
    kk = kk+1;
    n_train = ceil(10000/m);
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
        qt = clinical_flexstages_generate(e_train, opt);    
        [valgo, ~, train_time_tmp] = vfunction_training(qt, opt); 
        train_time(:, kk, Ex) = train_time_tmp;
        
        [time_hat_tmp, test_time_tmp, actions_hat_tmp, trial_hat_tmp] ... 
                                 = example_dynamics(valgo, e_test, opt);
        mean_time_hat(Ex, kk) = mean(time_hat_tmp);
        mean_trial_hat(Ex, kk) = mean(trial_hat_tmp);
        mean_actions_hat(Ex, kk) = mean(actions_hat_tmp);
        test_time{Ex, kk} = test_time_tmp;
        t2 = clock;
        t = etime(t2, t1);
    
        disp(['ntr#' num2str(n_train) '   Ex#' num2str(Ex)  ...
            '   mean_time_hat=' num2str(mean_time_hat(Ex, kk)) ...
             '   time_cost=' num2str(t) 'seconds']);      
    end
    save(savefile, 'example', 'n_train_seq', 'n_test', 'ExNum','opt', ...
                   'mean_time_hat', 'mean_trial_hat', ...
                   'mean_actions_hat', 'train_time', 'test_time');
end

train_time_results.time_stages = train_time;
train_time_results.time_total = squeeze(sum(train_time, 1));
train_time_results.time_total_mean = mean(train_time_results.time_total,2);
train_time_results.time_total_std = std(train_time_results.time_total,[],2);

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
test_time_results.time_total = squeeze(sum(test_time_action_predict+test_time_state_compute, 1));
test_time_results.time_total_mean = mean(test_time_results.time_total,2);
test_time_results.time_total_std = std(test_time_results.time_total,[],2);

m_mean_time_hat = mean(mean_time_hat, 1);
m_mean_trial_hat = mean(mean_trial_hat, 1);
m_mean_actions_hat = mean(mean_actions_hat, 1);

save(savefile, 'example', 'n_train_seq', 'n_test', 'ExNum', 'opt', ...
               'mean_time_hat', 'm_mean_time_hat', ...
               'mean_trial_hat', 'm_mean_trial_hat', ...
               'mean_actions_hat', 'm_mean_actions_hat', ...
               'train_time_results', 'test_time_results');