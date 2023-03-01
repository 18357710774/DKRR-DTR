% DNN-DTR with the selected parameters  (multi + separate case)

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
n_train = 10000;                     % the number of training samples
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
opt.fea_mode = 'markov_multi';
opt.action_mode = 'separate'; 
opt.num_stages = 3;
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
MaxEpochs = 10000;                        % MaxEpochs — Maximum number of epochs: 30 (default) | positive integer

MiniBatchSize = 5000;                     % MiniBatchSize — Size of mini-batch
                                          % 128 (default) | positive integer

ValidationFrequency = 5000;               % ValidationFrequency — Frequency of network validation in number of 
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
opt.algoparams.hidden_layers_number = 3;    % hidden_layers_number
opt.algoparams.hidden_neuron_number = 10;   % hidden_neuron_number

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end
savefile = [cd '\SynResults\clinical_flexiblestagesNtr' num2str(n_train) ...
            '_' opt.algoname  '_markovmulti_separ' '_baseline.mat'];

e_train = example;
e_train.n = n_train;
e_test = example;
e_test.n = n_test;

mean_time_hat = zeros(ExNum, 1);
mean_trial_hat = zeros(ExNum, 1);
mean_actions_hat = zeros(ExNum, 1);

train_time = zeros(opt.num_stages, ExNum);
test_time = cell(1, ExNum);

for Ex = 1:ExNum
    e_train.seed = Ex;
    e_test.seed = Ex;

    t1 = clock;
    qt = clinical_flexstages_generate(e_train, opt);    
    [valgo, ~, train_time_tmp] = vfunction_training(qt, opt); 
    train_time(:, Ex) = train_time_tmp;
    
    [time_hat_tmp, test_time_tmp, actions_hat_tmp, trial_hat_tmp] ... 
                             = example_dynamics(valgo, e_test, opt);
    mean_time_hat(Ex) = mean(time_hat_tmp);
    mean_trial_hat(Ex) = mean(trial_hat_tmp);
    mean_actions_hat(Ex) = mean(actions_hat_tmp);
    test_time{Ex} = test_time_tmp;
    t2 = clock;
    t = etime(t2, t1);

    disp(['Ex#' num2str(Ex)  '  mean_time_hat=' num2str(mean_time_hat(Ex)) ...
         '      time_cost=' num2str(t) 'seconds']);

    save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'mean_time_hat', 'mean_trial_hat', ...
               'mean_actions_hat', 'train_time', 'test_time');
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

m_mean_time_hat = mean(mean_time_hat);
m_mean_trial_hat = mean(mean_trial_hat);
m_mean_actions_hat = mean(mean_actions_hat);

save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', ...
               'mean_time_hat', 'm_mean_time_hat', ...
               'mean_trial_hat', 'm_mean_trial_hat', ...
               'mean_actions_hat', 'm_mean_actions_hat', ...
               'train_time_results', 'test_time_results');