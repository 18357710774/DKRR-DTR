clear; clc;
addpath(genpath('brewermap'));
addpath(genpath('cbrewer'));

loadpath = [cd '\SynResults\'];

%% ------------------------ Survival Time Results --------------------------------
divideCross = 5:5:500;
ExNum = 500;

fea_mode = {'markovsingle', 'markovmulti', 'markovmulti', 'markovnon'};
action_mode = {'separ', 'separ', 'mix', 'mix'};

survival_time_mean_krrsinglemac = zeros(4, length(divideCross));
survival_time_mean_krr = zeros(4, length(divideCross));
survival_time_mean_batch_ls = zeros(4, 1);
survival_time_mean_batch_fcnet = zeros(4, 1);
survival_time_mean_batch_krr = zeros(4, 1);

survival_time_std_krrsinglemac = zeros(4, length(divideCross));
survival_time_std_krr = zeros(4, length(divideCross));
survival_time_std_batch_ls = zeros(4, 1);
survival_time_std_batch_fcnet = zeros(4, 1);
survival_time_std_batch_krr = zeros(4, 1);

for kk = 1:4
    fea_mode_tmp = fea_mode{kk};
    action_mode_tmp = action_mode{kk};

    load([loadpath 'clinical_flexiblestagesNtrVary_krr_' fea_mode_tmp '_' ...
      action_mode_tmp '_baseline.mat'], 'mean_time_hat');
    survival_time_mean_krrsinglemac(kk, :) = mean(mean_time_hat, 1);
    survival_time_std_krrsinglemac(kk, :) = std(mean_time_hat, [], 1);
    clear mean_time_hat;
    
    algoname = 'krr';
    load([loadpath 'distributed_clinical_flexstageNtr10000_' algoname '_' fea_mode_tmp '_' ...
          action_mode_tmp '_varym_Usplit.mat'], 'mean_time_hat');
    survival_time_mean_krr(kk, :) = mean(mean_time_hat, 1);
    survival_time_std_krr(kk, :) = std(mean_time_hat, [], 1);
    clear mean_time_hat;
    
    % baselines in batch mode
    algoname = 'ls';
    load([loadpath 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'mean_time_hat');
    survival_time_mean_batch_ls(kk) = mean(mean_time_hat);
    survival_time_std_batch_ls(kk) = std(mean_time_hat);
    clear mean_time_hat;
    
    % load the results of fcnet
    algoname = 'fcnet';
    load([loadpath 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'mean_time_hat');
    survival_time_mean_batch_fcnet(kk) = mean(mean_time_hat);
    survival_time_std_batch_fcnet(kk) = std(mean_time_hat);
    clear mean_time_hat;
    
    % load the results of krr
    algoname = 'krr';
    load([loadpath 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'mean_time_hat');
    survival_time_mean_batch_krr(kk) = mean(mean_time_hat);
    survival_time_std_batch_krr(kk) = std(mean_time_hat);
end

%% plot the curve of relation between survival time and number of local machines
% markovsingle + separately
plot(divideCross, survival_time_mean_krrsinglemac(1,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, survival_time_mean_batch_krr(1)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, survival_time_mean_krr(1,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                             
         'YGrid','on', 'YMinorGrid','on');                   

set(gca, 'Ylim', [1.59, 1.82]);
ylabel('Survival time (year)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, 'NumColumns', 1, 'Location', 'southwest');
close;

% markovmulti + separately
plot(divideCross, survival_time_mean_krrsinglemac(2,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, survival_time_mean_batch_krr(2)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, survival_time_mean_krr(2,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                             
         'YGrid','on', 'YMinorGrid','on');                   

set(gca, 'Ylim', [1.59, 1.82]);
ylabel('Survival time (year)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, 'NumColumns', 1, 'Location', 'southwest');
close;

% markovmulti + mix
plot(divideCross, survival_time_mean_krrsinglemac(3,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, survival_time_mean_batch_krr(3)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, survival_time_mean_krr(3,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                             
         'YGrid','on', 'YMinorGrid','on');                   

set(gca, 'Ylim', [1.59, 1.82]);
ylabel('Survival time (year)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, 'NumColumns', 1, 'Location', 'southwest');
close;

% markovnon + mix
plot(divideCross, survival_time_mean_krrsinglemac(4,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, survival_time_mean_batch_krr(4)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, survival_time_mean_krr(4,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                             
         'YGrid','on', 'YMinorGrid','on');                   

set(gca, 'Ylim', [1.59, 1.82]);
ylabel('Survival time (year)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, 'NumColumns', 1, 'Location', 'southwest');
close;

%% plot the bar of survival times for LS-DTR, DNN-DTR, KRR-DTR and DKRR
select_m_number = [10, 20, 50, 100, 300, 500];
select_ind_number = select_m_number/5;
survival_time_mean = [survival_time_mean_batch_ls survival_time_mean_batch_fcnet ...
                      survival_time_mean_krr(:,select_ind_number)];
survival_time_std = [survival_time_std_batch_ls survival_time_std_batch_fcnet ...
                      survival_time_std_krr(:,select_ind_number)];

RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB = cbrewer('qual','Set2', 9, 'linear');
mycolor(1,:) = RGB1(8,:);
mycolor(2,:) = RGB2(9,:);
mycolor(3:8,:) = RGB([1 2 3 5 6 9], :);
errorbarcolor = brewermap(9, "Greys");

figureUnits = 'centimeters';
figureWidth = 27;
figureHeight = 12;

figureHandle = figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]); 
hold on;

y = survival_time_mean; 
neg = survival_time_std;
pos = survival_time_std;
m = size(y,1);
n = size(y,2);
x = 1:m;
GO = bar(x, y, 0.85);     

for j = 1:n
    GO(1, j).FaceColor = 'flat';
    GO(1, j).CData = mycolor(j,:);
    GO(1, j).EdgeColor = 'black';
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
         'XTick', 1:m, 'XTickLabelRotation', 0, ...
         'YGrid','on', ...
         'Xticklabel',{'S+S' 'M+S' 'M+J' 'N+J'});                   
set(gca, 'Ylim', [1.3, 2.0]);
ylabel('Survival time (year)');
legendstr = {'LS-DTR', 'DNN-DTR', 'DKRR-DTR(10)', 'DKRR-DTR(20)', ...
             'DKRR-DTR(50)', 'DKRR-DTR(100)', 'DKRR-DTR(300)', 'DKRR-DTR(500)'};
legend(legendstr, 'NumColumns', 4, 'Location', 'north');
