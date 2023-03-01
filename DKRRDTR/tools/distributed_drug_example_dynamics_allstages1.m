function [SumR_mean, N_mean, T_mean, I_mean, B_mean, R_mean] ...
            = distributed_drug_example_dynamics_allstages1(vf, example, opt)
valgo = vf.qfunctions;
Nr = vf.info_split.Nr;

if nargin < 2
    fea_mode = 'markov';
    action_mode = 'mix';
else
    fea_mode = opt.fea_mode;
    action_mode = opt.action_mode;
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


Ntmp = zeros(example.n, num_stages_training);        
Ntmp(:,1) = example.N0;                                    
Ttmp = zeros(example.n, num_stages_training);           
Ttmp(:,1) = example.T0;                                     
Itmp = zeros(example.n, num_stages_training);           
Itmp(:,1) = example.I0;                                     
Btmp = zeros(example.n, num_stages_training);          
Btmp(:,1) = example.B0;    
pi_actions_tmp = zeros(example.n, num_stages_training); 
valgo_tmp = valgo{1};
algo_idx = 0;

% Test
for i = 1:num_stages_trajectory
    size_of_action_space_tmp = valgo_tmp.size_of_action_space;
    X = set_drug_qtrajectory_test_data(Ntmp, Ttmp, Itmp, Btmp, pi_actions_tmp, algo_idx+1, ...
                                       size_of_action_space_tmp, fea_mode, action_mode);

    pi_actions(:, i) = distributed_qfunction_testing(valgo_tmp, X, Nr);
    A(:,i) = pi_actions(:, i) - 1;

    ee = 1 - exp(-B(:,i));
    N(:,i+1) = N(:,i) + deltaT * (r(2)*N(:,i).*(1-b(2)*N(:,i)) - c(4)*T(:,i).*N(:,i) - a(3)*ee.*N(:,i));
    T(:,i+1) = T(:,i) + deltaT * (r(1)*T(:,i).*(1-b(1)*T(:,i)) - c(2)*I(:,i).*T(:,i) - c(3)*T(:,i).*N(:,i) - a(2)*ee.*T(:,i));
    I(:,i+1) = I(:,i) + deltaT * (s + (rho*I(:,i).*T(:,i))./(alpha+T(:,i)) - c(1)*I(:,i).*T(:,i) - d(1)*I(:,i) - a(1)*ee.*I(:,i));
    B(:,i+1) = B(:,i) + deltaT * (-d(2)*B(:,i) + A(:,i));
    R(:,i) = (N(:,i) + I(:,i) - T(:,i) - A(:,i)).*deltaT;


    algo_idx = mod(i, num_stages_training);
    if algo_idx == 0
        Ntmp = zeros(example.n, num_stages_training); 
        Ttmp = zeros(example.n, num_stages_training);                                                
        Itmp = zeros(example.n, num_stages_training);                                                
        Btmp = zeros(example.n, num_stages_training);          
        pi_actions_tmp = zeros(example.n, num_stages_training); 
    else
        pi_actions_tmp(:,algo_idx) = pi_actions(:, i);
    end        
    Ntmp(:,algo_idx+1) = N(:,i+1);
    Ttmp(:,algo_idx+1) = T(:,i+1); 
    Itmp(:,algo_idx+1) = I(:,i+1); 
    Btmp(:,algo_idx+1) = B(:,i+1); 
    
    valgo_tmp = valgo{algo_idx+1};
    

%     if mod(i, num_stages_training) == 0
%         algo_idx = num_stages_training;
%         Ntmp = zeros(example.n, num_stages_training); 
%         Ntmp(:,1) = N(:,i+1);
%         Ttmp = zeros(example.n, num_stages_training);           
%         Ttmp(:,1) = T(:,i+1);                                     
%         Itmp = zeros(example.n, num_stages_training);           
%         Itmp(:,1) = I(:,i+1);                                     
%         Btmp = zeros(example.n, num_stages_training);          
%         Btmp(:,1) = B(:,i+1); 
%         pi_actions_tmp = zeros(example.n, num_stages_training); 
%         size_of_action_space = valgo{1}.size_of_action_space;
%     else
%         algo_idx = mod(i, num_stages_training);
%         Ntmp(:,algo_idx+1) = N(:,i+1);
%         Ttmp(:,algo_idx+1) = T(:,i+1); 
%         Itmp(:,algo_idx+1) = I(:,i+1); 
%         Btmp(:,algo_idx+1) = B(:,i+1); 
%         pi_actions_tmp(:,algo_idx) = pi_actions(:, i);
%         size_of_action_space = valgo{algo_idx+1}.size_of_action_space;
%     end
end
SumR = cumsum(R, 2);
SumR_mean = mean(SumR, 1);
N_mean = mean(N, 1);
T_mean = mean(T, 1);
I_mean = mean(I, 1);
B_mean = mean(B, 1);
R_mean = mean(R, 1); 

