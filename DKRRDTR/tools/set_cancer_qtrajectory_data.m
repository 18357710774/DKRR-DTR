function [retDat] = set_cancer_qtrajectory_data(W, M, A, U, AtRisk, Death, Cured, action_space, fea_mode, action_mode)
% fea_mode:
%     'markov';                 % the process obeys Markov assumption, and the input feature includes wellness and tumor size
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes all wellness, 
%                               % tumor sizes, and actions from stage 1 to current stage. It should be noted that if 
%                               % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously

% Set the qdata entries dat
% W are the wellness of current stage
% M are the tumor size of current stage
% A are actions of current stage
% U are the rewards of current stage
% AtRisk is 1 if no failure event happend up to current stage
% action_space is the set of actions at current stage

dat.W = W;                               % Z: wellness
dat.M = M;                               % Rpre: the reward of previous stage
dat.A = A;                               % A: actions
dat.U = U;                               % U: the actual time at current stage
dat.AtRisk = AtRisk;                     % AtRisk: value=1, not dead or cured at current stage
dat.Death = Death;                       % Death: value=1, dead at current stage
dat.Cured = Cured;                       % Cured: value=1, cured at current stage
dat.action_space = action_space;         % action_space: the range and increment of the action space at current stage

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'separate') 
    dat.X = [dat.W dat.M];
end

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'mix') 
    dat.X = [dat.W dat.M dat.A];
end

if strcmp(fea_mode, 'markov_non')
    if strcmp(action_mode, 'separate')
        error('Error: "markov_non" is selected, and the action_mode should be "mix".')
    end
    dat.X = [dat.W dat.M dat.A];
end

retDat = dat;
