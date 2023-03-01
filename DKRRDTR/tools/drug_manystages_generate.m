% generate n sets of trajectories

% opt.fea_mode:
%     'markov_single';          % the process obeys Markov assumption, and the input feature includes only wellness.
%                               % It should be noted that if fea_mode is setted as 'markov_non', the action_mode should be 'mix'
%                               % fea_mode is setted as 'markov_single', the action_mode should be 'separate'
%     'markov_multi';           % the process obeys Markov assumption, and the input feature includes wellness and previous reward
%     'markov_non';             % the process does not obey Markov assumption, and the input feature includes all wellness, 
%                               % previous reward, and actions from stage 1 to current stage. It should be noted that if 
%                               % fea_mode is setted as 'markov_non', the action_mode should be 'mix'

% opt.action_mode:
%     'separate';               % construct Q-function for each action separately
%     'mix';                    % construct Q-function for all actions simutaneously

function qd =  drug_manystages_generate(example, opt)


if nargin < 2
    fea_mode = 'markov_single';
    action_mode = 'separate';
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
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
days = example.days;
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
% A = zeros(1, num_stages_trajectory);
% A(:,1:480) = repmat(repelem([1 0], [1 3]), 1, 120);
for i = 1:num_stages_trajectory
    ee = 1 - exp(-B(:,i));
    N(:,i+1) = N(:,i) + deltaT * (r(2)*N(:,i).*(1-b(2)*N(:,i)) - c(4)*T(:,i).*N(:,i) - a(3)*ee.*N(:,i));
    T(:,i+1) = T(:,i) + deltaT * (r(1)*T(:,i).*(1-b(1)*T(:,i)) - c(2)*I(:,i).*T(:,i) - c(3)*T(:,i).*N(:,i) - a(2)*ee.*T(:,i));
    I(:,i+1) = I(:,i) + deltaT * (s + (rho*I(:,i).*T(:,i))./(alpha+T(:,i)) - c(1)*I(:,i).*T(:,i) - d(1)*I(:,i) - a(1)*ee.*I(:,i));
    B(:,i+1) = B(:,i) + deltaT * (-d(2)*B(:,i) + A(:,i));
    R(:,i) = (N(:,i) + I(:,i) - T(:,i) - A(:,i)).*deltaT;
end

num_segment = floor(num_stages_trajectory/num_stages_training);

N_cell = mat2cell(N(:,1:num_stages_trajectory), example.n, num_stages_training * ones(1,num_segment));
NS = cell2mat(N_cell(:));

T_cell = mat2cell(T(:,1:num_stages_trajectory), example.n, num_stages_training * ones(1,num_segment));
TS = cell2mat(T_cell(:));

I_cell = mat2cell(I(:,1:num_stages_trajectory), example.n, num_stages_training * ones(1,num_segment));
IS = cell2mat(I_cell(:));

B_cell = mat2cell(B(:,1:num_stages_trajectory), example.n, num_stages_training * ones(1,num_segment));
BS = cell2mat(B_cell(:));

A_cell = mat2cell(A(:,1:num_stages_trajectory), example.n, num_stages_training * ones(1,num_segment));
AS = cell2mat(A_cell(:));

R_cell = mat2cell(R(:,1:num_stages_trajectory), example.n, num_stages_training * ones(1,num_segment));
RS = cell2mat(R_cell(:));

qdtrue = cell(1, num_stages_training); 

if strcmp(fea_mode, 'markov')
    for i = 1:num_stages_training
        qdtrue{i} = set_drug_qtrajectory_data(NS(:,i), TS(:,i), IS(:,i), BS(:,i), ... 
                                                         AS(:,i), RS(:,i), fea_mode, action_mode);
    end
else
    for i = 1:num_stages_training
        qdtrue{i} = set_drug_qtrajectory_data(NS(:,1:i), TS(:,1:i), IS(:,1:i), BS(:,1:i), ...
                                                         AS(:,1:i), RS(:,i), fea_mode, action_mode);
    end
end

qd.data = qdtrue;
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
