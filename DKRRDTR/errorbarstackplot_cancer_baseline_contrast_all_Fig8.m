clear; clc;
addpath(genpath('brewermap'));
addpath(genpath('cbrewer'));

path = [cd '\SynResults\'];

%% ------------------------ CSP, Cured and W+M Results  --------------------------------
% load the results of the ten fixed treatment
load([path 'cancer_fixstages_fixpolicy_ExNum100.mat'], ...
     'CSP_mean', 'Curedfinal_mean', 'AtRiskfinal_mean', 'Mfinal_mean', 'Wfinal_mean');
CSP_mean_fixedpolicy = mean(CSP_mean, 1);
CSP_std_fixedpolicy = std(CSP_mean, [], 1);
WM_mean_fixedpolicy = mean(Mfinal_mean+Wfinal_mean, 1);
WM_std_fixedpolicy = std(Mfinal_mean+Wfinal_mean, [], 1);
Cured_mean_fixedpolicy = mean(Curedfinal_mean, 1);
Cured_std_fixedpolicy = std(Curedfinal_mean, [], 1);
AtRisk_mean_fixedpolicy = mean(AtRiskfinal_mean, 1);
AtRisk_std_fixedpolicy = std(AtRiskfinal_mean, [], 1);
CuredAtRisk_mean_fixedpolicy = cat(2, Cured_mean_fixedpolicy', AtRisk_mean_fixedpolicy');

clear CSP_mean Curedfinal_mean AtRiskfinal_mean Mfinal_mean Wfinal_mean;

%% plot the results of the three compared methods
fea_mode = {'markov', 'markovnon'};
m_CSP_mean = zeros(2,3);
m_CSP_std = zeros(2,3);
m_CSP_all_mean = zeros(2,3,7); 
m_CSP_all_std = zeros(2,3,7);
m_WM_mean = zeros(2,3);
m_WM_std = zeros(2,3);
m_WM_all_mean = zeros(2,3,7);  
m_WM_all_std = zeros(2,3,7);
m_Cured_mean = zeros(2,3);
m_Cured_std = zeros(2,3);
m_Cured_all_mean = zeros(2,3,7);  
m_CCured_all_std = zeros(2,3,7);
m_AtRisk_mean = zeros(2,3);
m_AtRisk_std = zeros(2,3);
m_AtRisk_all_mean = zeros(2,3,7);  
m_AtRisk_all_std = zeros(2,3,7);
train_time_mean = zeros(2,3);
train_time_std = zeros(2,3);
test_time_mean = zeros(2,3);
test_time_std = zeros(2,3);

% load the results of ls
load([path 'cancer_fixstagesNtr20000_ls_markov_baseline.mat'], ...
      'CSP_mean', 'Cured_mean', 'WM_mean', 'AtRisk_mean',...
      'train_time_results', 'test_time_results');
m_CSP_all_mean(1,1,:) = mean(CSP_mean);
m_CSP_all_std(1,1,:) = std(CSP_mean,[],1);
m_CSP_mean(1,1) = m_CSP_all_mean(1,1,end);
m_CSP_std(1,1) = m_CSP_all_std(1,1,end);
m_WM_all_mean(1,1,:) = mean(WM_mean);
m_WM_all_std(1,1,:) = std(WM_mean,[],1);
m_WM_mean(1,1) = m_WM_all_mean(1,1,end);
m_WM_std(1,1) = m_WM_all_std(1,1,end);
m_Cured_all_mean(1,1,:) = mean(Cured_mean);
m_Cured_all_std(1,1,:) = std(Cured_mean,[],1);
m_Cured_mean(1,1) = m_Cured_all_mean(1,1,end);
m_Cured_std(1,1) = m_Cured_all_std(1,1,end);
m_AtRisk_all_mean(1,1,:) = mean(AtRisk_mean);
m_AtRisk_all_std(1,1,:) = std(AtRisk_mean,[],1);
m_AtRisk_mean(1,1) = m_AtRisk_all_mean(1,1,end);
m_AtRisk_std(1,1) = m_AtRisk_all_std(1,1,end);
train_time_mean(1,1) = train_time_results.time_total_mean;
train_time_std(1,1) = train_time_results.time_total_std;
test_time_mean(1,1) = test_time_results.time_total_mean;
test_time_std(1,1) = test_time_results.time_total_std;
clear CSP_mean Cured_mean AtRisk_mean WM_mean train_time_results test_time_results;

load([path 'cancer_fixstagesNtr20000_ls_markovnon_baseline.mat'], ...
      'CSP_mean', 'Cured_mean', 'WM_mean', 'AtRisk_mean',...
      'train_time_results', 'test_time_results');
m_CSP_all_mean(2,1,:) = mean(CSP_mean);
m_CSP_all_std(2,1,:) = std(CSP_mean,[],1);
m_CSP_mean(2,1) = m_CSP_all_mean(2,1,end);
m_CSP_std(2,1) = m_CSP_all_std(2,1,end);
m_WM_all_mean(2,1,:) = mean(WM_mean);
m_WM_all_std(2,1,:) = std(WM_mean,[],1);
m_WM_mean(2,1) = m_WM_all_mean(2,1,end);
m_WM_std(2,1) = m_WM_all_std(2,1,end);
m_Cured_all_mean(2,1,:) = mean(Cured_mean);
m_Cured_all_std(2,1,:) = std(Cured_mean,[],1);
m_Cured_mean(2,1) = m_Cured_all_mean(2,1,end);
m_Cured_std(2,1) = m_Cured_all_std(2,1,end);
m_AtRisk_all_mean(2,1,:) = mean(AtRisk_mean);
m_AtRisk_all_std(2,1,:) = std(AtRisk_mean,[],1);
m_AtRisk_mean(2,1) = m_AtRisk_all_mean(2,1,end);
m_AtRisk_std(2,1) = m_AtRisk_all_std(2,1,end);
train_time_mean(2,1) = train_time_results.time_total_mean;
train_time_std(2,1) = train_time_results.time_total_std;
test_time_mean(2,1) = test_time_results.time_total_mean;
test_time_std(2,1) = test_time_results.time_total_std;
clear CSP_mean Cured_mean AtRisk_mean WM_mean train_time_results test_time_results;

% load the results of fcnet
load([path 'cancer_fixstagesNtr20000_fcnet_markov_baseline_ExNum20.mat'], ...
      'CSP_mean', 'Cured_mean', 'WM_mean', 'AtRisk_mean',...
      'train_time_results', 'test_time_results');
m_CSP_all_mean(1,2,:) = mean(CSP_mean);
m_CSP_all_std(1,2,:) = std(CSP_mean,[],1);
m_CSP_mean(1,2) = m_CSP_all_mean(1,2,end);
m_CSP_std(1,2) = m_CSP_all_std(1,2,end);
m_WM_all_mean(1,2,:) = mean(WM_mean);
m_WM_all_std(1,2,:) = std(WM_mean,[],1);
m_WM_mean(1,2) = m_WM_all_mean(1,2,end);
m_WM_std(1,2) = m_WM_all_std(1,2,end);
m_Cured_all_mean(1,2,:) = mean(Cured_mean);
m_Cured_all_std(1,2,:) = std(Cured_mean,[],1);
m_Cured_mean(1,2) = m_Cured_all_mean(1,2,end);
m_Cured_std(1,2) = m_Cured_all_std(1,2,end);
m_AtRisk_all_mean(1,2,:) = mean(AtRisk_mean);
m_AtRisk_all_std(1,2,:) = std(AtRisk_mean,[],1);
m_AtRisk_mean(1,2) = m_AtRisk_all_mean(1,2,end);
m_AtRisk_std(1,2) = m_AtRisk_all_std(1,2,end);
train_time_mean(1,2) = train_time_results.time_total_mean;
train_time_std(1,2) = train_time_results.time_total_std;
test_time_mean(1,2) = test_time_results.time_total_mean;
test_time_std(1,2) = test_time_results.time_total_std;
clear CSP_mean Cured_mean AtRisk_mean WM_mean train_time_results test_time_results;

load([path 'cancer_fixstagesNtr20000_fcnet_markovnon_baseline_ExNum20.mat'], ...
      'CSP_mean', 'Cured_mean', 'WM_mean', 'AtRisk_mean',...
      'train_time_results', 'test_time_results');
m_CSP_all_mean(2,2,:) = mean(CSP_mean);
m_CSP_all_std(2,2,:) = std(CSP_mean,[],1);
m_CSP_mean(2,2) = m_CSP_all_mean(2,2,end);
m_CSP_std(2,2) = m_CSP_all_std(2,2,end);
m_WM_all_mean(2,2,:) = mean(WM_mean);
m_WM_all_std(2,2,:) = std(WM_mean,[],1);
m_WM_mean(2,2) = m_WM_all_mean(2,2,end);
m_WM_std(2,2) = m_WM_all_std(2,2,end);
m_Cured_all_mean(2,2,:) = mean(Cured_mean);
m_Cured_all_std(2,2,:) = std(Cured_mean,[],1);
m_Cured_mean(2,2) = m_Cured_all_mean(2,2,end);
m_Cured_std(2,2) = m_Cured_all_std(2,2,end);
m_AtRisk_all_mean(2,2,:) = mean(AtRisk_mean);
m_AtRisk_all_std(2,2,:) = std(AtRisk_mean,[],1);
m_AtRisk_mean(2,2) = m_AtRisk_all_mean(2,2,end);
m_AtRisk_std(2,2) = m_AtRisk_all_std(2,2,end);
train_time_mean(2,2) = train_time_results.time_total_mean;
train_time_std(2,2) = train_time_results.time_total_std;
test_time_mean(2,2) = test_time_results.time_total_mean;
test_time_std(2,2) = test_time_results.time_total_std;
clear CSP_mean Cured_mean AtRisk_mean WM_mean train_time_results test_time_results;

% load the results of krr
load([path 'cancer_fixstagesNtr20000_krr_markov_baseline_optNtr10000.mat'], ...
      'CSP_mean', 'Cured_mean', 'WM_mean', 'AtRisk_mean',...
      'train_time_results', 'test_time_results');
m_CSP_all_mean(1,3,:) = mean(CSP_mean);
m_CSP_all_std(1,3,:) = std(CSP_mean,[],1);
m_CSP_mean(1,3) = m_CSP_all_mean(1,3,end);
m_CSP_std(1,3) = m_CSP_all_std(1,3,end);
m_WM_all_mean(1,3,:) = mean(WM_mean);
m_WM_all_std(1,3,:) = std(WM_mean,[],1);
m_WM_mean(1,3) = m_WM_all_mean(1,3,end);
m_WM_std(1,3) = m_WM_all_std(1,3,end);
m_Cured_all_mean(1,3,:) = mean(Cured_mean);
m_Cured_all_std(1,3,:) = std(Cured_mean,[],1);
m_Cured_mean(1,3) = m_Cured_all_mean(1,3,end);
m_Cured_std(1,3) = m_Cured_all_std(1,3,end);
m_AtRisk_all_mean(1,3,:) = mean(AtRisk_mean);
m_AtRisk_all_std(1,3,:) = std(AtRisk_mean,[],1);
m_AtRisk_mean(1,3) = m_AtRisk_all_mean(1,3,end);
m_AtRisk_std(1,3) = m_AtRisk_all_std(1,3,end);
train_time_mean(1,3) = train_time_results.time_total_mean;
train_time_std(1,3) = train_time_results.time_total_std;
test_time_mean(1,3) = test_time_results.time_total_mean;
test_time_std(1,3) = test_time_results.time_total_std;
clear CSP_mean Cured_mean AtRisk_mean WM_mean train_time_results test_time_results;

load([path 'cancer_fixstagesNtr20000_krr_markovnon_baseline_optNtr10000_9号机'], ...        
      'CSP_mean', 'Cured_mean', 'WM_mean', 'AtRisk_mean',...
      'train_time_results', 'test_time_results');
m_CSP_all_mean(2,3,:) = mean(CSP_mean);
m_CSP_all_std(2,3,:) = std(CSP_mean,[],1);
m_CSP_mean(2,3) = m_CSP_all_mean(2,3,end);
m_CSP_std(2,3) = m_CSP_all_std(2,3,end);
m_WM_all_mean(2,3,:) = mean(WM_mean);
m_WM_all_std(2,3,:) = std(WM_mean,[],1);
m_WM_mean(2,3) = m_WM_all_mean(2,3,end);
m_WM_std(2,3) = m_WM_all_std(2,3,end);
m_Cured_all_mean(2,3,:) = mean(Cured_mean);
m_Cured_all_std(2,3,:) = std(Cured_mean,[],1);
m_Cured_mean(2,3) = m_Cured_all_mean(2,3,end);
m_Cured_std(2,3) = m_Cured_all_std(2,3,end);
m_AtRisk_all_mean(2,3,:) = mean(AtRisk_mean);
m_AtRisk_all_std(2,3,:) = std(AtRisk_mean,[],1);
m_AtRisk_mean(2,3) = m_AtRisk_all_mean(2,3,end);
m_AtRisk_mean(2,3) = m_AtRisk_all_mean(2,3,end);
m_AtRisk_std(2,3) = m_AtRisk_all_std(2,3,end);
train_time_mean(2,3) = train_time_results.time_total_mean;
train_time_std(2,3) = train_time_results.time_total_std;
test_time_mean(2,3) = test_time_results.time_total_mean;
test_time_std(2,3) = test_time_results.time_total_std;
clear CSP_mean Cured_mean AtRisk_mean WM_mean train_time_results test_time_results;

m_CuredAtRisk_mean = cat(3, m_Cured_mean, m_AtRisk_mean);

%% ---------------------- CSP bar plot ----------------------------------
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = 12;

figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]); 
hold on;

