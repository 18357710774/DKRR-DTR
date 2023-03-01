function [qi_results, fc, time_cost] = distributed_cancer_fcnet_training(X, T, A, algo, action_mode, split_info)

hidden_neuron_number = algo.params.hidden_neuron_number;
hidden_layers_number = algo.params.hidden_layers_number;
initializer = algo.params.initializer;
act_type = algo.params.act_type;
train_options = algo.params.train_options;
hidden_neuron_numbers = hidden_neuron_number*ones(1,hidden_layers_number);      
[n, d_in] = size(X);
d_out = 1;
modnet = fcnet(d_in, d_out, hidden_neuron_numbers, act_type, initializer);

action_space = algo.action_space;
size_of_action_space = length(action_space);
idx_local = split_info.idx_local;
Nr = split_info.Nr;
num_machines = length(Nr);

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
            Akj = action_space(j);
            Xkj = Xk(Ak==Akj,:);
            Tkj = Tk(Ak==Akj,:); 
            if isempty(Xkj)
                fc(k,j).fc_model = [];
                qi_results_tmp(:,j) = -inf;
            else
                fc(k,j).fc_model = trainNetwork(Xkj, Tkj, modnet, train_options);
                qi_results_tmp(:,j) = predict(fc(k,j).fc_model, X); 
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
        fc(k).fc_model = trainNetwork(Xk, Tk, modnet, train_options);
        for j = 1:size_of_action_space
            Xjtmp = X;
            Xjtmp(:,end) = action_space(j);
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