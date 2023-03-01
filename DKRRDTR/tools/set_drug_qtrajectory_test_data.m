function X = set_drug_qtrajectory_test_data(N, T, I, B, A, size_of_action_space, fea_mode, action_mode)
% fea_mode:
%     'markov';                 % the process obeys Markov assumption, and the input feature includes wellness and tumor size
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes all wellness, 
%                               % tumor sizes, and actions from stage 1 to current stage. It should be noted that if 
%                               % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously


n = size(N, 1);

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'separate') 
    X = [N T I B];
end

if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'mix') 
    for i = 1:size_of_action_space
        X(:,:,i) = [N T I B ones(n,1)*i];
    end
end

if strcmp(fea_mode, 'markov_non')
    if strcmp(action_mode, 'separate')
        error('Error: "markov_non" is selected, and the action_mode should be "mix".')
    end
    for i = 1:size_of_action_space
        X(:,:,i) = [N T I B A(:,1:end-1) ones(n,1)*i];
    end
end