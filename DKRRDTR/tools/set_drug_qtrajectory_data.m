function [retDat] = set_drug_qtrajectory_data(N, T, I, B, A, R, idx, fea_mode, action_mode)
% opt.fea_mode:
%     'markov';                 % the process obeys Markov assumption.
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes the states
                                % and actions of previous opt.fea_steps stages. It should be noted that if 
                                % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% opt.action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously

% Set the qdata entries dat
% N: the normal cell population
% T: the tumor cell population
% I: the immune cell population
% B: drug concentration
% A: actions
% R: reward
% idx: index of stages for input features


dat.N = N(:,idx); 
dat.T = T(:,idx); 
dat.I = I(:,idx);  
dat.B = B(:,idx); 
dat.A = A(:,idx); 
dat.U = R(:,idx(1));  

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'separate') 
    dat.X = [dat.N dat.T dat.I dat.B];
end

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'mix') 
    dat.X = [dat.N dat.T dat.I dat.B dat.A];
end

if strcmp(fea_mode, 'markov_non')
    if strcmp(action_mode, 'separate')
        error('Error: "markov_non" is selected, and the action_mode should be "mix".')
    end
    dat.X = [dat.N dat.T dat.I dat.B dat.A];
end
dat.A = A(:,idx(end)); 
retDat = dat;
