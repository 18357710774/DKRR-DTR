% fixed treatments in Simulation 2

clear;
close all;
addpath(genpath('tools'));


% ------------------ Training number and testing number ----------------------------
n_test = 1000;                       % the number of testing samples
ExNum = 100;                         % the number of simulations

% ------------------ The settings for generating trajectories -----------------------
example.states =  [0.1, 1.2, 0.5;       % Constants in the eqations of wellness and tumor size
                   0.15, 1.2, 0.5];       
example.mu = [-4.5, 1, 1];              % The cofficients in the hazard function \lambda(t)
example.c0 = 0.5;                       % The threshold in reward function
example.IW = [0, 2];                    % The endpoints of the interval for initial wellness
example.IM = [0, 2];                    % The endpoints of the interval for initial tumor size
example.actions1 = [0, 1];              % The endpoints of the interval for drug level at stage 1
example.actions2 = [0, 1];              % The endpoints of the interval for drug level at stage k (k>1)
example.increment = 0.1;                % The increments of discrete doge levels
example.death_r = -6;                   % The reward for death
example.cure_r = 1.5;                   % The reward for cured patient
example.other_r = 0.5;                  % The reward for other results  
example = clinical_fixstages_params(example);

e_test = example;
e_test.n = n_test;

num_stages = 6;

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end
savefile = [cd '\SynResults\cancer_fixstages_fixpolicy.mat'];

action_space = (example.actions1(1)+example.increment):example.increment:example.actions1(2);
size_of_action_space = length(action_space);
e_test.action_space = action_space;

CSP_mean = zeros(ExNum, size_of_action_space); 
CSP_mean_allstages = zeros(num_stages+1, size_of_action_space, ExNum); 
Wfinal_mean = zeros(ExNum, size_of_action_space); 
Mfinal_mean = zeros(ExNum, size_of_action_space); 
Rfinal_mean = zeros(ExNum, size_of_action_space); 
Curedfinal_mean = zeros(ExNum, size_of_action_space); 
AtRiskfinal_mean = zeros(ExNum, size_of_action_space); 
Deathfinal_mean = zeros(ExNum, size_of_action_space); 

for Ex = 1:ExNum
    e_test.seed = Ex;
    tic;
    [CSP_mean(Ex,:), CSP_mean_allstages(:,:,Ex), Wfinal_mean(Ex,:), Mfinal_mean(Ex,:), ... 
     Rfinal_mean(Ex,:), Curedfinal_mean(Ex,:), AtRiskfinal_mean(Ex,:), Deathfinal_mean(Ex,:)] ...
             = cancer_example_dynamics_fixpolicy(e_test, num_stages);
    disp(['Exnum = ' num2str(Ex) ':   CSP_mean_max = ' num2str(max(CSP_mean(Ex,:)))]);
    t = toc;
end

CSP_mean_Exmean = mean(CSP_mean, 1);
CSP_mean_allstages_Exmean = mean(CSP_mean_allstages, 3);
Wfinal_mean_Exmean = mean(Wfinal_mean, 1);
Mfinal_mean_Exmean = mean(Mfinal_mean, 1);
Rfinal_mean_Exmean = mean(Rfinal_mean, 1);
Curedfinal_mean_Exmean = mean(Curedfinal_mean, 1);
AtRiskfinal_mean_Exmean = mean(AtRiskfinal_mean, 1);
Deathfinal_mean_Exmean = mean(Deathfinal_mean, 1);

save(savefile, 'example', 'n_test', 'ExNum', 'num_stages', 'action_space', ...
               'CSP_mean', 'Wfinal_mean', 'Mfinal_mean', 'Rfinal_mean', ...
               'Curedfinal_mean', 'AtRiskfinal_mean', 'Deathfinal_mean', ...
               'CSP_mean_Exmean', 'Wfinal_mean_Exmean', 'Mfinal_mean_Exmean', ...
               'Rfinal_mean_Exmean', 'Curedfinal_mean_Exmean', ...
               'AtRiskfinal_mean_Exmean', 'Deathfinal_mean_Exmean',...
               'CSP_mean_allstages', 'CSP_mean_allstages_Exmean');
