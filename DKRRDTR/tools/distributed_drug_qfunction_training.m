function [maxQi_plus_one, algo] =  distributed_drug_qfunction_training(algo, dat, split_info)

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

[X, T, A] = get_qtrajectory_data(qi);

  
if(~isempty(maxQi_plus_one))
    T = T + maxQi_plus_one;
end

% We compute for each action j its appropriate qfunction and set it into lsj.
% We also compute the value of q_i(T,j) for all j and set it in qi_results       

switch algoname
    case 'ls' 
        [qi_results, ls] = distributed_ls_training(X, T, A, algo, ...
                                                   action_mode, split_info);
        algo.algos = ls;
    case 'krr'             
        [qi_results, krr] = distributed_krr_training(X, T, A, algo, ...
                                                     action_mode, split_info);
        algo.algos = krr;
    case 'fcnet'             
        [qi_results, fcnet] = distributed_fcnet_training(X, T, A, algo, ...
                                                     action_mode, split_info);
        algo.algos = fcnet; 
end
% compute the values and indices of the best action at stage i
maxQi_plus_one = max(qi_results, [], 2); 