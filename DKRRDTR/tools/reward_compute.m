function R = reward_compute(W, M, AtRisk, Death, Cured, a)
death_r = a.death_r;
cure_r = a.cure_r;
other_r = a.other_r;

W_t = W(:,1);
W_tplus1 = W(:,2);
M_t = M(:,1);
M_tplus1 = M(:,2);

ind_death = Death;
ind_undeath = AtRisk | Cured;

R1 = zeros(size(AtRisk));
R1(ind_death,:) = death_r;

R2 = zeros(size(AtRisk));
R2_tmp = R2(ind_undeath,1);
W_t_undeath = W_t(ind_undeath);
W_tplus1_undeath = W_tplus1(ind_undeath);
R2_ind1 = (W_tplus1_undeath - W_t_undeath) <= -a.c0;
R2_ind2 = (W_tplus1_undeath - W_t_undeath) >= a.c0;
R2_tmp(R2_ind1) = other_r;
R2_tmp(R2_ind2) = -other_r;
R2(ind_undeath) = R2_tmp;

R3 = zeros(size(AtRisk));
R3_tmp = R3(ind_undeath,1);
M_t_undeath = M_t(ind_undeath);
M_tplus1_undeath = M_tplus1(ind_undeath);
R3_ind1 = M_tplus1_undeath == 0;
R3_ind2 = (M_tplus1_undeath - M_t_undeath) <= -a.c0 & M_tplus1_undeath > 0;
R3_ind3 = (M_tplus1_undeath - M_t_undeath) >= a.c0;
R3_tmp(R3_ind1) = cure_r;
R3_tmp(R3_ind2) = other_r;
R3_tmp(R3_ind3) = -other_r;
R3(ind_undeath) = R3_tmp;

R = R1 + R2 + R3;

