% DLS-DTR with the selected parameters  (multi + joint case)

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
n_train = 10000;                     % the number of training samples
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
opt.fea_mode = 'markov_multi';
opt.action_mode = 'mix'; 
opt.num_stages = 3;
opt.algoname = 'ls';
opt.split_mode = 'equal';
mCross = 5:5:500;

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end
savefile = [cd '\SynResults\distributed_clinical_flexstageNtr' num2str(n_train) ...
            '_' opt.algoname  '_markovmulti_mix_varym_Usplit.mat'];

e_train = example;
e_train.n = n_train;
e_test = example;
e_test.n = n_test;

mean_time_hat = zeros(ExNum, length(mCross));
mean_trial_hat = zeros(ExNum, length(mCross));
mean_actions_hat = zeros(ExNum, length(mCross));

train_time = cell(ExNum, length(mCross));
test_time = cell(ExNum, length(mCross));

for kk = 1:length(mCross)
    opt.num_machines = mCross(kk);   

    for Ex = 1:ExNum
        e_train.seed = Ex;
        e_test.seed = Ex;

        t1 = clock;
        qt = distributed_clinical_flexstages_generate(e_train, opt);    
        [vf, ~, train_time_tmp] = distributed_vfunction_training(qt, opt); 
        train_time{Ex,kk} = train_time_tmp;
        [time_hat_tmp, test_time_tmp, trial_hat_tmp, actions_hat_tmp] ... 
                                   = distributed_example_dynamics(vf, e_test, opt);
        mean_time_hat(Ex, kk) = mean(time_hat_tmp);
        mean_trial_hat(Ex, kk) = mean(trial_hat_tmp);
        mean_actions_hat(Ex, kk) = mean(actions_hat_tmp);
        test_time{Ex,kk} = test_time_tmp;
        t2 = clock;
        t = etime(t2, t1);
    
        disp(['local_machines#' num2str(opt.num_machines) ...
            '   Ex#' num2str(Ex)  '  mean_time_hat=' num2str(mean_time_hat(Ex)) ...
             '      time_cost=' num2str(t) 'seconds']);
    end
    save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'mCross', 'mean_time_hat', 'mean_trial_hat', ...
               'mean_actions_hat', 'train_time', 'test_time');
end

train_time_results = struct('time_local', {}, 'time_synthesize',{}, ...
                            'time_local_mean', {}, 'time_synthesize_mean', {}, ...
                            'time_total_mean', {});

test_time_results = struct('time_local', {}, 'time_synthesize',{}, ...
                           'time_state_compute', {},  'time_local_mean', {}, ...
                           'time_synthesize_mean', {}, 'time_state_compute_mean', {}, ...
                           'time_total_mean', {});

train_time_total_mean = zeros(1, length(mCross));
train_time_local_mean = zeros(1, length(mCross));
train_time_synthesize_mean = zeros(1, length(mCross));
test_time_total_mean = zeros(1, length(mCross));

for kk = 1:length(mCross)
    train_time_local = zeros(opt.num_stages, mCross(kk), ExNum);
    train_time_synthesize = zeros(opt.num_stages, ExNum);
    test_time_local = zeros(opt.num_stages, mCross(kk), ExNum);
    test_time_synthesize = zeros(opt.num_stages, ExNum);
    test_time_state_compute = zeros(opt.num_stages, ExNum);
    for Ex = 1:ExNum
        for i = 1:opt.num_stages
            train_time_local(i,:,Ex) = train_time{Ex, kk}(i).time_local;
            train_time_synthesize(i, Ex) = train_time{Ex, kk}(i).time_synthesize;
            test_time_local(i,:,Ex) = test_time{Ex, kk}(i).time_local;
            test_time_synthesize(i, Ex) = test_time{Ex, kk}(i).time_synthesize;
            test_time_state_compute(i, Ex) = test_time{Ex, kk}(i).time_state_compute;
        end
    end

    train_time_results(kk).time_local = train_time_local;
    train_time_results(kk).time_synthesize = train_time_synthesize;
    train_time_results(kk).time_local_mean = mean(mean(train_time_local, 3), 2);
    train_time_results(kk).time_synthesize_mean = mean(train_time_synthesize, 2);
    train_time_results(kk).time_total_mean = sum(train_time_results(kk).time_local_mean + ...
                                                 train_time_results(kk).time_synthesize_mean);
    train_time_total_mean(kk) = train_time_results(kk).time_total_mean;
    train_time_local_mean(kk) = sum(train_time_results(kk).time_local_mean);
    train_time_synthesize_mean(kk) = sum(train_time_results(kk).time_synthesize_mean);

    test_time_results(kk).time_local = test_time_local;
    test_time_results(kk).time_synthesize = test_time_synthesize;
    test_time_results(kk).time_state_compute = test_time_state_compute;
    test_time_results(kk).time_local_mean = mean(mean(test_time_local, 3), 2);
    test_time_results(kk).time_synthesize_mean = mean(test_time_synthesize, 2);
    test_time_results(kk).time_state_compute_mean = mean(test_time_state_compute, 2);

    test_time_results(kk).time_total_mean = sum(test_time_results(kk).time_local_mean + ...
                                                test_time_results(kk).time_synthesize_mean + ...
                                                test_time_results(kk).time_state_compute_mean);
    test_time_total_mean(kk) = test_time_results(kk).time_total_mean;
end

m_mean_time_hat = mean(mean_time_hat, 1);
m_mean_trial_hat = mean(mean_trial_hat, 1);
m_mean_actions_hat = mean(mean_actions_hat ,1);

save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'mCross', 'mean_time_hat', 'm_mean_time_hat', ...
               'mean_trial_hat', 'm_mean_trial_hat', ...
               'mean_actions_hat', 'm_mean_actions_hat', ...
               'train_time_results', 'test_time_results',...
               'train_time_local_mean', 'train_time_synthesize_mean', ...
               'test_time_total_mean', 'train_time_total_mean');