% -------- fixed treatment ---------
y = CuredAtRisk_mean_fixedpolicy * 100;
m = size(y,1);
n = size(y,2);
x = 0.25:0.25:2.5;
GO = bar(x, y, 0.9, 'stacked'); 
RGB = cbrewer('seq', 'Blues', 12, 'linear');
RGB  = RGB([8,10],:);
for i = 1 : m
    for j = 1 : n
        GO(1, j).FaceColor = 'flat';
        GO(1, j).CData(i,:) = RGB(j, :);
        GO(1,j).EdgeColor = 'black';
    end
end

y = CSP_mean_fixedpolicy * 100;
neg = CSP_std_fixedpolicy * 100;
pos = CSP_std_fixedpolicy * 100;
hold on
errorbarcolor = brewermap(9, "Greys");
errorbar(x, y, neg, pos, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);

% --------- LS-DTR, DNN-DTR, KRR-DTR -----------
stackData = m_CuredAtRisk_mean;
NumGroupsPerAxis = size(stackData, 1);
NumStacksPerGroup = size(stackData, 2);

% Count off the number of bins
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75;            % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumStacksPerGroup; 
for i = 1:NumStacksPerGroup
    Y = squeeze(stackData(:,i,:)) * 100;
    % Center the bars   
    internalPosCount = i - ((NumStacksPerGroup+1) / 2) + 9.1;
    % Offset the group draw positions:
    groupDrawPos = (internalPosCount)* groupOffset + groupBins;   
    Go(i,:) = bar(groupDrawPos, Y, 'stacked');
    set(Go(i,:),'BarWidth', groupOffset*0.9);
