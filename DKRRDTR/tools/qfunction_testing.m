function [pi_action, time_cost] =  qfunction_testing(algo, X)
action_mode = algo.action_mode;
algoname = algo.name;
n = size(X,1);

time_cost = 0;
switch algoname
    case 'ls' 
        qi_results = zeros(n, algo.size_of_action_space);
        
        if(algo.size_of_action_space==0 || isempty(algo.algos))
            pi_action = zeros(n,1);
        else
            if strcmp(action_mode, 'separate')
                tic;
                for j=1:algo.size_of_action_space        
                    qi_results(:,j) = lsw_testing(algo.algos(j), X);
                end
                time_cost = toc;
            else
                tic;
                for j=1:algo.size_of_action_space        
                    qi_results(:,j) = lsw_testing(algo.algos, X(:,:,j));
                end
                time_cost = toc;
            end
            [~, pi_action] = max(qi_results,[],2);
        end
    case 'krr'
        qi_results = zeros(n, algo.size_of_action_space);
        if(algo.size_of_action_space==0 || isempty(algo.algos))
            pi_action = zeros(n,1);
        else
            if strcmp(action_mode, 'separate')
                tic;
                for j=1:algo.size_of_action_space   
                    qi_results(:,j) = krr_testing(algo.algos(j), X);
                end
                time_cost = toc;
            else
                tic;
                for j=1:algo.size_of_action_space        
                    qi_results(:,j) = krr_testing(algo.algos, X(:,:,j));
                end
                time_cost = toc;
            end
            [~, pi_action] = max(qi_results,[],2);
        end
    case 'fcnet'
        qi_results = zeros(n, algo.size_of_action_space);
        if(algo.size_of_action_space==0 || isempty(algo.algos))
            pi_action = zeros(n,1);
        else
            if strcmp(action_mode, 'separate')
                tic;
                for j=1:algo.size_of_action_space   
                    qi_results(:,j) = predict(algo.algos(j).fc_model, X);  
                end
                time_cost = toc;
            else
                tic;
                for j=1:algo.size_of_action_space        
                    qi_results(:,j) = predict(algo.algos.fc_model, X(:,:,j));
                end
                time_cost = toc;
            end
            [~, pi_action] = max(qi_results,[],2);
        end       
end