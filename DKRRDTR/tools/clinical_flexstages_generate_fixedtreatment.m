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

function [U, sumUi] =  clinical_flexstages_generate_fixedtreatment(a, opt)

if( a.seed>0)
    rng(a.seed)
end

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
R = zeros(a.n,num_stages);                     % R(:,i) is the  length of the i-th stage by the dynamic
Wa = zeros(a.n,num_stages);                    % Wa(:,i) is the wellness after the i-th action;
Ma = zeros(a.n,num_stages);                    % Ma(:,i) is the tumor size after the i-th action;

% ----------------------------------------------------------------------------------------------
% AtRisk(j,i) indicates whether the j-th trajectory ends or not at the i-th theoretical stage  
% AtRisk(:,i) = 1 indicates that the patient steps in stage i
% AtRisk(:,i) = 1 and AtRisk(:,i+1) = 0 mean that the patient fails or the trial ends at stage i
AtRisk = [ones(a.n,1),zeros(a.n,num_stages)];  % AtRisk(:,i) is one if the patiant is at risk at the begining of stage i


A = opt.A;                 % actions: action matrix with size a.n X 3, and each row includes 
                                               % the action numbers of the three stages for each person
mu = zeros(a.n,num_stages);                    % mu(:,i) is the failure time expectation of the i-th stage
T = zeros(a.n,num_stages);                     % T(:,i) is the failure time
U = zeros(a.n,num_stages);                     % U(:,i)=min (T,R,a.max-sumT(i-1)) is the actual time in stage i;
sumUi = zeros(a.n,num_stages);                 % sumUi time up to and include stage i.

for i = 1:num_stages
    Wa(:,i) = (W(:,i)-a.actions(1,1)).*(A(:,i)==1) + ...     % if treatment A, W(u_i^+|A) = W(u_i) - 0.5
              (W(:,i)-a.actions(2,1)).*(A(:,i)==2);          % if treatment B, W(u_i^+|B) = W(u_i) - 0.25
    Wa(:,i) = max(Wa(:,i), 0);
    
    Ma(:,i) = (a.actions(1,2)./W(:,i)).*(A(:,i)==1) + ...    % if treatment A, T(u_i^+|A) = T(u_i) * 0.1 / W(u_i), where T(u_i)=1
              (a.actions(2,2)./W(:,i)).*(A(:,i)==2);         % if treatment B, T(u_i^+|B) = T(u_i) * 0.2 / W(u_i), where T(u_i)=1
    Ma(:,i) = min(Ma(:,i), 1);

    R(:,i) = (1/a.Mdot)*(1-Ma(:,i))./Ma(:,i);                % Let T(u) = T(u_i^+) + 4*T(u_i^+)(u-u_i)/3 = 1 
                                                             %      ==> u-u_i = (1-T(u_i^+)) * (3/4) / T(u_i^+)
                                                             % since the value u-u_i obtained from equation T(u)=1
    R(AtRisk(:,i)==0,i) = 0;
    mu(:,i) = a.c0*(Wa(:,i)+a.c1)./Ma(:,i);                  % Model the survival function of the patient as an exponential 
                                                             % distribution with mean (3/20) * (W(u_i^+)+2) / T(u_i^+)


    mu(Wa(:,i)<a.failure,i) = 0;                             % W(u_i^+)<0.25 represents a failure, and the patient is dead?

    T(:,i) = exprnd(mu(:,i));                                % generate random numbers with an exponential distribution
    % we need to truncate at a.max and to consider only those at risk
    % we check if this observation was censored
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
    M(AtRisk(:,i)==0, i+1) = 0;
end

