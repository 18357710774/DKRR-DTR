function [pi_action, time_cost] = distributed_fcnet_testing(algo, X, action_mode, Nr)

size_of_action_space = algo.size_of_action_space;
algos = algo.algos;
num_machines = length(Nr);
n = size(X,1);

%% ----------- synthesize using loop ---------------------
qi_results = zeros(n, size_of_action_space);

time_local = zeros(1,num_machines);
time_synthesize_tmp = zeros(1,num_machines);

if(size_of_action_space==0 || isempty(algo.algos))
    pi_action = zeros(n,1);
else
    if strcmp(action_mode, 'separate')
        for k = 1:num_machines
            qi_results_tmp = zeros(n, size_of_action_space);
            tic;
            for j = 1:size_of_action_space        
                qi_results_tmp(:,j) = predict(algos(k,j).fc_model, X);
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
                qi_results_tmp(:,j) = predict(algos(k).fc_model, X(:,:,j));
            end
            ttmp = toc;
            time_local(k) = ttmp;

            tic;
            qi_results = qi_results + Nr(k)*qi_results_tmp;
            ttmp = toc;
            time_synthesize_tmp(k) = ttmp;
        end
    end
    [~, pi_action] = max(qi_results,[],2);
end

time_cost.time_local = time_local;
time_cost.time_synthesize = sum(time_synthesize_tmp);

%% ----------- synthesize using matrix multiplication ---------------------
% qi_results = zeros(n, size_of_action_space);
% qi_results_all = zeros(n, size_of_action_space, num_machines);
% 
% time_local = zeros(1,num_machines);
% if(size_of_action_space==0 || isempty(algo.algos))
%     pi_action = zeros(n,1);
% else
%     if strcmp(action_mode, 'separate')
%         for k = 1:num_machines
%             tic;
%             for j = 1:size_of_action_space        
%                 qi_results_all(:,j,k) = predict(algos(k,j).fc_model, X);
%             end
%             ttmp = toc;
%             time_local(k) = ttmp;
%         end
%     else
%         for k = 1:num_machines
%             tic;
%             for j = 1:size_of_action_space        
%                 qi_results_all(:,j,k) = predict(algos(k).fc_model, X(:,:,j));
%             end
%             ttmp = toc;
%             time_local(k) = ttmp;
%         end
%     end
% 
%     tic;
%     for j = 1:size_of_action_space
%         qi_results(:,j) = squeeze(qi_results_all(:,j,:)) * Nr;
%     end
%     ttmp = toc;
%     time_synthesize = ttmp;
% 
%     [~, pi_action] = max(qi_results,[],2);
% end
% time_cost.time_local = time_local;
% time_cost.time_synthesize = time_synthesize;