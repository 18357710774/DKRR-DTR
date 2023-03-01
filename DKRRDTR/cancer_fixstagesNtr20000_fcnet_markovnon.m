% DNN-DTR with the selected parameters  (non-markov case)

clear;
close all;
addpath(genpath('tools')) 

% ------------------ Training number and testing number ----------------------------
n_train = 20000;                        % the number of training samples
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
opt.algoname = 'fcnet';

% ------------------- Set parameters ranges --------------------------
% neural network settings
initializer = 'glorot';                   % Function to initialize weights: 'glorot' (default) | 'he' | 'orthogonal' | 
                                          % 'narrow-normal' | 'zeros' | 'ones' | function handle    

act_type = 'sigmoid';                     % Activation function: 'sigmoid' | 'relu' | 'leakyrelu' | 'tanh' |
                                          % 'clippedrelu' | 'elu' | 'swish'
        
solverName = 'sgdm';                      % Optimization algorithm: 'sgdm' | 'rmsprop' | 'adam'

Momentum = 0.9;                           % Contribution of the parameter update step of the previous iteration to 
                                          % the current iteration of stochastic gradient descent with momentum, specified 
                                          % as a scalar from 0 to 1. A value of 0 means no contribution from the previous 
                                          % step, whereas a value of 1 means maximal contribution from the previous step. 
                                          % The default value works well for most tasks. To specify the Momentum training 
                                          % option, solverName must be 'sgdm'.

InitialLearnRate = 0.05;                  % Initial learning rate used for training, specified as a positive scalar.
                                          % The default value is 0.01 for the 'sgdm' solver and 0.001 for the 
                                          % 'rmsprop' and 'adam' solvers.
MaxEpochs = 2000;                         % MaxEpochs — Maximum number of epochs: 30 (default) | positive integer

MiniBatchSize = 5000;                     % MiniBatchSize — Size of mini-batch
                                          % 128 (default) | positive integer

ValidationFrequency = 5000;                % ValidationFrequency — Frequency of network validation in number of 
                                          % iterations, 50 (default) | positive integer 

Verbose = 1;                              % Verbose — Indicator to display training progress information
                                          % 1 (true) (default) | 0 (false)

VerboseFrequency = ValidationFrequency;   % VerboseFrequency — Frequency of verbose printing
                                          % 0 (default) | positive integer

ExecutionEnvironment = 'auto';            % ExecutionEnvironment — Hardware resource for training network
                                          % 'auto' | 'cpu' | 'gpu' | 'multi-gpu' | 'parallel'

opt.algoparams.train_options = trainingOptions(solverName, ...
                             'InitialLearnRate',InitialLearnRate, ...
                             'MaxEpochs', MaxEpochs, ...
                             'MiniBatchSize', MiniBatchSize, ...
                             'Shuffle','every-epoch', ...
                             'Momentum', Momentum, ...
                             'ValidationFrequency',ValidationFrequency, ...
                             'Plots','none',...
                             'Verbose',Verbose, ...
                             'VerboseFrequency', VerboseFrequency, ...
                             'ExecutionEnvironment', ExecutionEnvironment);
opt.algoparams.initializer = initializer;
opt.algoparams.act_type = act_type;
opt.algoparams.hidden_layers_number = 2;     % hidden_layers_number
opt.algoparams.hidden_neuron_number = 90;    % hidden_neuron_number

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end
savefile = [cd '\SynResults\cancer_fixstagesNtr' num2str(n_train) ...
            '_' opt.algoname  '_markovnon' '_baseline.mat'];

e_train = example;
e_train.n = n_train;
e_test = example;
e_test.n = n_test;

CSP_mean = zeros(ExNum, opt.num_stages+1);
W_mean = zeros(ExNum, opt.num_stages+1);
M_mean = zeros(ExNum, opt.num_stages+1);
WM_mean = zeros(ExNum, opt.num_stages+1);
R_mean = zeros(ExNum, opt.num_stages);
Death_mean = zeros(ExNum, opt.num_stages+1);
Cured_mean = zeros(ExNum, opt.num_stages+1);
AtRisk_mean = zeros(ExNum, opt.num_stages+1);

