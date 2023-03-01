function [qi_results, ls, time_cost] = distributed_cancer_ls_training(X, T, A, algo, action_mode, split_info)
action_space = algo.action_space;
size_of_action_space = length(action_space);
idx_local = split_info.idx_local;
Nr = split_info.Nr;
num_machines = length(Nr);
n = size(X, 1);

%% ----------- synthesize using loop ---------------------
qi_results = zeros(n, size_of_action_space);
ls = struct('b0', {}, 'beta', {});

time_local = zeros(1,num_machines);
time_synthesize_tmp = zeros(1,num_machines);
if strcmp(action_mode, 'separate')
    for k = 1:num_machines
        qi_results_tmp = zeros(n, size_of_action_space);
        Xk = X(idx_local{k},:);
        Tk = T(idx_local{k},:);
        Ak = A(idx_local{k},:);
        tic;
        for j = 1:size_of_action_space
            Akj = action_space(j);
            Xkj = Xk(Ak==Akj,:);
            Tkj = Tk(Ak==Akj,:); 
            if isempty(Xkj)
                ls(k,j).b0 = [];
                ls(k,j).beta = [];
                qi_results_tmp(:,j) = -inf;
            else
                ls(k,j) = lsw_training(Xkj, Tkj);
                qi_results_tmp(:,j) = lsw_testing(ls(k,j), X);
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
        Xk = X(idx_local{k},:);
        Tk = T(idx_local{k},:);
        tic;
        ls(k) = lsw_training(Xk, Tk);
        for j = 1:size_of_action_space
            Xjtmp = X;
            Xjtmp(:,end) = action_space(j);
            qi_results_tmp(:,j) = lsw_testing(ls(k), Xjtmp);
        end
        ttmp = toc;
        time_local(k) = ttmp;

        tic;
        qi_results = qi_results + Nr(k)*qi_results_tmp;
        ttmp = toc;
        time_synthesize_tmp(k) = ttmp;
    end
end
time_cost.time_local = time_local;
time_cost.time_synthesize = sum(time_synthesize_tmp);