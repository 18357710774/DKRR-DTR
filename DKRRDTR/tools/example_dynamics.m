function [total_time_hat, time_cost, num_actions_hat, end_trial_hat, initial_wellness] = example_dynamics(valgo, a, opt)

if nargin < 2
    fea_mode = 'markov_single';
    action_mode = 'separate';
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
end

% Initialize the wellness and tumor size
if a.seed>0
    rng(a.seed)
end

size_of_action_space = valgo{1}.size_of_action_space;
num_stages = opt.num_stages;
% ----------------------------------------------------------------------------------------------
% W, Wa, M, Ma, and R are the theoretical values for wellness, immediate wellness of an action,
% tumor size, immediate tumor size of an action, and time length of a stage, respectively, without
% consideration of failures and the end of the trial.
W = zeros(a.n,num_stages+1);  % wellness: the first column is the initial wellness and the last three columns
                              %           are the wellness in the subsequent three stages.
W(:,1) = a.IW(1) + (a.IW(2)-a.IW(1)).*rand(a.n,1);  % the initial wellness are drawn uniformly from
                                                    % the segment [a.IW(1), a.IW(2)].
M = zeros(a.n,num_stages+1);  % tumor size: the first column is the initial tumor size and the last three columns 
                              % are the tumor sizes in the subsequent three stages.
M(:,1) = 1;
Rpre = zeros(a.n,num_stages+1);
R = zeros(a.n,num_stages);                     % R(:,i) is the  length of the i-th stage by the dynamic
Wa = zeros(a.n,num_stages);                    % Wa(:,i) is the wellness after the i-th action;
Ma = zeros(a.n,num_stages);                    % Ma(:,i) is the tumor size after the i-th action;

% ----------------------------------------------------------------------------------------------
% AtRisk(j,i) indicates whether the j-th trajectory ends or not at the i-th theoretical stage  
% AtRisk(:,i) = 1 indicates that the patient steps in stage i
% AtRisk(:,i) = 1 and AtRisk(:,i+1) = 0 mean that the patient fails or the trial ends at stage i
AtRisk = [ones(a.n,1),zeros(a.n,num_stages)];  % AtRisk(:,i) is one if the patiant is at risk at the begining of stage i


mu = zeros(a.n,num_stages);                    % mu(:,i) is the failure time expectation of the i-th stage
T = zeros(a.n,num_stages);                     % T(:,i) is the failure time
U = zeros(a.n,num_stages);                     % U(:,i)=min (T,R,a.max-sumT(i-1)) is the actual time in stage i;
sumUi = zeros(a.n,num_stages);                 % sumUi time up to and include stage i.
pi_actions = zeros(a.n,num_stages);            % the actions taken by the valgo

time_cost = struct('time_action_predict', {}, 'time_state_compute', {});
% Test
for i = 1:num_stages

    X = set_qtrajectory_test_data(W, Rpre, pi_actions, i, size_of_action_space, fea_mode, action_mode);

    [pi_actions(:, i), time_cost_tmp] = qfunction_testing(valgo{i}, X);
    time_cost(i).time_action_predict = time_cost_tmp;

    tic;
    if sum(pi_actions(:, i)) == 0
        Wa(:,i) = 0;
        Ma(:,i) = 0;
        R(:,i) = 0;
        mu(:,i) = 0;
    else
        [Wa(:,i), Ma(:,i), R(:,i), mu(:,i)] =  status_computation(W(:,i), a, pi_actions(:,i));
        R(AtRisk(:,i)==0,i) = 0;
    end

    mu(Wa(:,i)<a.failure,i) = 0;                             % W(u_i^+)<0.25 represents a failure, and the patient is dead?

    T(:,i) = exprnd(mu(:,i));  

    if i == 1
        T(:,1) = min(T(:,1), a.max);                         % maximum survival years, a.max = 3
    else
        T(:,i) = min(T(:,i), a.max-sum(U(:,1:i-1),2));       % survival time length from the beginning of stage i to the time 
                                                             % point in which the trial ends or a failure happens 
        T(AtRisk(:,i)==0,i) = 0;
    end
    U(:,i) = min(T(:,i),R(:,i));                             % the actual time in stage i: R(:,i) is the length of the i-th stage, and T(:,i) is the length from the begining of stage i to the failure occurrence
    sumUi(:,i) = sum(U(:,1:i),2);
    
    AtRisk(:,i+1) = T(:,i)>R(:,i);                           % if the patient steps into the next stage and no censoration happens, AtRisk = 1    
    
    W(:,i+1) = Wa(:,i)+(1-Wa(:,i)).*(1-2.^(-a.Wdot*U(:,i))); % W(u) = W(U_i^+) + (1-W(U_i^+)) * (1-2^(-0.5*(u-u_i)))
    W(AtRisk(:,i)==0, i+1) = 0;
    M(:,i+1) = Ma(:,i)+a.Mdot*Ma(:,i).*U(:,i);               % T(u) = T(u_i^+) + 4*T(u_i^+)(u-u_i)/3, all elements should be one 
                                                             % since the value u-u_i obtained from equation T(u)=1
    M(AtRisk(:,i)==0, i+1) = 0;
    Rpre(:,i+1) = U(:,i);
    ttmp = toc;
    time_cost(i).time_state_compute = ttmp;
end

total_time_hat = sumUi(:,num_stages);

% mean_total_time_hat = mean(total_time_hat);

num_actions_hat = sum(AtRisk, 2);

end_trial_hat = (total_time_hat == a.max);

initial_wellness = W(:,1);


