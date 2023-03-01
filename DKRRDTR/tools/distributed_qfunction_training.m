function [maxQi_plus_one, algo, time_cost] =  distributed_qfunction_training(algo, dat, split_info)

% If this qfunction is not the first in the recursion then we need the
% results of max Q_{i+1}. This appears in qi_plus_one
% Thus we need dat={qdata_i, max_qdata_{i+1}}

% maxQi_plus_one is the expectated times of the best action at stage i 
action_mode = algo.action_mode;
algoname = algo.name;

if length(dat) == 2
    qi = dat{1};
    maxQi_plus_one = dat{2};
else
    qi = dat;
    maxQi_plus_one = [];
end

[X, T, A, AtRisk] = get_qtrajectory_data(qi);

n = size(X, 1);

if sum(AtRisk) == 0
    maxQi_plus_one = zeros(n,1);   % 这里本身就应该是0吧  
    algo.algos = [];
    time_cost.time_local = zeros(1, length(split_info.Nr));
    time_cost.time_synthesize = 0;
else    
    if(~isempty(maxQi_plus_one))
        T = T + maxQi_plus_one;
    end
    
    % We compute for each action j its appropriate qfunction and set it into lsj.
    % We also compute the value of q_i(T,j) for all j and set it in qi_results       

    switch algoname
        case 'ls' 
            [qi_results, ls, time_cost] = distributed_ls_training(X, T, A, algo, ...
                                                       action_mode, split_info);
            algo.algos = ls;
        case 'krr'             
            [qi_results, krr, time_cost] = distributed_krr_training(X, T, A, algo, ...
                                                         action_mode, split_info);
            algo.algos = krr;
        case 'fcnet'             
            [qi_results, fcnet, time_cost] = distributed_fcnet_training(X, T, A, algo, ...
                                                         action_mode, split_info);
            algo.algos = fcnet; 
    end
    % compute the values and indices of the best action at stage i
    maxQi_plus_one = max(qi_results, [], 2); 
end



%             sigma = algo.params(1);
%             lambda = algo.params(2);

%             qi_results = zeros(n, algo.size_of_action_space);
%             qi_results_all = zeros(n, algo.size_of_action_space, num_machines);
%             krr = struct('x', {}, 'alpha', {}, 'sigma', {}, 'lambda', {});
% 
%             if strcmp(action_mode, 'separate')
%                 for k = 1:num_machines
%                     Xk = X(idx_local{k},:);
%                     Tk = T(idx_local{k},:);
%                     for j = 1:algo.size_of_action_space
%                         Xkj = Xk(A==j,:);
%                         Tkj = Tk(A==j,:); 
%                         krr(k,j) = krr_training(Xkj, Tkj, sigma, lambda);
%                         qi_results_all(:,j,k) = krr_testing(krr(k,j), Xk);
%                     end
%                 end
%             else                
%                 for k = 1:num_machines
%                     Xk = X(idx_local{k},:);
%                     Tk = T(idx_local{k},:);
%                     krr(k) = krr_training(Xk, Tk, sigma, lambda);
%                     for j = 1:algo.size_of_action_space
%                         Xjtmp = Xk;
%                         Xjtmp(:,end) = j;
%                         qi_results_all(:,j,k) = krr_testing(krr(k), Xjtmp);
%                     end
%                 end
%             end
%             for j=1:algo.size_of_action_space
%                 qi_results(:,j) = squeeze(qi_results_all(:,j,:)) * Nr;
%             end