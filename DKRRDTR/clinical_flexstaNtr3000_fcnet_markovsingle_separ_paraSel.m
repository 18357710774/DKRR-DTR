% parameter selection step for fully connected neural network (single +  separate case)
% the number of hidden layers, the number of neurons in the hidden layers, 
% and the number of epochs of DNN are tuned parameters

clear;
close all;
addpath(genpath('tools'))

% ------------------ Training number and testing number ----------------------------
n_train = 3000;                      % the number of training samples
n_test = 1000;                       % the number of testing samples
ExNum = 20;                          % the number of simulations

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

MiniBatchSize = 3000;                     % MiniBatchSize — Size of mini-batch
                                          % 128 (default) | positive integer

ValidationFrequency = 5000;               % ValidationFrequency — Frequency of network validation in number of 
                                          % iterations, 50 (default) | positive integer 

Verbose = 1;                              % Verbose — Indicator to display training progress information
                                          % 1 (true) (default) | 0 (false)

VerboseFrequency = ValidationFrequency;   % VerboseFrequency — Frequency of verbose printing
                                          % 0 (default) | positive integer

ExecutionEnvironment = 'auto';            % ExecutionEnvironment — Hardware resource for training network
                                          % 'auto' | 'cpu' | 'gpu' | 'multi-gpu' | 'parallel'

opt.algoparams.initializer = initializer;
opt.algoparams.act_type = act_type;

hidden_layers_number_seq = 1:4;
hidden_neuron_number_seq = 10:10:100;
MaxEpochs_seq = 2000:2000:10000;

para = zeros(3, length(hidden_layers_number_seq)*length(hidden_neuron_number_seq));
count = 0;
for hidden_layers_number = hidden_layers_number_seq
    for hidden_neuron_number = hidden_neuron_number_seq
        for MaxEpochs = MaxEpochs_seq
            count = count+1;
            para(:,count) = [hidden_layers_number; hidden_neuron_number; MaxEpochs];        
        end
    end
end

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end

savefile = [cd '\SynResults\clinical_flexiblestagesNtr' num2str(n_train) ...
            '_' opt.algoname act_type '_markovsingle_separ' '_paraSel.mat'];

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
        MaxEpochs = para(3,k);                   % Maximum number of epochs: 30 (default) | positive integer
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
                             'ExecutionEnvironment', 'auto');

        opt.algoparams.hidden_layers_number = para(1,k);    % hidden_layers_number
        opt.algoparams.hidden_neuron_number = para(2,k);    % hidden_neuron_number
        tic;
        valgo = vfunction_training(qt, opt);                        
        time_hat_tmp = example_dynamics(valgo, e_test, opt);
        mean_time_hat(Ex, k) = mean(time_hat_tmp);
        t = toc;
        disp(['Ex#' num2str(Ex)  '    hidden_layers_number=' num2str(para(1,k)) ...
            '    hidden_neuron_number=' num2str(para(2,k))  ...
            '    MaxEpochs=' num2str(para(3,k))  ...
            '    mean_time_hat=' num2str(mean_time_hat(Ex, k)) ...
            '    time_cost=' num2str(t) 'seconds']);
    end
    save(savefile, 'para', 'mean_time_hat');
end
m_mean_time_hat = mean(mean_time_hat, 1);
[m_mean_time_hat_opt, ind_opt] = max(m_mean_time_hat);
hidden_layers_number_opt = para(1,ind_opt);
hidden_neuron_number_opt = para(2,ind_opt);
MaxEpochs_opt = para(3,ind_opt);
save(savefile, 'example', 'n_train', 'n_test', 'ExNum','opt', 'hidden_layers_number_seq', ...
               'hidden_neuron_number_seq', 'para', 'mean_time_hat', 'm_mean_time_hat', ...
               'hidden_neuron_number_opt', 'hidden_layers_number_opt', 'MaxEpochs_opt');
