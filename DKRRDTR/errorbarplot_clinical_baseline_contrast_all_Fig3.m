clear; clc;
addpath(genpath('brewermap'));
addpath(genpath('cbrewer'));

path = [cd '\SynResults\'];

%% ------------------------ Survival Time Results --------------------------------
% load the results of the eight fixed treatment
load([path 'clinical_flexstages_fixpolicy_ExNum500.mat'], 'TotalTime_mean');
survival_time_mean_fixedpolicy = mean(TotalTime_mean, 1);
survival_time_std_fixedpolicy = std(TotalTime_mean, [], 1);
clear TotalTime_mean;
xlabel_str = {'AAA', 'AAB', 'ABA', 'ABB', 'BAA', 'BAB', 'BBA', 'BBB'};

RGB = cbrewer('seq', 'Blues', 12, 'linear');
RGB = RGB(4:11,:);
errorbarcolor = brewermap(9, "Greys");

% figure size
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = 12;
figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]); % define the new figure dimensions
hold on;

x1 = 0.25:0.25:2;
y1 = survival_time_mean_fixedpolicy; 
[~, indsort] = sort(y1, 'ascend');
neg1 = survival_time_std_fixedpolicy;
pos1 = survival_time_std_fixedpolicy;
Go = bar(x1, y1, 0.85);

% set the color of the jth bar in the ith group
Go.FaceColor = 'flat';
Go.EdgeColor = 'black';
for i = 1:8
    Go.CData(indsort(i),:) = RGB(i,:);
end
% plot the error
xx1 = Go.XEndPoints;
hold on
errorbar(xx1, y1, neg1, pos1, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);

% plot the results of the three compared methods
fea_mode = {'markovsingle', 'markovmulti', 'markovmulti', 'markovnon'};
action_mode = {'separ', 'separ', 'mix', 'mix'};

%  mxn matrix, where m is the number of groups and n is the number of bars in each group
survival_time_mean = zeros(4,3);
survival_time_std = zeros(4,3);
train_time_mean = zeros(4,3);
train_time_std = zeros(4,3);
test_time_mean = zeros(4,3);
test_time_std = zeros(4,3);

for kk = 1:4
    fea_mode_tmp = fea_mode{kk};
    action_mode_tmp = action_mode{kk};

    % load the results of ls
    algoname = 'ls';
    load([path 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'mean_time_hat', 'train_time_results', 'test_time_results');
    survival_time_mean(kk,1) = mean(mean_time_hat);
    survival_time_std(kk,1) = std(mean_time_hat);
    train_time_mean(kk,1) = train_time_results.time_total_mean;
    train_time_std(kk,1) = train_time_results.time_total_std;
    test_time_mean(kk,1) = test_time_results.time_total_mean;
    test_time_std(kk,1) = test_time_results.time_total_std;
    clear mean_time_hat train_time_results test_time_results;
    
    % load the results of fcnet
    algoname = 'fcnet';
    load([path 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'mean_time_hat', 'train_time_results', 'test_time_results');
    survival_time_mean(kk,2) = mean(mean_time_hat);
    survival_time_std(kk,2) = std(mean_time_hat);
    train_time_mean(kk,2) = train_time_results.time_total_mean;
    train_time_std(kk,2) = train_time_results.time_total_std;
    test_time_mean(kk,2) = test_time_results.time_total_mean;
    test_time_std(kk,2) = test_time_results.time_total_std;
    clear mean_time_hat train_time_results test_time_results;
    
    % load the results of krr
    algoname = 'krr';
    load([path 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'mean_time_hat', 'train_time_results', 'test_time_results');
    survival_time_mean(kk,3) = mean(mean_time_hat);
    survival_time_std(kk,3) = std(mean_time_hat);
    train_time_mean(kk,3) = train_time_results.time_total_mean;
    train_time_std(kk,3) = train_time_results.time_total_std;
    test_time_mean(kk,3) = test_time_results.time_total_mean;
    test_time_std(kk,3) = test_time_results.time_total_std;
    clear mean_time_hat train_time_results test_time_results;
end

RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB3 = cbrewer('seq', 'Reds', 12, 'linear');
RGB1  = RGB1([5,7,8,9],:);
RGB2  = RGB2([5,7,8,9],:);
RGB3  = RGB3([5,7,8,9],:);
RGB = cat(3,RGB1,RGB2,RGB3);
errorbarcolor = brewermap(9, "Greys");

y = survival_time_mean; 
neg = survival_time_std;
pos = survival_time_std;
m = size(y,1);
n = size(y,2);
x = (1:m) + 1.95;
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
         'XTick', [0.25:0.25:2 3:6], ...
         'Ylim', [0,2], 'YTick',0.2:0.2:2, ...
         'XTickLabelRotation', 45, ...
         'Xticklabel',{'AAA', 'AAB', 'ABA', 'ABB', 'BAA', 'BAB', 'BBA', 'BBB', ...
         'S+S' 'M+S' 'M+J' 'N+J'});                   
ylabel('Survival time (year)');
legend([GO(1),GO(2),GO(3)], 'LS-DTR', 'DNN-DTR', 'KRR-DTR', ...
        'NumColumns', 2, 'Location', 'northwest');
close;

%% ------------------------ Training Time Results --------------------------------
figureUnits = 'centimeters';
figureWidth = 13;
figureHeight = 12;
figureHandle = figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]); % define the new figure dimensions
hold on;

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
         'XTick', 1:m, 'XTickLabelRotation', 30, ...
         'YGrid','on', 'YMinorTick','on','YScale','log', ...
         'Xticklabel',{'S+S' 'M+S' 'M+J' 'N+J'});    
ylabel('Training time (second)');
legend([GO(1),GO(2),GO(3)],  'LS-DTR', 'DNN-DTR', 'KRR-DTR', ...
        'NumColumns', 3, 'Location', 'north');
