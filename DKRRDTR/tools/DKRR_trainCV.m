function [para_opt, t_cv, e_cv, Machine] = DKRR_trainCV(Machine, lambda_seq, KerPara, nfolds)
m = length(Machine);
L = length(lambda_seq);
for k = 1:m
    nn = length(Machine{k}.train_y);
    Machine{k}.cvo = cvpartition(nn,'k',nfolds); 
end


if KerPara.KernelType == 4
    SigmaCross = KerPara.paraCross;
    e_cv = zeros(m, length(SigmaCross)*L, nfolds);  
    t_cv = cell(length(SigmaCross), nfolds);
      
    para = zeros(2,length(SigmaCross)*length(lambda_seq));
    kk = 0;
    for Sigma = SigmaCross
        kk = kk+1;        
        indtmp = (kk-1)*length(lambda_seq)+1:kk*length(lambda_seq);       
        KerPara.para = Sigma;
        para(:,indtmp) = [Sigma*ones(1,length(lambda_seq));lambda_seq];    
        for cv = 1:nfolds % 1:cvo.NumTestSets
            MachineCV = cell(1,m);
            for k = 1:m
                cvo = Machine{k}.cvo;
                train_ID = cvo.training(cv);
                test_ID = cvo.test(cv);
                MachineCV{k}.train_x = Machine{k}.train_x(train_ID,:);
                MachineCV{k}.train_y = Machine{k}.train_y(train_ID,:);
                MachineCV{k}.test_x = Machine{k}.train_x(test_ID,:);
                MachineCV{k}.test_y = Machine{k}.train_y(test_ID,:);
            end
            [e_cvtmp, t_cv{kk, cv}] = DKRR_trainCV_inner(MachineCV, lambda_seq, KerPara);  
            e_cv(:,indtmp,cv) = e_cvtmp;  % e_cv is a tensor with size (local machine no. X para no. X cv_folds)
        end               
    end
else
    t_cv = cell(1, nfolds);
    e_cv = zeros(m, L, nfolds);
    for cv = 1:nfolds % 1:cvo.NumTestSets
        MachineCV = cell(1,m);
        for k = 1:m
            cvo = Machine{k}.cvo;
            train_ID = cvo.training(cv);
            test_ID = cvo.test(cv);
            MachineCV{k}.train_x = Machine{k}.train_x(train_ID,:);
            MachineCV{k}.train_y = Machine{k}.train_y(train_ID,:);
            MachineCV{k}.test_x = Machine{k}.train_x(test_ID,:);
            MachineCV{k}.test_y = Machine{k}.train_y(test_ID,:);
        end
        % the size of e is mXL, and each row is the test error of one local machine for L values of lambda
        [e_cv(:,:,cv), t_cv{cv}] = DKRR_trainCV_inner(MachineCV, lambda_seq, KerPara);
    end
    para = lambda_seq;
end
e_cv_mean = mean(e_cv, 3);


% The i-th element of lambda_opt is the optimal parameter pair for the i-th local machine via cv 
[~, ind_para_opt] = min(e_cv_mean, [], 2);
para_opt = para(:, ind_para_opt);


