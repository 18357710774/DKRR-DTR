function [qi_results, krr, time_cost] = distributed_cancer_krr_training(X, T, A, algo, action_mode, split_info)
sigma = algo.params(1);
lambda = algo.params(2);
action_space = algo.action_space;
size_of_action_space = length(action_space);
idx_local = split_info.idx_local;
Nr = split_info.Nr;
num_machines = length(Nr);
n = size(X, 1);

qi_results = zeros(n, size_of_action_space);
krr = struct('x', {}, 'alpha', {}, 'sigma', {}, 'lambda', {});

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
                krr(k,j).x = [];
                krr(k,j).alpha = [];
                krr(k,j).sigma = [];
                krr(k,j).lambda = [];
                qi_results_tmp(:,j) = -inf;
            else
                krr(k,j) = krr_training(Xkj, Tkj, sigma, lambda);
                qi_results_tmp(:,j) = krr_testing(krr(k,j), X);
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
        krr(k) = krr_training(Xk, Tk, sigma, lambda);
        for j = 1:size_of_action_space
            Xjtmp = X;
            Xjtmp(:,end) = action_space(j);
            qi_results_tmp(:,j) = krr_testing(krr(k), Xjtmp);
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