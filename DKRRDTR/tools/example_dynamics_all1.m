function [TotalTime, NumActions, InitialWellness] = example_dynamics_all1(e_test, num_stages)

size_of_action_space = 2;

W = cell(num_stages+1,1);                     % Wellness
M = cell(num_stages+1,1);                     % Tumor size
W_action = cell(num_stages,1);                % Wellness after action
M_action = cell(num_stages,1);                % Tumor after action
mu = cell(num_stages,1);                      % expectation as a result of action
T = cell(num_stages,1);                       % actual failure time
R = cell(num_stages,1);                       % time to go to next stage
U = cell(num_stages,1);                       % minimum between failure, time to move to next stage and end of trial
AtRisk = cell(num_stages+1,1);
W_actual = cell(num_stages+1,1);

if e_test.seed > 0
    rng(e_test.seed)
end

% Initialize the wellness and tumor size
W{1} = e_test.IW(1) + (e_test.IW(2)-e_test.IW(1)).*rand(e_test.n,1);
M{1} = ones(e_test.n,1);                     % tumor size
AtRisk{1} = ones(e_test.n,2);                % at risk at time zero
W_actual{1} = W{1};

% Test
for i = 1:num_stages
    Wi = W{i};
    Mi = M{i};

    % assign the different action imidiate results
    for j = 1:size_of_action_space^(i-1)   % j = 1,2,4
        for k = 1:size_of_action_space
            W_action{i} = [W_action{i},Wi(:,j)-e_test.actions(k,1)];
            M_action{i} = [M_action{i},e_test.actions(k,2)./Wi(:,j)];
        end
    end
    
    R{i} = (1/e_test.Mdot)*(1-M_action{i})./M_action{i};
    
    W{i+1} = W_action{i} + (1-W_action{i}).*(1-2.^(-e_test.Wdot*R{i}));
    M{i+1} = M_action{i} + e_test.Mdot*M_action{i}.*R{i};
    
    
    mu_i = e_test.c0*(W_action{i}+e_test.c1)./M_action{i};
    mu_i(W_action{i}<e_test.failure) = 0;
    mu{i} = mu_i;
    
    T{i} = exprnd(mu{i});

    if i == 1 
        T{i} = min(T{i},e_test.max); 
    else
        T_tmp = zeros(e_test.n, size_of_action_space^i);
        for k = 1:i-1
            T_tmp = T_tmp + expend_matrix(U{k}, size_of_action_space^(i-k));
        end
        T{i} = min(T{i}, e_test.max-T_tmp);
    end
       
    T{i}(AtRisk{i}==0) = 0;    
    U{i} = min(T{i}, R{i});

    W_actual{i+1} = W_action{i} + (1-W_action{i}).*(1-2.^(-e_test.Wdot*U{i}));
    W_actual{i+1}(AtRisk{i}==0) = 0;

    AtRisk{i+1} = T{i}>R{i};
    AtRisk{i+1} = expend_matrix(AtRisk{i+1},2);
end

% We compute the total time. Total time is an size_of_action_space^num_stages (e.g., 2^3) 
% columns matrix. We check what was the best time for each line and what was the time for
% fixed policy.
TotalTime = zeros(e_test.n, size_of_action_space^num_stages);
NumActions = TotalTime;
for i = 1:num_stages
    U{i} = expend_matrix(U{i}, size_of_action_space^(num_stages-i));
    AtRisk{i} = expend_matrix(AtRisk{i}, size_of_action_space^(num_stages-i));
    TotalTime = TotalTime + U{i};
    NumActions = NumActions + AtRisk{i};
end
InitialWellness=W{1};