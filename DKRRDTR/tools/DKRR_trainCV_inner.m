function [e, t, MachineCV] = DKRR_trainCV_inner(MachineCV, lambda_seq, KerPara)
m = length(MachineCV);
L = length(lambda_seq);

%% Step 1: local process
t_Step1 = zeros(m,1);
A = cell(1, m);

for k = 1:m
    tic;
    [A{k}, MachineCV{k}.K_DjDj] = KRR_train_inner(MachineCV{k}.train_x, MachineCV{k}.train_y, lambda_seq, KerPara);           
    t_tmp = toc;
    t_Step1(k) = t_tmp;
end

%% Step 2 Estimate on test data
e = zeros(m, L);
t_Step2 = zeros(m,1);
for k = 1:m
    tic;
    MachineCV{k}.K_DtDj = KernelComputation(MachineCV{k}.test_x, MachineCV{k}.train_x, KerPara);
    F_hat_j = MachineCV{k}.K_DtDj * A{k};
    e_tmp = mean((repmat(MachineCV{k}.test_y, 1, L) - F_hat_j).^2, 1);
    t_tmp = toc;
    t_Step2(k) = t_tmp;
    e(k, :) = e_tmp;
end

t.t_Step1 = t_Step1;
t.t_Step2 = t_Step2;

