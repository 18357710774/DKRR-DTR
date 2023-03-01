function X = set_qtrajectory_test_data(Z, Rpre, A, inum, size_of_action_space, fea_mode, action_mode)
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
% inum is the number of the current stage 


n = size(Z, 1);

if strcmp(fea_mode, 'markov_single')
    if strcmp(action_mode, 'mix')
        error('Error: "markov_single" is selected, and the action_mode should be "separate".')
    end
    X = Z(:,inum);
end

if strcmp(fea_mode, 'markov_multi') && strcmp(action_mode, 'separate') 
    X = [Z(:,inum) Rpre(:,inum)];
end

if strcmp(fea_mode, 'markov_multi') && strcmp(action_mode, 'mix') 
    for i = 1:size_of_action_space
        X(:,:,i) = [Z(:,inum) Rpre(:,inum) ones(n,1)*i];
    end
end

if strcmp(fea_mode, 'markov_non')
    if strcmp(action_mode, 'separate')
        error('Error: "markov_non" is selected, and the action_mode should be "mix".')
    end
    for i = 1:size_of_action_space
        X(:,:,i) = [Z(:,1:inum) Rpre(:,1:inum) A(:,1:inum-1) ones(n,1)*i];
    end
end
