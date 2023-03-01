% fixed treatments in Simulation 1

clear;
close all;
addpath(genpath('tools'));

% ------------------ Training number and testing number ----------------------------
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

e_test = example;
e_test.n = n_test;

num_stages = 3;

if ~exist([cd '\SynResults'], 'dir')
	mkdir([cd '\SynResults']);
end
savefile = [cd '\SynResults\clinical_flexstages_fixpolicy.mat'];

TotalTime = zeros(n_test, 8, ExNum);
NumActions = zeros(n_test, 8, ExNum);
TotalTime_mean = zeros(ExNum, 8);
NumActions_mean = zeros(ExNum, 8);
for Ex = 1:ExNum
    e_test.seed = Ex;
    tic;
    [TotalTime_tmp, NumActions_tmp] = example_dynamics_all(e_test, num_stages);
    TotalTime(:,:,Ex) = TotalTime_tmp;
    NumActions(:,:,Ex) = NumActions_tmp; 
    TotalTime_mean(Ex,:) = mean(TotalTime_tmp, 1);
    NumActions_mean(Ex,:) = mean(NumActions_mean, 1);
end

m_TotalTime_mean = mean(TotalTime_mean, 1);
m_NumActions_mean = mean(NumActions_mean, 1);

save(savefile, 'example', 'n_test', 'ExNum', 'num_stages', ...
               'm_TotalTime_mean', 'm_NumActions_mean', ...
               'TotalTime_mean', 'NumActions_mean', ...
               'TotalTime', 'NumActions');
