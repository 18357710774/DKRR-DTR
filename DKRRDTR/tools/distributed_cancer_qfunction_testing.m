function [pi_action, time_cost] =  distributed_cancer_qfunction_testing(algo, X, Nr)
action_mode = algo.action_mode;
algoname = algo.name;

switch algoname
    case 'ls' 
        [pi_action, time_cost] = distributed_cancer_ls_testing(algo, X, action_mode, Nr);     
    case 'krr'
        [pi_action, time_cost] = distributed_cancer_krr_testing(algo, X, action_mode, Nr);
    case 'fcnet'
        [pi_action, time_cost] = distributed_cancer_fcnet_testing(algo, X, action_mode, Nr);
end