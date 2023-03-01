function [maxQi_plus_one, algo, time_cost] =  cancer_qfunction_training(algo, dat)

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

[X, T, A, ~, ~, ~, Aspace] = get_qtrajectory_data(qi);
action_space = Aspace(1):Aspace(2):Aspace(3);
size_of_action_space = length(action_space);

algo.action_space = action_space;

n = size(X, 1);

if(~isempty(maxQi_plus_one))
    T = T + maxQi_plus_one;
end

% We compute for each action j its appropriate qfunction and set it into lsj.
% We also compute the value of q_i(T,j) for all j and set it in qi_results       

switch algoname
    case 'ls' 
        qi_results = zeros(n, size_of_action_space);
        ls = struct('b0', {}, 'beta', {});
        if strcmp(action_mode, 'separate')
            tic;
            for j=1:size_of_action_space
                Aj = action_space(j);
                Xj = X(A==Aj,:);
                Tj = T(A==Aj);
                if isempty(Xj)
                    ls(j).b0 = [];
                    ls(j).beta = [];
                    qi_results(:,j) = -inf;
                else
                    ls(j) = lsw_training(Xj, Tj);
                    qi_results(:,j) = lsw_testing(ls(j), X);
                end
            end
            time_cost = toc;
        else
            tic;
            ls = lsw_training(X, T);
            for j=1:size_of_action_space
                Xjtmp = X;
                Xjtmp(:,end) = action_space(j);
                qi_results(:,j) = lsw_testing(ls, Xjtmp);
            end
            time_cost = toc;
        end
        algo.algos = ls;
    case 'krr' 
        sigma = algo.params(1);
        lambda = algo.params(2);
        qi_results = zeros(n, size_of_action_space);

        krr = struct('x', {}, 'alpha', {}, 'sigma', {}, 'lambda', {});
        if strcmp(action_mode, 'separate')
            tic;
            for j=1:size_of_action_space
                Aj = action_space(j);
                Xj = X(A==Aj,:);
                Tj = T(A==Aj);
                if isempty(Xj)
                    krr(j).x = [];
                    krr(j).alpha = [];
                    krr(j).sigma = [];
                    krr(j).lambda = [];
                    qi_results(:,j) = -inf;
                else
                    krr(j) = krr_training(Xj, Tj, sigma, lambda);
                    qi_results(:,j) = krr_testing(krr(j), X);
                end
            end
            time_cost = toc;
        else
            tic;
            krr = krr_training(X, T, sigma, lambda);
            for j=1:size_of_action_space
                Xjtmp = X;
                Xjtmp(:,end) = action_space(j);
                qi_results(:,j) = krr_testing(krr, Xjtmp);
            end
            time_cost = toc;
        end
        algo.algos = krr;
    case 'fcnet' 
        hidden_neuron_number = algo.params.hidden_neuron_number;
        hidden_layers_number = algo.params.hidden_layers_number;
        initializer = algo.params.initializer;
        act_type = algo.params.act_type;
        train_options = algo.params.train_options;

        hidden_neuron_numbers = hidden_neuron_number*ones(1,hidden_layers_number);      
        
        d_in = size(X, 2);
        d_out = 1;
        modnet = fcnet(d_in, d_out, hidden_neuron_numbers, act_type, initializer);

        qi_results = zeros(n, size_of_action_space);

        fc = struct('fc_model', {});
        if strcmp(action_mode, 'separate')
            tic;
            for j=1:size_of_action_space
                Aj = action_space(j);
                Xj = X(A==Aj,:);
                Tj = T(A==Aj);
                if isempty(Xj)
                    fc(j).fc_model = [];
                    qi_results(:,j) = -inf;
                else
                    fc(j).fc_model = trainNetwork(Xj,Tj,modnet,train_options);
                    qi_results(:,j) = predict(fc(j).fc_model, X);  
                end                    
            end
            time_cost = toc;
        else
            tic;
            fc(1).fc_model = trainNetwork(X,T,modnet,train_options);
            for j=1:size_of_action_space
                Xjtmp = X;
                Xjtmp(:,end) = action_space(j);
                qi_results(:,j) = predict(fc(1).fc_model, Xjtmp);
            end
            time_cost = toc;
        end
        algo.algos = fc;
end
% compute the values and indices of the best action at stage i
maxQi_plus_one = max(qi_results, [], 2); 