end

RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB3 = cbrewer('seq', 'Reds', 12, 'linear');
RGB1  = RGB1([5,8],:);
RGB2  = RGB2([5,8],:);
RGB3  = RGB3([5,8],:);
RGB = cat(3, RGB1, RGB2, RGB3);
% set the color of each bar
for i = 1:3
    for j = 1:2
        Go(i, j).FaceColor = 'flat';
        Go(i, j).CData = squeeze(RGB(j,:,i));
        Go(i,j).EdgeColor = 'black';
    end
end

xx = zeros(2, 3);
for i = 1 : 3
    xx(:, i) = Go(i, 1).XEndPoints';
end
y = m_CSP_mean * 100;
neg = m_CSP_std * 100;
pos = m_CSP_std * 100;
hold on
errorbarcolor = brewermap(9, "Greys");
errorbar(xx, y, neg, pos, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);
hold off

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                       
         'XTick', [0.25:0.25:2.5 3.35:1:4.35], ...
         'Ylim', [0, 45], 'YTick', 5:5:45, ...
         'Xlim', [-0.034027777777778,4.85], ...
         'XTickLabelRotation', 30, ...
         'Xticklabel',{'0.1', '0.2', '0.3', '0.4', '0.5', ...
                       '0.6', '0.7', '0.8', '0.9', '1.0', ...
                       'M+J', 'N+J'});                                  

