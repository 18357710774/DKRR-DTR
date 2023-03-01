function [paraOpt, cv_error_mean_opt] = KRR_CV(train_x, train_y, lambda_seq, KerPara, nfolds)
% This function performs CV for the kernel ridge regression. 
if nargin < 5
    nfolds = 5;
end
nn = length(train_y);
cvo = cvpartition(nn,'k',nfolds);
if KerPara.KernelType == 4
    SigmaCross = KerPara.paraCross;
    cv_error = zeros(nfolds,length(SigmaCross)*length(lambda_seq));
    para = zeros(2,length(SigmaCross)*length(lambda_seq));
    kk = 0;
    for Sigma = SigmaCross
        kk = kk+1;
        indtmp = (kk-1)*length(lambda_seq)+1:kk*length(lambda_seq);
        KerPara.para = Sigma;
        para(:,indtmp) = [Sigma*ones(1,length(lambda_seq));lambda_seq];
        for cv = 1:cvo.NumTestSets
            train_ID = cvo.training(cv);
            test_ID = cvo.test(cv);
            trainCV_x = train_x(train_ID,:);
            trainCV_y = train_y(train_ID,:);
            testCV_x = train_x(test_ID,:);
            testCV_y = train_y(test_ID,:);                     
            cv_error(cv,indtmp) = KRR(trainCV_x, trainCV_y, testCV_x, testCV_y, lambda_seq, KerPara);         
        end               
    end
    cv_error_mean = mean(cv_error,1);
    [~, indmin] = min(cv_error_mean);
    paraOpt = para(:,indmin);
else
    cv_error = zeros(nfolds, length(lambda_seq));
    for cv = 1:cvo.NumTestSets
        train_ID = cvo.training(cv);
        test_ID = cvo.test(cv);
        trainCV_x = train_x(train_ID,:);
        trainCV_y = train_y(train_ID,:);
        testCV_x = train_x(test_ID,:);
        testCV_y = train_y(test_ID,:);
        cv_error(cv,:) = KRR(trainCV_x, trainCV_y, testCV_x, testCV_y, lambda_seq, KerPara);          
    end               
    cv_error_mean = mean(cv_error,1);
    [cv_error_mean_opt, indmin] = min(cv_error_mean);
    paraOpt = lambda_seq(:,indmin);
end


