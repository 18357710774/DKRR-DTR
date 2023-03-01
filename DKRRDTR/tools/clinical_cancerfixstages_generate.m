% generate n sets of trajectories

% opt.fea_mode:
%     'markov';                 % the process obeys Markov assumption
%     'markov_non';             % the process does not obey Markov assumption

function qd =  clinical_cancerfixstages_generate(a, opt)

if nargin < 2
    fea_mode = 'markov';
    action_mode = 'mix';
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
end

if( a.seed>0)
    rng(a.seed)
end

num_stages = opt.num_stages;
% ----------------------------------------------------------------------------------------------
W = zeros(a.n,num_stages+1);                        % wellness: negative part of wellness, i.e., toxicity.
W(:,1) = a.IW(1) + (a.IW(2)-a.IW(1)).*rand(a.n,1);  % the initial wellness are drawn uniformly from
                                                    % the segment [a.IW(1), a.IW(2)].
M = zeros(a.n,num_stages+1);                        % tumor size: the first column is the initial tumor size
M(:,1) = a.IM(1) + (a.IM(2)-a.IM(1)).*rand(a.n,1);  % the initial tumor sizes are drawn uniformly from
                                                    % the segment [a.IM(1), a.IM(2)].
R = zeros(a.n,num_stages);                          % rewards


AtRisk = [ones(a.n,1),zeros(a.n,num_stages)];       % AtRisk(:,i) is one if the patiant is at risk at the begining of stage i


A = zeros(a.n,num_stages);                                                % actions: action matrix with size a.n X num_stages, and each row includes 
                                                                          % the drug levels of the stages for each person
n1 = floor((a.actions1(2)-a.actions1(1))/a.increment);
A(:,1) = a.actions1(1) + a.increment.*unidrnd(n1, a.n, 1);                % the drug level of the first stage are drawn uniformly 
                                                                          % from the segment [a.actions1(1), a.actions1(2)]. 

n2 = floor((a.actions2(2)-a.actions2(1))/a.increment);
A(:,2:end) = a.actions2(1) + a.increment.*unidrnd(n2, a.n, num_stages-1); % the drug level of the first stage are drawn uniformly 
                                                                          % from the segment [a.actions2(1), a.actions2(2)].

action_space = zeros(num_stages, 3);
action_space(1,:) = [a.actions1(1)+a.increment a.increment a.actions1(2)];
action_space(2:end, :) = repmat([a.actions2(1)+a.increment a.increment a.actions2(2)], num_stages-1, 1);

size_of_action_space = zeros(1,num_stages);
size_of_action_space(1) = length(action_space(1,1):action_space(1,2):action_space(1,3));
size_of_action_space(2:end) = length(action_space(2,1):action_space(2,2):action_space(2,3));

delta_lambda = zeros(a.n,num_stages);                                     % delta_lambda(:,i) is the cumulative hazard value of the i-th stage
death_p = zeros(a.n,num_stages);                                          % death_p(:,i) is the probability of death at the i-th stage

for i = 1:num_stages
    W(:,i+1) = W(:,i) + a.states(1,1)*max(M(:,i), M(:,1))...
        + a.states(1,2)*(A(:,i)-a.states(1,3));                           % W(t+1) = W(t) + a.states(1,1)*max(M(:,t), M(:,1)) + a.state(1,2)*(A(:,t)-a.state(1,3))
    M(:,i+1) = M(:,i) + a.states(2,1)*max(W(:,i), W(:,1))... 
        - a.states(2,2)*(A(:,i)-a.states(2,3));                           % M(t+1) = M(t) + a.states(2,1)*max(W(:,t), W(:,1)) - a.state(2,2)*(A(:,t)-a.state(2,3))
    M(:,i+1) = M(:,i+1).*double(M(:,i+1)>0);
    W(AtRisk(:,i)==0, i+1) = W(AtRisk(:,i)==0, i);                        % if patient is dead or cured at current stage, the wellness and tumor size of the right 
    M(AtRisk(:,i)==0, i+1) = M(AtRisk(:,i)==0, i);                        % endpoints at the next stage are equals to the ones at the current stage  

    delta_lambda(:,i) = exp(a.mu(1)+a.mu(2)*W(:,i+1)+a.mu(3)*M(:,i+1));   % lambda(s) = exp(mu0+mu1*W(s)+mu2*M(s))  for s \in (t-1, t]
                                                                          % delta_lambda(t) = integral_{t-1}^t lambda(s)ds
    death_p(:,i) = 1 - exp(-delta_lambda(:,i));                           % the death probability: p = 1-exp(-delta_lambda(t))
    AtRisk(:,i+1) = (rand(a.n,1) > death_p(:,i)) & AtRisk(:,i)>0 ...      % if the patient steps into the next stage 
                     & M(:,i+1)>0;                                        % (i.e., not dead or not cured at current stage), AtRisk = 1
%     number_rand(:,i) = rand(a.n,1);
%     AtRisk(:,i+1) = ( number_rand(:,i) > death_p(:,i)) & AtRisk(:,i)>0 ...      % if the patient steps into the next stage 
%                      & M(:,i+1)>0;                                        % (i.e., not dead or not cured at current stage), AtRisk = 1                                                       
    R(:,i) = reward_compute(A(:,i), W(:,i:i+1), M(:,i:i+1), AtRisk(:,i+1), a);
end

qdtrue = cell(1, num_stages); 

if strcmp(fea_mode, 'markov')
    for i = 1:num_stages
        qdtrue{i} = set_cancer_qtrajectory_data(W(:,i), M(:,i), A(:,i), ...
                                         R(:,i), AtRisk(:,i), action_space(i,:), fea_mode, action_mode);
    end
else
    for i = 1:num_stages
        qdtrue{i} = set_cancer_qtrajectory_data(W(:,1:i), M(:,1:i), A(:,1:i), ...
                                         R(:,i), AtRisk(:,i), action_space(i,:), fea_mode, action_mode);
    end
end
qd.data = qdtrue;
qd.infos.stages = num_stages;
qd.infos.size_of_action_space = size_of_action_space;
qd.infos.fea_mode = fea_mode;
qd.infos.action_mode = action_mode;


% if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'separate')
%     for i = 1:num_stages
%         dattmp.X = [W(:,i) M(:,i)];
%         dattmp.A = A(:,i);
%         dattmp.U = R(:,i);
%         dattmp.AtRisk = AtRisk(:,i);  
%         dattmp.action_space = action_space(i,:);
%         qdtrue{i} = dattmp;
%         clear dattmp;
%     end
% end
% 
% if strcmp(fea_mode, 'markov') && strcmp(action_mode, 'mix')
%     for i = 1:num_stages
%         dattmp.X = [W(:,i) M(:,i) A(:,i)];
%         dattmp.A = A(:,i);
%         dattmp.U = R(:,i);
%         dattmp.AtRisk = AtRisk(:,i);  
%         dattmp.action_space = action_space(i,:);
%         qdtrue{i} = dattmp;
%         clear dattmp;
%     end
% end
% 
% if strcmp(fea_mode, 'markov_non') && strcmp(action_mode, 'mix')
%     for i = 1:num_stages
%         dattmp.X = [W(:,1:i) M(:,1:i) A(:,1:i)];
%         dattmp.A = A(:,1:i);
%         dattmp.U = R(:,i);
%         dattmp.AtRisk = AtRisk(:,i);
%         dattmp.action_space = action_space(i,:);
%         qdtrue{i} = dattmp;
%         clear dattmp;
%     end
% end

% qd.data = qdtrue;
% qd.infos.stages = num_stages;
% qd.infos.fea_mode = fea_mode;
