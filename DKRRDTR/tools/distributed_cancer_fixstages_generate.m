% generate n sets of trajectories

% opt.fea_mode:
%     'markov';                 % the process obeys Markov assumption, and the input feature includes only wellness and tumor size.
%                              
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes all wellness, 
%                               % tumor size, and actions from stage 1 to current stage. It should be noted that if 
%                               % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% opt.action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously

function qd =  distributed_cancer_fixstages_generate(a, opt)


if nargin < 2
    fea_mode = 'markov';
    action_mode = 'mix';
    num_machines = 10;
    split_mode = 'equal';
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
    num_machines = opt.num_machines;
    split_mode = opt.split_mode;
    if strcmp(opt.split_mode, 'unequal')
        if ~isfield(opt, 'N0min')
            N0min = 10;
        else
            N0min = opt.N0min;
        end
    end
end

if( a.seed>0)
    rng(a.seed)
end


if strcmp(split_mode, 'equal')           % data is equally distributed  
    [Nvec, idx_local] = EqualSplitData(a.n, num_machines);
end

if strcmp(split_mode, 'unequal')         % data is unequally distributed  
    [Nvec, idx_local] = RandSplitData(a.n, N0min, num_machines);
end
Nr = Nvec/a.n;                           % the percentages of data in local machines

num_stages = opt.num_stages;

W = zeros(a.n,num_stages+1);                        % wellness: negative part of wellness, i.e., toxicity.
W0 = a.IW(1) + (a.IW(2)-a.IW(1)).*rand(a.n,1);      % the initial wellness are drawn uniformly from
W(:,1) = W0;                                        % the segment [a.IW(1), a.IW(2)].
M = zeros(a.n,num_stages+1);                        % tumor size: the first column is the initial tumor size
M0 = a.IM(1) + (a.IM(2)-a.IM(1)).*rand(a.n,1);      % the initial tumor sizes are drawn uniformly from
M(:,1) = M0;                                        % the segment [a.IM(1), a.IM(2)].
R = zeros(a.n,num_stages);                          % rewards

AtRisk = [true(a.n,1),false(a.n,num_stages)];       % AtRisk(:,i) is one if the patiant is at risk at the begining of stage i

A = zeros(a.n,num_stages);                                                % actions: action matrix with size a.n X num_stages, and each row includes 
                                                                          % the drug levels of the stages for each person
n1 = floor((a.actions1(2)-a.actions1(1))/a.increment);
A(:,1) = a.actions1(1) + a.increment.*unidrnd(n1, a.n, 1);                % the drug level of the first stage are drawn uniformly 
                                                                          % from the segment [a.actions1(1), a.actions1(2)]. 

n2 = floor((a.actions2(2)-a.actions2(1))/a.increment);
A(:,2:end) = a.actions2(1) + a.increment.*unidrnd(n2, a.n, num_stages-1); % the drug level of the first stage are drawn uniformly 
                                                                          % from the segment [a.actions2(1), a.actions2(2)]
Death = false(a.n,num_stages+1);                                          % death: if the elment equals to 1, then the corresponding patient is dead
Cured = false(a.n,num_stages+1);                                          % cured: if the elment equals to 1, then the corresponding patient is cured
 
action_space = zeros(num_stages, 3);
action_space(1,:) = [a.actions1(1)+a.increment a.increment a.actions1(2)];
action_space(2:end, :) = repmat([a.actions2(1)+a.increment a.increment a.actions2(2)], num_stages-1, 1);

size_of_action_space = zeros(1,num_stages);
size_of_action_space(1) = length(action_space(1,1):action_space(1,2):action_space(1,3));
size_of_action_space(2:end) = length(action_space(2,1):action_space(2,2):action_space(2,3));

for i = 1:num_stages
    [W(:,i+1), M(:,i+1), R(:,i), AtRisk(:,i+1), Death(:,i+1), Cured(:,i+1)] = ...
            cancer_status_computation(W(:,i), W0, M(:,i), M0, a, A(:,i), AtRisk(:,i), Death(:,i), Cured(:,i));
end

qdtrue = cell(1, num_stages); 

if strcmp(fea_mode, 'markov')
    for i = 1:num_stages
        qdtrue{i} = set_cancer_qtrajectory_data(W(:,i), M(:,i), A(:,i), ...
                                         R(:,i), AtRisk(:,i), Death(:,i), Cured(:,i), action_space(i,:), fea_mode, action_mode);
    end
else
    for i = 1:num_stages
        qdtrue{i} = set_cancer_qtrajectory_data(W(:,1:i), M(:,1:i), A(:,1:i), ...
                                         R(:,i), AtRisk(:,i), Death(:,i), Cured(:,i), action_space(i,:), fea_mode, action_mode);
    end
end

qd.data = qdtrue;
qd.idx_local = idx_local;
qd.Nr = Nr;
qd.num_machines = num_machines;
qd.infos.stages = num_stages;
qd.infos.size_of_action_space = size_of_action_space;
qd.infos.fea_mode = fea_mode;
qd.infos.action_mode = action_mode;