ylabel('CSP (%)');
legend([Go(1,1),Go(2,1),Go(3,1)], ...
    'LS-DTR', 'DNN-DTR', 'KRR-DTR', 'NumColumns', 2, 'Location', 'northwest');
close;

%% ------------------------ Training Time Results --------------------------------
figureUnits = 'centimeters';
figureWidth = 13;
figureHeight = 12;
figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]);
hold on;

RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB3 = cbrewer('seq', 'Reds', 12, 'linear');
RGB1  = RGB1([5,8],:);
RGB2  = RGB2([5,8],:);
RGB3  = RGB3([5,8],:);
RGB = cat(3,RGB1,RGB2,RGB3);

errorbarcolor = brewermap(9, "Greys");
y = train_time_mean; 
neg = train_time_std;
pos = train_time_std;
m = size(y,1);
n = size(y,2);
x = 1:m;
GO = bar(x, y, 0.9);     
for i = 1 : m
    for j = 1 : n
        GO(1, j).FaceColor = 'flat';
        GO(1, j).CData(i,:) = squeeze(RGB(i,:,j));
        GO(1,j).EdgeColor = 'black';
    end
end 

xx = zeros(m, n);
for i = 1 : n
    xx(:, i) = GO(1, i).XEndPoints';
end
hold on
errorbar(xx, y, neg, pos, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);
hold off

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                         
         'XTick', (1:m)+0.05, 'XTickLabelRotation', 30, ...
         'Ylim', [0.1, 30000], ...
         'YGrid','on', 'YMinorTick','on','YScale','log', ...
         'Xticklabel',{'M+J' 'N+J'});                             
 
ylabel('Training time (second)');
legend([GO(1),GO(2),GO(3)], ...
    'LS-DTR', 'DNN-DTR', 'KRR-DTR', 'NumColumns', 2, 'Location', 'northeast');