train_time = zeros(opt.num_stages, ExNum);
test_time = cell(1, ExNum);

for Ex = 1:ExNum
    e_train.seed = Ex;
    e_test.seed = Ex;

    t1 = clock;
    qt = cancer_fixstages_generate(e_train, opt);    
    [valgo, ~, train_time_tmp] = cancer_vfunction_training(qt, opt);   
    train_time(:, Ex) = train_time_tmp;

    [CSP_tmp, test_time_tmp, W_tmp, M_tmp, WM_tmp, R_tmp, Death_tmp, Cured_tmp, AtRisk_tmp] = ...
                            cancer_example_dynamics_allstages(valgo, e_test, opt);
    CSP_mean(Ex,:) = CSP_tmp;
    W_mean(Ex,:) = W_tmp;
    M_mean(Ex,:) = M_tmp;
    WM_mean(Ex,:) = WM_tmp;
    R_mean(Ex,:) = R_tmp;
    Death_mean(Ex,:) = Death_tmp;
    Cured_mean(Ex,:) = Cured_tmp;
    AtRisk_mean(Ex,:) = AtRisk_tmp;
    test_time{Ex} = test_time_tmp;
    t2 = clock;
    t = etime(t2, t1);

    disp(['Ex#' num2str(Ex)  '  CSP_mean=' num2str(CSP_mean(Ex, end)) ...
         '      WM_mean=' num2str(WM_mean(Ex, end)) ...
         '      time_cost=' num2str(t) 'seconds']);
    save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'CSP_mean', 'W_mean', 'M_mean', 'WM_mean', 'R_mean', ...
               'Death_mean', 'Cured_mean', 'AtRisk_mean', ...
               'train_time', 'test_time');
end

train_time_results.time_stages = train_time;
train_time_results.time_total = sum(train_time, 1);
train_time_results.time_total_mean = mean(train_time_results.time_total);
train_time_results.time_total_std = std(train_time_results.time_total);

test_time_action_predict = zeros(opt.num_stages, ExNum);
test_time_state_compute = zeros(opt.num_stages, ExNum);
for Ex = 1:ExNum
    for i = 1:opt.num_stages
        test_time_action_predict(i,Ex) = test_time{Ex}(i).time_action_predict;
        test_time_state_compute(i, Ex) = test_time{Ex}(i).time_state_compute;
    end
end

test_time_results.time_action_predict = test_time_action_predict;
test_time_results.time_state_compute = test_time_state_compute;
test_time_results.time_action_predict_mean = mean(test_time_action_predict, 2);
test_time_results.time_state_compute_mean = mean(test_time_state_compute, 2);
test_time_results.time_total = sum(test_time_action_predict+test_time_state_compute, 1);
test_time_results.time_total_mean = mean(test_time_results.time_total);
test_time_results.time_total_std = std(test_time_results.time_total);

CSP_mean_Exmean = mean(CSP_mean, 1);
W_mean_Exmean = mean(W_mean, 1);
M_mean_Exmean = mean(M_mean, 1);
WM_mean_Exmean = mean( WM_mean, 1);
R_mean_Exmean = mean(R_mean, 1);
Death_mean_Exmean = mean(Death_mean, 1);
Cured_mean_Exmean = mean(Cured_mean, 1);
AtRisk_mean_Exmean = mean(AtRisk_mean, 1);

save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'CSP_mean', 'W_mean', 'M_mean', 'WM_mean', 'R_mean', ...
               'Death_mean', 'Cured_mean', 'AtRisk_mean', ...
               'CSP_mean_Exmean', 'W_mean_Exmean', 'M_mean_Exmean', ...
               'WM_mean_Exmean','R_mean_Exmean', 'Death_mean_Exmean',...
               'Cured_mean_Exmean', 'AtRisk_mean_Exmean',...
               'train_time_results', 'test_time_results');

