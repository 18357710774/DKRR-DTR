function [CSP, time_cost, W_end, M_end, WM_end, pi_actions, bb] = cancer_example_dynamics(valgo, a, opt)

if nargin < 2
    fea_mode = 'markov';
    action_mode = 'mix';
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
end

% Initialize the wellness and tumor size
if a.seed>0
    rng(a.seed)
end


num_stages = opt.num_stages;
W = zeros(a.n,num_stages+1);                        % wellness: negative part of wellness, i.e., toxicity.
W0 = a.IW(1) + (a.IW(2)-a.IW(1)).*rand(a.n,1);      % the initial wellness are drawn uniformly from
W(:,1) = W0;                                        % the segment [a.IW(1), a.IW(2)].

M = zeros(a.n,num_stages+1);                        % tumor size: the first column is the initial tumor size
M0 = a.IM(1) + (a.IM(2)-a.IM(1)).*rand(a.n,1);      % the initial tumor sizes are drawn uniformly from
M(:,1) = M0;                                        % the segment [a.IM(1), a.IM(2)].

R = zeros(a.n,num_stages);                          % rewards

AtRisk = [true(a.n,1),false(a.n,num_stages)];       % AtRisk(:,i) is one if the patiant is at risk at the begining of stage i
Death = false(a.n, num_stages+1);                   % death: if the elment equals to 1, then the corresponding patient is dead
Cured = false(a.n, num_stages+1);                   % cured: if the elment equals to 1, then the corresponding patient is cured
 
pi_actions = zeros(a.n, num_stages);                 % the actions taken by the valgo

time_cost = struct('time_action_predict', {}, 'time_state_compute', {});
% Test
for i = 1:num_stages
    action_space = valgo{i}.action_space;
    X = set_cancer_qtrajectory_test_data(W, M, pi_actions, i, action_space, fea_mode, action_mode);
    
    [pi_actions(:, i), time_cost_tmp] = cancer_qfunction_testing(valgo{i}, X);
    time_cost(i).time_action_predict = time_cost_tmp;

    tic;
    [W(:,i+1), M(:,i+1), R(:,i), AtRisk(:,i+1), Death(:,i+1), Cured(:,i+1)] = ...
        cancer_status_computation(W(:,i), W0, M(:,i), M0, a, pi_actions(:,i), AtRisk(:,i), Death(:,i), Cured(:,i));
    ttmp = toc;
    time_cost(i).time_state_compute = ttmp;
end

AAA = double(AtRisk) + double(Cured) + double(Death);
AAAS = sum(AAA, 1);
bb = all(AAAS==a.n);

Survival = Cured(:,end) | AtRisk(:,end);
CSP = mean(double(Survival));                        % cumulative survival probability

W_end = W(:,end);
M_end = M(:,end);
WM_end = W(:,end) + M(:,end);


