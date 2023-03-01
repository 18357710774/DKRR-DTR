function [qi_results, fc, time_cost] = distributed_fcnet_training(X, T, A, algo, action_mode, split_info)

hidden_neuron_number = algo.params.hidden_neuron_number;
hidden_layers_number = algo.params.hidden_layers_number;
initializer = algo.params.initializer;
act_type = algo.params.act_type;
train_options = algo.params.train_options;
hidden_neuron_numbers = hidden_neuron_number*ones(1,hidden_layers_number);      
[n, d_in] = size(X);
d_out = 1;
modnet = fcnet(d_in, d_out, hidden_neuron_numbers, act_type, initializer);

size_of_action_space = algo.size_of_action_space;
idx_local = split_info.idx_local;
Nr = split_info.Nr;
num_machines = length(Nr);

%% ----------- synthesize using loop ---------------------
qi_results = zeros(n, size_of_action_space);
fc = struct('fc_model', {});

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
            fc(k,j).fc_model = trainNetwork(Xkj, Tkj, modnet, train_options);
            qi_results_tmp(:,j) = predict(fc(k,j).fc_model, X); 
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
        fc(k).fc_model = trainNetwork(Xk, Tk, modnet, train_options);
        for j = 1:size_of_action_space
            Xjtmp = X;
            Xjtmp(:,end) = j;
            qi_results_tmp(:,j) = predict(fc(k).fc_model, Xjtmp);
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
% fc = struct('fc_model', {});
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
%             fc(k,j).fc_model = trainNetwork(Xkj, Tkj, modnet, train_options);
%             qi_results_all(:,j,k) = predict(fc(k,j).fc_model, X); 
%         end
%         ttmp = toc;
%         time_local(k) = ttmp;
%     end
% else                
%     for k = 1:num_machines
%         Xk = X(idx_local{k},:);
%         Tk = T(idx_local{k},:);
%         tic;
%         fc(k).fc_model = trainNetwork(Xk, Tk, modnet, train_options);
%         for j = 1:size_of_action_space
%             Xjtmp = X;
%             Xjtmp(:,end) = j;
%             qi_results_all(:,j,k) = predict(fc(k).fc_model, Xjtmp);
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