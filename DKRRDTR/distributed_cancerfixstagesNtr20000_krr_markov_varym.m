% DKRR-DTR with the selected parameters  (markov case)

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
n_train = 20000;                       % the number of training samples
n_test = 1000;                         % the number of testing samples
ExNum = 20;                            % the number of simulations

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
opt.fea_mode = 'markov'; 
opt.action_mode = 'mix'; 
opt.num_stages = 6;
opt.algoname = 'krr';
opt.split_mode = 'equal';
mCross = 2:2:100;

% ------------------- Set parameters ranges --------------------------
opt.algoparams(1) = 0.5456;            % KRR: the fisrt parameter is width of kernel, 
opt.algoparams(2) = 6.1035e-5;         %      the second parameter is regularization

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end
savefile = [cd '\SynResults\distributed_cancer_fixstageNtr' num2str(n_train) ...
            '_' opt.algoname  '_markov_varym_Usplit.mat'];

e_train = example;
e_train.n = n_train;
e_test = example;
e_test.n = n_test;

CSP_mean = zeros(length(mCross), opt.num_stages+1, ExNum);
W_mean = zeros(length(mCross), opt.num_stages+1, ExNum);
M_mean = zeros(length(mCross), opt.num_stages+1, ExNum);
WM_mean = zeros(length(mCross), opt.num_stages+1, ExNum);
R_mean = zeros(length(mCross), opt.num_stages, ExNum);
Death_mean = zeros(length(mCross), opt.num_stages+1, ExNum);
Cured_mean = zeros(length(mCross), opt.num_stages+1, ExNum);
AtRisk_mean = zeros(length(mCross), opt.num_stages+1, ExNum);

train_time = cell(ExNum, length(mCross));
test_time = cell(ExNum, length(mCross));

for kk = 1:length(mCross)
    opt.num_machines = mCross(kk);   
    for Ex = 1:ExNum
        e_train.seed = Ex;
        e_test.seed = Ex;
        
        t1 = clock;
        qt = distributed_cancer_fixstages_generate(e_train, opt);    
        [vf, ~, train_time_tmp] = distributed_cancer_vfunction_training(qt, opt); 
        train_time{Ex,kk} = train_time_tmp;

        [CSP_tmp, test_time_tmp, W_tmp, M_tmp, WM_tmp, R_tmp, Death_tmp, Cured_tmp, AtRisk_tmp] ...
                         = distributed_cancer_example_dynamics_allstages(vf, e_test, opt);
        
        CSP_mean(kk,:, Ex) = CSP_tmp;
        W_mean(kk,:, Ex) = W_tmp;
        M_mean(kk,:, Ex) = M_tmp;
        WM_mean(kk,:, Ex) = WM_tmp;
        R_mean(kk,:, Ex) = R_tmp;
        Death_mean(kk,:, Ex) = Death_tmp;
        Cured_mean(kk,:, Ex) = Cured_tmp;
        AtRisk_mean(kk,:, Ex) = AtRisk_tmp;
        test_time{Ex,kk} = test_time_tmp;
        t2 = clock;
        t = etime(t2, t1);

        disp(['local_machines#' num2str(opt.num_machines) ...
            '   Ex#' num2str(Ex)  '  CSP_mean=' num2str(CSP_mean(kk, end, Ex)) ...
            '   WM_mean=' num2str(WM_mean(kk, end, Ex)) ...
            '   time_cost=' num2str(t) 'seconds']);
    end
    save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'mCross', 'CSP_mean', 'W_mean', 'M_mean', 'WM_mean', ...
               'R_mean', 'Death_mean', 'Cured_mean', 'AtRisk_mean', ...
               'train_time', 'test_time');
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


CSP_mean_Exmean = mean(CSP_mean, 3);
W_mean_Exmean = mean(W_mean, 3);
M_mean_Exmean = mean(M_mean, 3);
WM_mean_Exmean = mean( WM_mean, 3);
R_mean_Exmean = mean(R_mean, 3);
Death_mean_Exmean = mean(Death_mean, 3);
Cured_mean_Exmean = mean(Cured_mean, 3);
AtRisk_mean_Exmean = mean(AtRisk_mean, 3);

save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'mCross', 'CSP_mean', 'W_mean', 'M_mean', 'WM_mean', ...
               'R_mean', 'Death_mean', 'Cured_mean', 'AtRisk_mean', ...
               'CSP_mean_Exmean', 'W_mean_Exmean', 'M_mean_Exmean', ...
               'WM_mean_Exmean','R_mean_Exmean', 'Death_mean_Exmean',...
               'Cured_mean_Exmean', 'AtRisk_mean_Exmean', ...
               'train_time_results', 'test_time_results',...
               'train_time_local_mean', 'train_time_synthesize_mean', ...
               'test_time_total_mean', 'train_time_total_mean');
