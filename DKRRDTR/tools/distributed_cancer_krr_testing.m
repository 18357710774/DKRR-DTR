function [pi_action, time_cost] = distributed_cancer_krr_testing(algo, X, action_mode, Nr)
action_space = algo.action_space;
size_of_action_space = length(action_space);
algos = algo.algos;
num_machines = length(Nr);
n = size(X,1);

%% ----------- synthesize using loop ---------------------
qi_results = zeros(n, size_of_action_space);

time_local = zeros(1,num_machines);
time_synthesize_tmp = zeros(1,num_machines);

if(size_of_action_space==0 || isempty(algos))
    pi_action = -inf*ones(n,1);
else
    if strcmp(action_mode, 'separate')
        for k = 1:num_machines
            qi_results_tmp = zeros(n, size_of_action_space);
            tic;
            for j = 1:size_of_action_space                
                if isempty(algos(k,j).alpha)
                    qi_results_tmp(:,j) = -ones(n,1)*inf;
                else
                    qi_results_tmp(:,j) = krr_testing(algos(k,j), X);
                end                
            end
            ttmp = toc;
            time_local(k) = ttmp;

            tic;
            qi_results = qi_results + Nr(k)*qi_results_tmp;
            ttmp = toc;
            time_synthesize_tmp(k) = ttmp;
        end
    else
        for k = 1:num_machines
            qi_results_tmp = zeros(n, size_of_action_space);
            tic;
            for j = 1:size_of_action_space        
                qi_results_tmp(:,j) = krr_testing(algos(k), X(:,:,j));
            end
            ttmp = toc;
            time_local(k) = ttmp;

            tic;
            qi_results = qi_results + Nr(k)*qi_results_tmp;
            ttmp = toc;
            time_synthesize_tmp(k) = ttmp;
        end
    end
    [~, pi_action_ind] = max(qi_results,[],2);
    pi_action = action_space(pi_action_ind);
end

time_cost.time_local = time_local;
time_cost.time_synthesize = sum(time_synthesize_tmp);