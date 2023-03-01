function [SumR_mean, N_mean, T_mean, I_mean, B_mean, R_mean] ...
            = distributed_drug_example_dynamics_allstages(vf, example, opt)
valgo = vf.qfunctions;
Nr = vf.info_split.Nr;

if nargin < 2
    fea_mode = 'markov';
    action_mode = 'separate';
    fea_steps = 1;
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
    if strcmp(fea_mode, 'markov')
        fea_steps = 1;
    else
        fea_steps = opt.fea_steps;
    end
end

% Initialize the wellness and tumor size
if example.seed>0
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

pi_actions = zeros(example.n, num_stages_trajectory);    % the actions taken by the valgo
A = zeros(example.n, num_stages_trajectory);


Ntmp = zeros(example.n, fea_steps);        
Ntmp(:,end) = example.N0;                                    
Ttmp = zeros(example.n, fea_steps);           
Ttmp(:,end) = example.T0;                                     
Itmp = zeros(example.n, fea_steps);           
Itmp(:,end) = example.I0;                                     
Btmp = zeros(example.n, fea_steps);          
Btmp(:,end) = example.B0;    
pi_actions_tmp = zeros(example.n, fea_steps); 


% Test
for i = 1:num_stages_trajectory
    if i <= num_stages_trajectory-num_stages_training+1
        valgo_tmp = valgo{1};
    else
        idx = mod(i,num_stages_training);
        if idx == 0
            idx = num_stages_training;
        end
        valgo_tmp = valgo{idx};
    end
    size_of_action_space_tmp = valgo_tmp.size_of_action_space;

    X = set_drug_qtrajectory_test_data(Ntmp, Ttmp, Itmp, Btmp, pi_actions_tmp, ...
                                       size_of_action_space_tmp, fea_mode, action_mode);

    pi_actions(:, i) = distributed_qfunction_testing(valgo_tmp, X, Nr);
    A(:,i) = pi_actions(:, i) - 1;

    ee = 1 - exp(-B(:,i));
    N(:,i+1) = N(:,i) + deltaT * (r(2)*N(:,i).*(1-b(2)*N(:,i)) - c(4)*T(:,i).*N(:,i) - a(3)*ee.*N(:,i));
    T(:,i+1) = T(:,i) + deltaT * (r(1)*T(:,i).*(1-b(1)*T(:,i)) - c(2)*I(:,i).*T(:,i) - c(3)*T(:,i).*N(:,i) - a(2)*ee.*T(:,i));
    I(:,i+1) = I(:,i) + deltaT * (s + (rho*I(:,i).*T(:,i))./(alpha+T(:,i)) - c(1)*I(:,i).*T(:,i) - d(1)*I(:,i) - a(1)*ee.*I(:,i));
    B(:,i+1) = B(:,i) + deltaT * (-d(2)*B(:,i) + A(:,i));
    R(:,i) = (N(:,i) + I(:,i) - T(:,i) - A(:,i)).*deltaT;

    Ntmp(:,1:end-1) = Ntmp(:,2:end);
    Ntmp(:,end) = N(:,i+1);
    Ttmp(:,1:end-1) = Ttmp(:,2:end);
    Ttmp(:,end) = T(:,i+1);
    Itmp(:,1:end-1) = Itmp(:,2:end);
    Itmp(:,end) = I(:,i+1);
    Btmp(:,1:end-1) = Btmp(:,2:end);
    Btmp(:,end) = B(:,i+1);

    pi_actions_tmp(:,end) = pi_actions(:,i);
    pi_actions_tmp(:,1:end-1) = pi_actions_tmp(:,2:end);
    pi_actions_tmp(:,end) = zeros(example.n, 1);

end
SumR = cumsum(R, 2);
SumR_mean = mean(SumR, 1);
N_mean = mean(N, 1);
T_mean = mean(T, 1);
I_mean = mean(I, 1);
B_mean = mean(B, 1);
R_mean = mean(R, 1); 

