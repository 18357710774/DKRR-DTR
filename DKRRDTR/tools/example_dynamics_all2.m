function [TotalTime,NumActions,InitialWellness]=example_dynamics_all2(e_test, num_stages)

W=cell(4,1);% Wellness
M=cell(4,1);% Tumor size
W_action=cell(3,1);% Wellness after action
M_action=cell(3,1);% Tumor after action
mu=cell(3,1);% expectation as a result of action
T=cell(3,1);% actual failure time
R=cell(3,1); % time to go to next stage
U=cell(3,1);%  minimum between failure, time to move to next stage and end of trial
AtRisk=cell(4,1);%

if e_test.seed > 0
    rng(e_test.seed)
end

%Initialize the wellness and tumor size
W{1}=e_test.IW(1) + (e_test.IW(2)-e_test.IW(1)).*rand(e_test.n,1);
M{1}=ones(e_test.n,1);%tumor size
AtRisk{1}=ones(e_test.n,2);%at risk at time zero
%TEST




for(i=1:num_stages)
    Wi=W{i};
    Mi=M{i};
    
    
    % assign the different action imidiate results
    for(j=1:2^(i-1))% j=1,2,4
        W_action{i}=[W_action{i},Wi(:,j)-e_test.actions(1,1),Wi(:,j)-e_test.actions(2,1)];
        M_action{i}=[M_action{i},e_test.actions(1,2)./Wi(:,j),e_test.actions(2,2)./Wi(:,j)];
    end
    
    R{i}=(1/e_test.Mdot)*(1-M_action{i})./M_action{i};
    
    W{i+1}=W_action{i}+(1-W_action{i}).*(1-2.^(-e_test.Wdot*R{i}));
    M{i+1}=M_action{i}+e_test.Mdot*M_action{i}.*R{i};
    
    
    mu_i=e_test.c0*(W_action{i}+e_test.c1)./M_action{i};
    mu_i(W_action{i}<e_test.failure)=0;
    mu{i}=mu_i;
    
    T{i}=exprnd(mu{i});
    
    switch i %we need to truncate at e_test.max and to consider only those at risk
        case 1
            
            T{i}=min(T{i},e_test.max);
        case 2 %CHECK!!!!!!
            
            T{i}=min(T{i},e_test.max-expend_matrix(U{1}));
        case 3
            T{i}=min(T{i},e_test.max-expend_matrix(U{1},4)-expend_matrix(U{2}));
    end
    
    
    
    T{i}(AtRisk{i}==0)=0;
    
    U{i}=min(T{i},R{i});
    AtRisk{i+1}=T{i}>R{i};
    AtRisk{i+1}=expend_matrix(AtRisk{i+1},2);
end


% We compute the total time. Total time is an 8 columns matrix
% We check what was the best time for each line
% and what was the time for pi_hat
U{1}=expend_matrix(U{1},4);
U{2}=expend_matrix(U{2},2);

TotalTime=U{1}+U{2}+U{3};

AtRisk{1}=expend_matrix(AtRisk{1},4);
AtRisk{2}=expend_matrix(AtRisk{2},2);

NumActions=AtRisk{1}+AtRisk{2}+AtRisk{3};

InitialWellness=W{1};