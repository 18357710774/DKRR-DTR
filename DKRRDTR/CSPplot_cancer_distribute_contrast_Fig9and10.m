clear; clc;
addpath(genpath('brewermap'));
addpath(genpath('cbrewer'));

loadpath = [cd '\SynResults\'];

%% ------------------------ CSP Results --------------------------------
divideCross = 2:2:100;

CSP_mean_krrsinglemac = zeros(2, length(divideCross));
CSP_mean_krr = zeros(2, length(divideCross));
CSP_mean_batch_ls = zeros(2, 1);
CSP_mean_batch_fcnet = zeros(2, 1);
CSP_mean_batch_krr = zeros(2, 1);
CSP_std_krrsinglemac = zeros(2, length(divideCross));
CSP_std_krr = zeros(2, length(divideCross));
CSP_std_batch_ls = zeros(2, 1);
CSP_std_batch_fcnet = zeros(2, 1);
CSP_std_batch_krr = zeros(2, 1);

Cured_mean_krrsinglemac = zeros(2, length(divideCross));
Cured_mean_krr = zeros(2, length(divideCross));
Cured_mean_batch_ls = zeros(2, 1);
Cured_mean_batch_fcnet = zeros(2, 1);
Cured_mean_batch_krr = zeros(2, 1);
Cured_std_krrsinglemac = zeros(2, length(divideCross));
Cured_std_krr = zeros(2, length(divideCross));
Cured_std_batch_ls = zeros(2, 1);
Cured_std_batch_fcnet = zeros(2, 1);
Cured_std_batch_krr = zeros(2, 1);

AtRisk_mean_krrsinglemac = zeros(2, length(divideCross));
AtRisk_mean_krr = zeros(2, length(divideCross));
AtRisk_mean_batch_ls = zeros(2, 1);
AtRisk_mean_batch_fcnet = zeros(2, 1);
AtRisk_mean_batch_krr = zeros(2, 1);
AtRisk_std_krrsinglemac = zeros(2, length(divideCross));
AtRisk_std_krr = zeros(2, length(divideCross));
AtRisk_std_batch_ls = zeros(2, 1);
AtRisk_std_batch_fcnet = zeros(2, 1);
AtRisk_std_batch_krr = zeros(2, 1);

WM_mean_krrsinglemac = zeros(2, length(divideCross));
WM_mean_krr = zeros(2, length(divideCross));
WM_mean_batch_ls = zeros(2, 1);
WM_mean_batch_fcnet = zeros(2, 1);
WM_mean_batch_krr = zeros(2, 1);
WM_std_krrsinglemac = zeros(2, length(divideCross));
WM_std_krr = zeros(2, length(divideCross));
WM_std_batch_ls = zeros(2, 1);
WM_std_batch_fcnet = zeros(2, 1);
WM_std_batch_krr = zeros(2, 1);

% krr-single
load([loadpath 'cancer_fixstagesNtrVary_krr_markov_baseline.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_krrsinglemac(1, :) = mean(squeeze(CSP_mean(end,:,:)), 2);
CSP_std_krrsinglemac(1, :) = std(squeeze(CSP_mean(end,:,:)), [], 2);
Cured_mean_krrsinglemac(1, :) = mean(squeeze(Cured_mean(end,:,:)), 2);
Cured_std_krrsinglemac(1, :) = std(squeeze(Cured_mean(end,:,:)), [], 2);
AtRisk_mean_krrsinglemac(1, :) = mean(squeeze(AtRisk_mean(end,:,:)), 2);
AtRisk_std_krrsinglemac(1, :) = std(squeeze(AtRisk_mean(end,:,:)), [], 2);
WM_mean_krrsinglemac(1, :) = mean(squeeze(WM_mean(end,:,:)), 2);
WM_std_krrsinglemac(1, :) = std(squeeze(WM_mean(end,:,:)), [], 2);
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

load([loadpath 'cancer_fixstagesNtrVary_krr_markovnon_baseline.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_krrsinglemac(2, :) = mean(squeeze(CSP_mean(end,:,:)), 2);
CSP_std_krrsinglemac(2, :) = std(squeeze(CSP_mean(end,:,:)), [], 2);
Cured_mean_krrsinglemac(2, :) = mean(squeeze(Cured_mean(end,:,:)), 2);
Cured_std_krrsinglemac(2, :) = std(squeeze(Cured_mean(end,:,:)), [], 2);
AtRisk_mean_krrsinglemac(2, :) = mean(squeeze(AtRisk_mean(end,:,:)), 2);
AtRisk_std_krrsinglemac(2, :) = std(squeeze(AtRisk_mean(end,:,:)), [], 2);
WM_mean_krrsinglemac(2, :) = mean(squeeze(WM_mean(end,:,:)), 2);
WM_std_krrsinglemac(2, :) = std(squeeze(WM_mean(end,:,:)), [], 2);
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

% dkrr
load([loadpath 'distributed_cancer_fixstageNtr20000_krr_markov_varym_Usplit.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_krr(1, :) = mean(squeeze(CSP_mean(:,end,:)), 2);
CSP_std_krr(1, :) = std(squeeze(CSP_mean(:,end,:,:)), [], 2);
Cured_mean_krr(1, :) = mean(squeeze(Cured_mean(:,end,:,:)), 2);
Cured_std_krr(1, :) = std(squeeze(Cured_mean(:,end,:,:)), [], 2);
AtRisk_mean_krr(1, :) = mean(squeeze(AtRisk_mean(:,end,:,:)), 2);
AtRisk_std_krr(1, :) = std(squeeze(AtRisk_mean(:,end,:,:)), [], 2);
WM_mean_krr(1, :) = mean(squeeze(WM_mean(:,end,:,:)), 2);
WM_std_krr(1, :) = std(squeeze(WM_mean(:,end,:,:)), [], 2);
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

load([loadpath 'distributed_cancer_fixstageNtr20000_krr_markovnon_varym_Usplit.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_krr(2, :) = mean(squeeze(CSP_mean(:,end,:)), 2);
CSP_std_krr(2, :) = std(squeeze(CSP_mean(:,end,:)), [], 2);
Cured_mean_krr(2, :) = mean(squeeze(Cured_mean(:,end,:)), 2);
Cured_std_krr(2, :) = std(squeeze(Cured_mean(:,end,:)), [], 2);
AtRisk_mean_krr(2, :) = mean(squeeze(AtRisk_mean(:,end,:)), 2);
AtRisk_std_krr(2, :) = std(squeeze(AtRisk_mean(:,end,:)), [], 2);
WM_mean_krr(2, :) = mean(squeeze(WM_mean(:,end,:)), 2);
WM_std_krr(2, :) = std(squeeze(WM_mean(:,end,:)), [], 2);

% ls in batch mode
load([loadpath 'cancer_fixstagesNtr20000_ls_markov_baseline.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_batch_ls(1) = mean(CSP_mean(:,end));
CSP_std_batch_ls(1) = std(CSP_mean(:,end));
Cured_mean_batch_ls(1) = mean(Cured_mean(:,end));
Cured_std_batch_ls(1) = std(Cured_mean(:,end));
AtRisk_mean_batch_ls(1) = mean(AtRisk_mean(:,end));
AtRisk_std_batch_ls(1) = std(AtRisk_mean(:,end));
WM_mean_batch_ls(1) = mean(WM_mean(:,end));
WM_std_batch_ls(1) = std(WM_mean(:,end));
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

load([loadpath 'cancer_fixstagesNtr20000_ls_markovnon_baseline.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_batch_ls(2) = mean(CSP_mean(:,end));
CSP_std_batch_ls(2) = std(CSP_mean(:,end));
Cured_mean_batch_ls(2) = mean(Cured_mean(:,end));
Cured_std_batch_ls(2) = std(Cured_mean(:,end));
AtRisk_mean_batch_ls(2) = mean(AtRisk_mean(:,end));
AtRisk_std_batch_ls(2) = std(AtRisk_mean(:,end));
WM_mean_batch_ls(2) = mean(WM_mean(:,end));
WM_std_batch_ls(2) = std(WM_mean(:,end));
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

% fcnet in batch mode
load([loadpath 'cancer_fixstagesNtr20000_fcnet_markov_baseline_ExNum20.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_batch_fcnet(1) = mean(CSP_mean(:,end));
CSP_std_batch_fcnet(1) = std(CSP_mean(:,end));
Cured_mean_batch_fcnet(1) = mean(Cured_mean(:,end));
Cured_std_batch_fcnet(1) = std(Cured_mean(:,end));
AtRisk_mean_batch_fcnet(1) = mean(AtRisk_mean(:,end));
AtRisk_std_batch_fcnet(1) = std(AtRisk_mean(:,end));
WM_mean_batch_fcnet(1) = mean(WM_mean(:,end));
WM_std_batch_fcnet(1) = std(WM_mean(:,end));
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

load([loadpath 'cancer_fixstagesNtr20000_fcnet_markovnon_baseline_ExNum20.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_batch_fcnet(2) = mean(CSP_mean(:,end));
CSP_std_batch_fcnet(2) = std(CSP_mean(:,end));
Cured_mean_batch_fcnet(2) = mean(Cured_mean(:,end));
Cured_std_batch_fcnet(2) = std(Cured_mean(:,end));
AtRisk_mean_batch_fcnet(2) = mean(AtRisk_mean(:,end));
AtRisk_std_batch_fcnet(2) = std(AtRisk_mean(:,end));
WM_mean_batch_fcnet(2) = mean(WM_mean(:,end));
WM_std_batch_fcnet(2) = std(WM_mean(:,end));
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

% krr in batch mode
load([loadpath 'cancer_fixstagesNtr20000_krr_markov_baseline_optNtr10000.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_batch_krr(1) = mean(CSP_mean(:,end));
CSP_std_batch_krr(1) = std(CSP_mean(:,end));
Cured_mean_batch_krr(1) = mean(Cured_mean(:,end));
Cured_std_batch_krr(1) = std(Cured_mean(:,end));
AtRisk_mean_batch_krr(1) = mean(AtRisk_mean(:,end));
AtRisk_std_batch_krr(1) = std(AtRisk_mean(:,end));
WM_mean_batch_krr(1) = mean(WM_mean(:,end));
WM_std_batch_krr(1) = std(WM_mean(:,end));
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

load([loadpath 'cancer_fixstagesNtr20000_krr_markovnon_baseline_optNtr10000_9号机.mat'], ...
      'CSP_mean', 'Cured_mean', 'AtRisk_mean', 'WM_mean');
CSP_mean_batch_krr(2) = mean(CSP_mean(:,end));
CSP_std_batch_krr(2) = std(CSP_mean(:,end));
Cured_mean_batch_krr(2) = mean(Cured_mean(:,end));
Cured_std_batch_krr(2) = std(Cured_mean(:,end));
AtRisk_mean_batch_krr(2) = mean(AtRisk_mean(:,end));
AtRisk_std_batch_krr(2) = std(AtRisk_mean(:,end));
WM_mean_batch_krr(2) = mean(WM_mean(:,end));
WM_std_batch_krr(2) = std(WM_mean(:,end));
clear CSP_mean Cured_mean AtRisk_mean WM_mean;

%% plot the curve of relation between CSP and number of local machines
% markov
plot(divideCross, CSP_mean_krrsinglemac(1,:)*100, 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, CSP_mean_batch_krr(1)*ones(1,length(divideCross))*100, ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, CSP_mean_krr(1,:)*100, 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                             
         'YGrid','on', 'YMinorGrid','off', ...
         'Ylim', [26, 40], 'Xlim', [1, 101]);                   

% 标签及Legend 设置    
ylabel('CSP (%)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, 'NumColumns', 1, 'Location', 'southwest');
close;


% markovnon
plot(divideCross, CSP_mean_krrsinglemac(2,:)*100, 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, CSP_mean_batch_krr(2)*ones(1,length(divideCross))*100, ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, CSP_mean_krr(2,:)*100, 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                             
         'YGrid','on', 'YMinorGrid','on');                   

set(gca, 'Ylim', [27.5, 36.5]);
% 标签及Legend 设置    
ylabel('CSP (%)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, 'NumColumns', 1, 'Location', 'southwest');
close;

%% plot the bar of survival times for LS-DTR, DNN-DTR, KRR-DTR and DKRR
select_m_number = [10:10:50, 70, 100];
select_ind_number = select_m_number/2;
CSP_mean = [CSP_mean_batch_ls CSP_mean_batch_fcnet ...
                      CSP_mean_krr(:,select_ind_number)];
CSP_std = [CSP_std_batch_ls CSP_std_batch_fcnet ...
                      CSP_std_krr(:,select_ind_number)];
Cured_mean = [Cured_mean_batch_ls Cured_mean_batch_fcnet ...
                      Cured_mean_krr(:,select_ind_number)];
Cured_std = [Cured_std_batch_ls Cured_std_batch_fcnet ...
                      Cured_std_krr(:,select_ind_number)];
AtRisk_mean = [AtRisk_mean_batch_ls AtRisk_mean_batch_fcnet ...
                      AtRisk_mean_krr(:,select_ind_number)];
AtRisk_std = [AtRisk_std_batch_ls AtRisk_std_batch_fcnet ...
                      AtRisk_std_krr(:,select_ind_number)];

CuredAtRisk_mean = cat(3, Cured_mean, AtRisk_mean);

RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB3 = cbrewer('qual','Set2', 9, 'linear');
RGB4 = cbrewer('qual','Dark2', 9, 'linear');
mycolor1(1,:) = RGB1(9,:);
mycolor1(2,:) = RGB2(9,:);
mycolor1(3:9,:) = RGB3([1 2 3 4 5 6 9], :);
mycolor2(1,:) = RGB1(11,:);
mycolor2(2,:) = RGB2(11,:);
mycolor2(3:9,:) = RGB4([1 2 3 4 5 6 9], :);
mycolor = cat(3, mycolor1, mycolor2);
errorbarcolor = brewermap(9, "Greys");

figureUnits = 'centimeters';
figureWidth = 13.9;
figureHeight = 12;
figureHandle = figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]);
hold on;

stackData = CuredAtRisk_mean;
NumGroupsPerAxis = size(stackData, 1);
NumStacksPerGroup = size(stackData, 2);

% Count off the number of bins
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.88;            % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumStacksPerGroup; 
for i = 1:NumStacksPerGroup
    Y = squeeze(stackData(:,i,:)) * 100;
    % Center the bars   
    internalPosCount = i - ((NumStacksPerGroup+1) / 2);
    % Offset the group draw positions:
    groupDrawPos = (internalPosCount)* groupOffset + groupBins;   
    Go(i,:) = bar(groupDrawPos, Y, 'stacked');
    set(Go(i,:),'BarWidth', groupOffset*0.85);
end

for i = 1:9
    for j = 1:2
        Go(i, j).FaceColor = 'flat';
        Go(i, j).CData = squeeze(mycolor(i,:,j));
        Go(i,j).EdgeColor = 'black';
    end
end

xx = zeros(2, 9);
for i = 1 : 9
    xx(:, i) = Go(i, 1).XEndPoints';
end
y = CSP_mean * 100;
neg = CSP_std * 100;
pos = CSP_std * 100;
hold on
errorbar(xx, y, neg, pos, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);
hold off

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                            
         'XTick', 1:2, 'XTickLabelRotation', 0, ...
         'Xlim', [0.53, 2.47], ...
         'Ylim', [10, 50], 'YGrid','on', ...
         'Xticklabel',{'M+J' 'N+J'});              
ylabel('CSP (%)');
legendstr = {'LS', 'DNN', 'DKRR(10)', 'DKRR(20)', 'DKRR(30)', ...
             'DKRR(40)', 'DKRR(50)', 'DKRR(70)', 'DKRR(100)'};
legend([Go(1,1),Go(2,1),Go(3,1),Go(4,1),Go(5,1),Go(6,1),Go(7,1),Go(8,1),Go(9,1)], ...
        legendstr,'NumColumns', 3, 'Location', 'northeast');
