function results = cancer_example_dynamics_all(e_test, num_stages)

action_space = e_test.action_space;
size_of_action_space = length(action_space);

W = cell(num_stages+1,1);                     % Wellness
M = cell(num_stages+1,1);                     % Tumor size
R = cell(num_stages,1);                       % time to go to next stage
AtRisk = cell(num_stages+1,1);
Death = cell(num_stages+1,1);
Cured = cell(num_stages+1,1);

if e_test.seed > 0
    rng(e_test.seed)
end

% Initialize the wellness and tumor size
W0 = e_test.IW(1) + (e_test.IW(2)-e_test.IW(1)).*rand(e_test.n,1);  % the initial wellness are drawn uniformly from
                                                                      % the segment [e_test.IW(1), e_test.IW(2)].
M0 = e_test.IM(1) + (e_test.IM(2)-e_test.IM(1)).*rand(e_test.n,1);  % the initial tumor sizes are drawn uniformly from
                                                                      % the segment [e_test.IM(1), e_test.IM(2)].
W{1} = W0;
M{1} = M0;                                                                    
AtRisk{1} = true(e_test.n,1);                                         % at risk at time zero
Death{1} = false(e_test.n,1); 
Cured{1} = false(e_test.n,1); 

% Test
for i = 1:num_stages
    Wi = W{i};
    Mi = M{i};
    AtRiski = AtRisk{i};
    Deathi = Death{i};
    Curedi = Cured{i};
    Ri = zeros(e_test.n, size_of_action_space^i);
    Wiplus1 = zeros(e_test.n, size_of_action_space^i);
    Miplus1 = zeros(e_test.n, size_of_action_space^i);
    AtRiskiplus1 = false(e_test.n, size_of_action_space^i);
    Deathiplus1 = false(e_test.n, size_of_action_space^i);
    Curediplus1 = false(e_test.n, size_of_action_space^i);
    for k = 1:size_of_action_space
        indtmp = k:size_of_action_space:size_of_action_space^i;
        [Wiplus1tmp, Miplus1tmp, Ritmp, AtRiskiplus1tmp, Deathiplus1tmp, Curediplus1tmp] = ...
            cancer_status_computation_mat(Wi, W0, Mi, M0, e_test, action_space(k), AtRiski, Deathi, Curedi);
        Wiplus1(:,indtmp) = Wiplus1tmp;
        Miplus1(:,indtmp) = Miplus1tmp;
        AtRiskiplus1(:,indtmp) = AtRiskiplus1tmp;
        Deathiplus1(:,indtmp) = Deathiplus1tmp;
        Curediplus1(:,indtmp) = Curediplus1tmp;
        Ri(:,indtmp) = Ritmp;
    end 
    W{i+1} = Wiplus1;
    M{i+1} = Miplus1;
    AtRisk{i+1} = AtRiskiplus1;
    Death{i+1} = Deathiplus1;
    Cured{i+1} = Curediplus1;
    R{i} = Ri;
end

W_final_stage_all_combination_mean = mean(W{num_stages+1}, 1);
M_final_stage_all_combination_mean = mean(M{num_stages+1}, 1);
R_final_stage_all_combination_mean = mean(R{num_stages}, 1);
WM_final_stage_all_combination_mean = W_final_stage_all_combination_mean+M_final_stage_all_combination_mean;

Death_final_stage_all_combination_mean = mean(Death{num_stages+1}, 1);
Cured_final_stage_all_combination_mean = mean(Cured{num_stages+1}, 1);
AtRisk_final_stage_all_combination_mean = mean(AtRisk{num_stages+1}, 1);
Survival_final_stage_all_combination = Cured{num_stages+1} | AtRisk{num_stages+1};
CSP_final_stage_all_combination = mean(Survival_final_stage_all_combination, 1);

% fixed dose levels ranging from 0.1 to 1.0 with increments of size 0.1
ind_fixed_dose = zeros(1, size_of_action_space);
for i = 1:size_of_action_space
    n_ind = 0;
    for j = 1:num_stages-1
        n_ind = n_ind + (i-1)*size_of_action_space^(num_stages-j);
    end
    n_ind = n_ind + i;
    ind_fixed_dose(i) = n_ind;
end

W_final_stage_fix_doge_mean = W_final_stage_all_combination_mean(:,ind_fixed_dose);
M_final_stage_fix_doge_mean = M_final_stage_all_combination_mean(:,ind_fixed_dose);
R_final_stage_fix_doge_mean = R_final_stage_all_combination_mean(:,ind_fixed_dose);
WM_final_stage_fix_doge_mean = WM_final_stage_all_combination_mean(:,ind_fixed_dose);

Death_final_stage_fix_doge_mean = Death_final_stage_all_combination_mean(:,ind_fixed_dose);
Cured_final_stage_fix_doge_mean = Cured_final_stage_all_combination_mean(:,ind_fixed_dose);
AtRisk_final_stage_fix_doge_mean = AtRisk_final_stage_all_combination_mean(:,ind_fixed_dose);
Survival_final_stage_fix_doge_mean = Survival_final_stage_all_combination(:,ind_fixed_dose);
CSP_final_stage_fix_doge = CSP_final_stage_all_combination(:,ind_fixed_dose);

results.W_final_stage_all_combination_mean = W_final_stage_all_combination_mean;
results.M_final_stage_all_combination_mean = M_final_stage_all_combination_mean;
results.R_final_stage_all_combination_mean = R_final_stage_all_combination_mean;
results.WM_final_stage_all_combination_mean = WM_final_stage_all_combination_mean;
results.Death_final_stage_all_combination_mean = Death_final_stage_all_combination_mean;
results.Cured_final_stage_all_combination_mean = Cured_final_stage_all_combination_mean;
results.AtRisk_final_stage_all_combination_mean = AtRisk_final_stage_all_combination_mean;
results.Survival_final_stage_all_combination = Survival_final_stage_all_combination;
results.CSP_final_stage_all_combination = CSP_final_stage_all_combination;

results.W_final_stage_fix_doge_mean = W_final_stage_fix_doge_mean;
results.M_final_stage_fix_doge_mean = M_final_stage_fix_doge_mean;
results.R_final_stage_fix_doge_mean = R_final_stage_fix_doge_mean;
results.WM_final_stage_fix_doge_mean = WM_final_stage_fix_doge_mean;
results.Death_final_stage_fix_doge_mean = Death_final_stage_fix_doge_mean;
results.Cured_final_stage_fix_doge_mean = Cured_final_stage_fix_doge_mean;
results.AtRisk_final_stage_fix_doge_mean = AtRisk_final_stage_fix_doge_mean;
results.Survival_final_stage_fix_doge_mean = Survival_final_stage_fix_doge_mean;
results.CSP_final_stage_fix_doge = CSP_final_stage_fix_doge;

results.CSP_optimal = mean(max(Survival_final_stage_all_combination,[],2));




