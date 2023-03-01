function [retDat] = set_qtrajectory_data(Z, Rpre, A, U, AtRisk, sumU, fea_mode, action_mode)
% fea_mode:
%     'markov_single';          % the process obeys Markov assumption, and the input feature includes only wellness.
%                               % It should be noted that if fea_mode is setted as 'markov_non', the action_mode should be 'mix'
%                               % fea_mode is setted as 'markov_single', the action_mode should be 'separate'
%     'markov_multi';           % the process obeys Markov assumption, and the input feature includes wellness and previous reward
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes all wellness, 
%                               % previous reward, and actions from stage 1 to current stage. It should be noted that if 
%                               % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously

% Set the qdata entries dat
% Z are the covariates of current stage
% Rpre are the rewards of previous stage
% A are actions of current stage
% U are the time spents (rewards) of current stage
% AtRisk is 1 if no failure event happend up to cuurent stage
% SumU are the time spent (total rewards) up to and include current stage

dat.Z = Z;                               % Z: wellness
dat.Rpre = Rpre;                         % Rpre: the reward of previous stage
dat.A = A;                               % A: actions
dat.U = U;                               % U: the actual time at current stage
dat.AtRisk = AtRisk;                     % atRisk: no failure happens at current stage
dat.SumU = sumU;                         % sumU: the actual time from stage 1 to stage i


if strcmp(fea_mode, 'markov_single')
    if strcmp(action_mode, 'mix')
        error('Error: "markov_single" is selected, and the action_mode should be "separate".')
    end
    dat.X = dat.Z;
end

if strcmp(fea_mode, 'markov_multi') && strcmp(action_mode, 'separate') 
    dat.X = [dat.Z dat.Rpre];
end

if strcmp(fea_mode, 'markov_multi') && strcmp(action_mode, 'mix') 
    dat.X = [dat.Z dat.Rpre dat.A];
end

if strcmp(fea_mode, 'markov_non')
    if strcmp(action_mode, 'separate')
        error('Error: "markov_non" is selected, and the action_mode should be "mix".')
    end
    dat.X = [dat.Z dat.Rpre dat.A];
end

retDat = dat;


                             
% if nargin == 1
%     A = zeros(size(Z,1),1);
%     AtRisk = A;
%     U = A;
%     sumU = A;
% end

% if nargin<=6
%     dat.Z = Z;                           % Z: wellness
%     dat.Rpre = Rpre;                     % Rpre: the reward of previous stage
%     dat.A = A;                           % A: actions
%     dat.X = [Z Rpre A];                  % X: variable (state and action) of Q-function 
%     dat.U = U;                           % U: the actual time at current stage
%     dat.AtRisk = AtRisk;                 % atRisk: no failure happens at current stage
%     dat.SumU = sumU;                     % sumU: the actual time from stage 1 to stage i
% end
% 
% retDat = dat;