function [CSP_mean, CSP_mean_allstages, Wfinal_mean, Mfinal_mean, Rfinal_mean, Curedfinal_mean, ...
    AtRiskfinal_mean, Deathfinal_mean, results] = cancer_example_dynamics_fixpolicy(e_test, num_stages)

action_space = e_test.action_space;
size_of_action_space = length(action_space);

if e_test.seed > 0
    rng(e_test.seed)
end

% Initialize the wellness and tumor size
W0 = e_test.IW(1) + (e_test.IW(2)-e_test.IW(1)).*rand(e_test.n,1);    % the initial wellness are drawn uniformly from
                                                                      % the segment [e_test.IW(1), e_test.IW(2)].
M0 = e_test.IM(1) + (e_test.IM(2)-e_test.IM(1)).*rand(e_test.n,1);    % the initial tumor sizes are drawn uniformly from
                                                                      % the segment [e_test.IM(1), e_test.IM(2)].
W = zeros(e_test.n, num_stages+1, size_of_action_space);
M = zeros(e_test.n, num_stages+1, size_of_action_space);
R = zeros(e_test.n, num_stages, size_of_action_space);
AtRisk = false(e_test.n, num_stages+1, size_of_action_space);
Death = false(e_test.n, num_stages+1, size_of_action_space);
Cured = false(e_test.n, num_stages+1, size_of_action_space);

for k = 1:size_of_action_space
    actionk = action_space(k);
    Wk = zeros(e_test.n, num_stages+1);
    Wk(:,1) = W0;
    Mk = zeros(e_test.n, num_stages+1);
    Mk(:,1) = M0;
    Rk = zeros(e_test.n, num_stages);
    AtRiskk = false(e_test.n, num_stages+1);
    AtRiskk(:,1) = true(e_test.n, 1);
    Deathk = false(e_test.n, num_stages+1);
    Curedk = false(e_test.n, num_stages+1);

    for i = 1:num_stages
        [Wk(:,i+1), Mk(:,i+1), Rk(:,i), AtRiskk(:,i+1), Deathk(:,i+1), Curedk(:,i+1)] = ...
            cancer_status_computation(Wk(:,i), W0, Mk(:,i), M0, e_test, actionk, AtRiskk(:,i), Deathk(:,i), Curedk(:,i));
    end 
    W(:, :, k) = Wk;
    M(:, :, k) = Mk;
    R(:, :, k) = Rk;
    AtRisk(:, :, k) = AtRiskk;
    Death(:, :, k) = Deathk;
    Cured(:, :, k) = Curedk;
    clear Wk Mk Rk AtRiskk Deathk Curedk;
end

Survival = Cured | AtRisk;                                            % the survival patients include cured and uncured patients (i.e., not dead)  

Wfinal = squeeze(W(:,end,:));
Mfinal = squeeze(M(:,end,:));
Rfinal = squeeze(R(:,end,:));
AtRiskfinal = squeeze(AtRisk(:,end,:));
Deathfinal = squeeze(Death(:,end,:));
Curedfinal = squeeze(Cured(:,end,:));
Survivalfinal = squeeze(Survival(:,end,:));

results.W = W;
results.M = M;
results.R = R;
results.AtRisk = AtRisk;
results.Death = Death;
results.Cured = Cured;
results.Survival = Survival;

results.Wfinal = Wfinal;
results.Mfinal = Mfinal;
results.Rfinal = Rfinal;
results.AtRiskfinal = AtRiskfinal;
results.Deathfinal = Deathfinal;
results.Curedfinal = Curedfinal;
results.Survivalfinal = Survivalfinal;

Wfinal_mean = mean(Wfinal,1);
Mfinal_mean = mean(Mfinal,1);
Rfinal_mean = mean(Rfinal,1);
AtRiskfinal_mean = mean(AtRiskfinal,1);
Deathfinal_mean = mean(Deathfinal,1);
Curedfinal_mean = mean(Curedfinal,1);
CSP_mean = mean(Survivalfinal,1);
CSP_mean_allstages = squeeze(mean(Survival, 1));

