function [Machine, t_local] = DKRR_train_inner(Machine, para_opt, KerPara)

m = length(Machine);

t_local = zeros(m,1);

if KerPara.KernelType == 4
    for k = 1:m
        tic;
        KerPara.para = para_opt(1, k);
        lambda_tmp = para_opt(2, k);
        Machine{k}.alpha_j = KRR_train_inner(Machine{k}.train_x, Machine{k}.train_y, lambda_tmp, KerPara);     
        t_tmp = toc;
        t_local(k) = t_tmp;
    end
    
else
    for k = 1:m
        tic;
        lambda_tmp = para_opt(k);
        Machine{k}.alpha_j = KRR_train_inner(Machine{k}.train_x, Machine{k}.train_y, lambda_tmp, KerPara);     
        t_tmp = toc;
        t_local(k) = t_tmp;
    end
end


