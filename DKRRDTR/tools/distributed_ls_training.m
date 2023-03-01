function [qi_results, ls, time_cost] = distributed_ls_training(X, T, A, algo, action_mode, split_info)

size_of_action_space = algo.size_of_action_space;
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
            Xkj = Xk(Ak==j,:);
            Tkj = Tk(Ak==j,:); 
            ls(k,j) = lsw_training(Xkj, Tkj);
            qi_results_tmp(:,j) = lsw_testing(ls(k,j), X);
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
            Xjtmp(:,end) = j;
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

%% ----------- synthesize using matrix multiplication ---------------------
% qi_results = zeros(n, size_of_action_space);
% qi_results_all = zeros(n, size_of_action_space, num_machines);
% ls = struct('b0', {}, 'beta', {});
% 
% time_local = zeros(1,num_machines);
% if strcmp(action_mode, 'separate')
%     for k = 1:num_machines
%         Xk = X(idx_local{k},:);
%         Tk = T(idx_local{k},:);
%         Ak = A(idx_local{k},:);
%         tic;
%         for j = 1:size_of_action_space
%             Xkj = Xk(Ak==j,:);
%             Tkj = Tk(Ak==j,:); 
%             ls(k,j) = lsw_training(Xkj, Tkj);
%             qi_results_all(:,j,k) = lsw_testing(ls(k,j), X);
%         end
%         ttmp = toc;
%         time_local(k) = ttmp;
%     end
% else
%     for k = 1:num_machines
%         Xk = X(idx_local{k},:);
%         Tk = T(idx_local{k},:);
%         tic;
%         ls(k) = lsw_training(Xk, Tk);
%         for j = 1:size_of_action_space
%             Xjtmp = X;
%             Xjtmp(:,end) = j;
%             qi_results_all(:,j,k) = lsw_testing(ls(k), Xjtmp);
%         end
%         ttmp = toc;
%         time_local(k) = ttmp;
%     end
% end
% tic;
% for j = 1:size_of_action_space
%     qi_results(:,j) = squeeze(qi_results_all(:,j,:)) * Nr;
% end
% ttmp = toc;
% time_synthesize = ttmp;
% time_cost.time_local = time_local;
% time_cost.time_synthesize = time_synthesize;
