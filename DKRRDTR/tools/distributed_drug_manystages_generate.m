% generate n sets of trajectories

% opt.fea_mode:
%     'markov';                 % the process obeys Markov assumption.
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes the states
                                % and actions of previous opt.fea_steps stages. It should be noted that if 
                                % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% opt.action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously

% opt.fea_steps                 % the number of previous stages considered or the input at the current stages
                                % opt.fea_steps is equal to 1 when opt.fea_mode is markov

function qd =  distributed_drug_manystages_generate(example, opt)

if nargin < 2
    fea_mode = 'markov';
    action_mode = 'separate';
    num_machines = 100;
    split_mode = 'equal';
    fea_steps = 1;
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
    num_machines = opt.num_machines;
    split_mode = opt.split_mode;
    if strcmp(fea_mode, 'markov')
        fea_steps = 1;
    else
        fea_steps = opt.fea_steps;
    end
    if strcmp(opt.split_mode, 'unequal')
        if ~isfield(opt, 'N0min')
            N0min = 10;
        else
            N0min = opt.N0min;
        end
    end
end

if( example.seed>0)
    rng(example.seed)
end


a = example.a;                                           % the cofficients for death of immune cell, tumor cell and normal cell due to medicine toxicity
b = example.b;                                           % the reciprocal carrying capacity for tumor cell and normal cell in the logistic growth law
c = example.c;                                           % the cofficients for death due to other cells
d = example.d;                                           % the cofficient for death of immune cell due to immune cell, and the cofficient for decay of drug concentration
r = example.r;                                           % the growth rate for tumor cell and normal cell in the logistic growth law
alpha = example.alpha;
rho = example.rho;
s = example.s;
deltaT = example.deltaT;
num_stages_trajectory = example.days/example.deltaT;
num_stages_training = opt.num_stages;

N = zeros(example.n, num_stages_trajectory+1);           % the normal cell population
N(:,1) = example.N0;                                     % the initial condition of the normal cell population
T = zeros(example.n, num_stages_trajectory+1);           % the tumor cell population
T(:,1) = example.T0;                                     % the initial condition of the tumor cell population
I = zeros(example.n, num_stages_trajectory+1);           % the immune cell population
I(:,1) = example.I0;                                     % the initial condition of the immune cell population 
B = zeros(example.n, num_stages_trajectory+1);           % drug concentration
B(:,1) = example.B0;                                     % the initial drug concentration

R = zeros(example.n, num_stages_trajectory);

A = unidrnd(2,example.n,num_stages_trajectory)-1;        % actions: action matrix with size example.n X num_stages_trajectory, 
                                                         % and each row includes the action numbers of the three stages for each person

for i = 1:num_stages_trajectory
    ee = 1 - exp(-B(:,i));
    N(:,i+1) = N(:,i) + deltaT * (r(2)*N(:,i).*(1-b(2)*N(:,i)) - c(4)*T(:,i).*N(:,i) - a(3)*ee.*N(:,i));
    T(:,i+1) = T(:,i) + deltaT * (r(1)*T(:,i).*(1-b(1)*T(:,i)) - c(2)*I(:,i).*T(:,i) - c(3)*T(:,i).*N(:,i) - a(2)*ee.*T(:,i));
    I(:,i+1) = I(:,i) + deltaT * (s + (rho*I(:,i).*T(:,i))./(alpha+T(:,i)) - c(1)*I(:,i).*T(:,i) - d(1)*I(:,i) - a(1)*ee.*I(:,i));
    B(:,i+1) = B(:,i) + deltaT * (-d(2)*B(:,i) + A(:,i));
    R(:,i) = (N(:,i) + I(:,i) - T(:,i) - A(:,i)).*deltaT;
end

A = A + 1;                                               % in order to make the action belongs to the set {1,2}


NE = zeros(example.n, num_stages_trajectory+fea_steps);
TE = zeros(example.n, num_stages_trajectory+fea_steps);
IE = zeros(example.n, num_stages_trajectory+fea_steps);
BE = zeros(example.n, num_stages_trajectory+fea_steps);
AE = zeros(example.n, num_stages_trajectory+fea_steps-1);
NE(:, fea_steps:end) = N;
TE(:, fea_steps:end) = T;
IE(:, fea_steps:end) = I;
BE(:, fea_steps:end) = B;
AE(:, fea_steps:end) = A;

fea_idx_begin = 1:num_stages_trajectory;
fea_idx_end = fea_steps:num_stages_trajectory+fea_steps-1;
num_segment = num_stages_trajectory/num_stages_training;

qd_cell = cell(num_segment, num_stages_training);
count = 0;
for j = 1:num_segment
    for k = 1:num_stages_training
        count = count + 1;
        idx_tmp = fea_idx_begin(count):fea_idx_end(count);
        qd_cell{j,k} = set_drug_qtrajectory_data(NE, TE, IE, BE, AE, R, idx_tmp, fea_mode, action_mode);
    end
end

qdtrue = merge_drug_qtrajectory_data(qd_cell);

num_training_samples = num_segment * example.n;

if strcmp(split_mode, 'equal')           % data is equally distributed  
    [Nvec, idx_local] = EqualSplitData(num_training_samples, num_machines);
end

if strcmp(split_mode, 'unequal')         % data is unequally distributed  
    [Nvec, idx_local] = RandSplitData(num_training_samples, N0min, num_machines);
end
Nr = Nvec/num_training_samples;                           % the percentages of data in local machines

qd.data = qdtrue;
qd.idx_local = idx_local;
qd.Nr = Nr;
qd.num_machines = num_machines;
qd.infos.stages = num_stages_training;
qd.infos.size_of_action_space = length(unique(A));
qd.infos.fea_mode = fea_mode;
qd.infos.action_mode = action_mode;



% NS1 = [];
% TS1 = [];
% IS1 = [];
% BS1 = [];
% AS1 = [];
% RS1 = [];
% for i = 1:num_segment
%     ix_begin = (i-1)*num_stages_training+1;
%     ix_end = i*num_stages_training;
%     NS1 = [NS1; N(:,ix_begin:ix_end)];
%     TS1 = [TS1; T(:,ix_begin:ix_end)];
%     IS1 = [IS1; I(:,ix_begin:ix_end)];
%     BS1 = [BS1; B(:,ix_begin:ix_end)];
%     AS1 = [AS1; A(:,ix_begin:ix_end)];
%     RS1 = [RS1; R(:,ix_begin:ix_end)];
% end

% plot(0:0.25:150, N, 'LineStyle', '-.', 'LineWidth', 2, 'Color', [1.00,0.41,0.16]);
% hold on;
% plot(0:0.25:150, T, 'LineStyle', '--', 'LineWidth', 2, 'Color', [0.47,0.67,0.19]);
% hold on;
% plot(0:0.25:150, I, 'LineStyle', ':', 'LineWidth', 2, 'Color', [0.72,0.27,1.00]);
% hold on;
% plot(0:0.25:150, B, 'LineStyle', '-', 'LineWidth', 1, 'Color', [0.07,0.62,1.00]);
