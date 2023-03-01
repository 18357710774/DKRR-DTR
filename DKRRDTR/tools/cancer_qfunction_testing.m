function [pi_action, time_cost] =  cancer_qfunction_testing(algo, X)
action_mode = algo.action_mode;
action_space = algo.action_space;
size_of_action_space = length(action_space);
algoname = algo.name;
n = size(X,1);

if(size_of_action_space==0 || isempty(algo.algos))
    pi_action = -inf*ones(n,1);
    time_cost = 0;
else
    qi_results = zeros(n, size_of_action_space);
    switch algoname
        case 'ls'               
            if strcmp(action_mode, 'separate')
                tic;
                for j=1:size_of_action_space        
                    qi_results(:,j) = lsw_testing(algo.algos(j), X);
                end
                time_cost = toc;
            else
                tic;
                for j=1:size_of_action_space        
                    qi_results(:,j) = lsw_testing(algo.algos, X(:,:,j));
                end
                time_cost = toc;
            end            
            
        case 'krr'
            if strcmp(action_mode, 'separate')
                tic;
                for j=1:size_of_action_space   
                    qi_results(:,j) = krr_testing(algo.algos(j), X);
                end
                time_cost = toc;
            else
                tic;
                for j=1:size_of_action_space        
                    qi_results(:,j) = krr_testing(algo.algos, X(:,:,j));
                end
                time_cost = toc;
            end
            
        case 'fcnet'           
            if strcmp(action_mode, 'separate')
                tic;
                for j=1:size_of_action_space
                    qi_results(:,j) = fcnet_testing(algo.algos(j), X);  
                end
                time_cost = toc;
            else
                tic;
                for j=1:size_of_action_space        
                    qi_results(:,j) = fcnet_testing(algo.algos, X(:,:,j));
                end
                time_cost = toc;
            end            
    end
    [~, pi_action_ind] = max(qi_results,[],2);
    pi_action = action_space(pi_action_ind);
end