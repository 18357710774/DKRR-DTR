function X = set_cancer_qtrajectory_test_data(W, M, A, inum, action_space, fea_mode, action_mode)
% fea_mode:
%     'markov';                 % the process obeys Markov assumption, and the input feature includes wellness and tumor size
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes all wellness, 
%                               % tumor sizes, and actions from stage 1 to current stage. It should be noted that if 
%                               % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously
% Set the qdata entries dat
% Z are the covariates of current stage
% Rpre are the rewards of previous stage
% inum is the number of the current stage 


n = size(W, 1);

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'separate') 
    X = [W(:,inum) M(:,inum)];
end

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'mix') 
    for i = 1:length(action_space)
        X(:,:,i) = [W(:,inum) M(:,inum) ones(n,1)*action_space(i)];
    end
end

if strcmp(fea_mode, 'markov_non')
    if strcmp(action_mode, 'separate')
        error('Error: "markov_non" is selected, and the action_mode should be "mix".')
    end
    for i = 1:length(action_space)
        X(:,:,i) = [W(:,1:inum) M(:,1:inum) A(:,1:inum-1) ones(n,1)*action_space(i)];
    end
end