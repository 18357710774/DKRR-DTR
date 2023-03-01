clear; clc;
addpath(genpath('brewermap'));
addpath(genpath('cbrewer'));

loadpath = [cd '\SynResults\'];

%% ------------------------ Training Time Results --------------------------------
divideCross = 2:2:100;
num_stages = 6;
N = 20000;
iota = 100;                % the number of actions

training_time_mean_krrsinglemac = zeros(2, length(divideCross));
training_time_total_mean_krr = zeros(2, length(divideCross));
training_time_local_mean_krr = zeros(2, length(divideCross));
training_time_synthesize_mean_krr = zeros(2, length(divideCross));

training_time_mean_batch_ls = zeros(2, 1);
training_time_mean_batch_fcnet = zeros(2, 1);
training_time_mean_batch_krr = zeros(2, 1);

training_time_std_krrsinglemac = zeros(2, length(divideCross));
training_time_total_std_krr = zeros(2, length(divideCross));
training_time_local_std_krr = zeros(2, length(divideCross));
training_time_synthesize_std_krr = zeros(2, length(divideCross));

training_time_std_batch_ls = zeros(2, 1);
training_time_std_batch_fcnet = zeros(2, 1);
training_time_std_batch_krr = zeros(2, 1);

% krr-single
load([loadpath 'cancer_fixstagesNtrVary_krr_markov_baseline.mat'], ...
      'train_time_results');
training_time_mean_krrsinglemac(1, :) = train_time_results.time_total_mean;
training_time_std_krrsinglemac(1, :) = train_time_results.time_total_std;
clear train_time_results;

load([loadpath 'cancer_fixstagesNtrVary_krr_markovnon_baseline.mat'], ...
      'train_time_results');
training_time_mean_krrsinglemac(2, :) = train_time_results.time_total_mean;
training_time_std_krrsinglemac(2, :) = train_time_results.time_total_std;
clear train_time_results;

% dkrr
load([loadpath 'distributed_cancer_fixstageNtr20000_krr_markov_varym_Usplit.mat'], ...
      'train_time_results', 'train_time_total_mean');
training_time_local_tmp = zeros(num_stages, length(divideCross), 20);
training_time_synthesize_tmp = zeros(num_stages, length(divideCross), 20);
for i = 1:length(divideCross)
    training_time_local_tmp(:,i,:) = mean(train_time_results(i).time_local, 2);
    training_time_synthesize_tmp(:,i,:) = train_time_results(i).time_synthesize;
end
training_time_local = squeeze(sum(training_time_local_tmp, 1));
training_time_synthesize = squeeze(sum(training_time_synthesize_tmp, 1));
training_time_total = squeeze(sum(training_time_local_tmp+training_time_synthesize_tmp, 1));
training_time_total_mean_krr(1, :) = mean(training_time_total, 2);
training_time_local_mean_krr(1, :) = mean(training_time_local, 2);
training_time_synthesize_mean_krr(1, :) = mean(training_time_synthesize, 2);
training_time_total_std_krr(1, :) = std(training_time_total, [], 2);
training_time_local_std_krr(1, :) = std(training_time_local, [], 2);
training_time_synthesize_std_krr(1, :) = std(training_time_synthesize, [], 2);
disp(num2str(max(abs(mean(training_time_total, 2) - train_time_total_mean'))))
clear train_time_results train_time_total_mean training_time_total ...
    training_time_local training_time_synthesize;

load([loadpath 'distributed_cancer_fixstageNtr20000_krr_markovnon_varym_Usplit.mat'], ...
      'train_time_results', 'train_time_total_mean');
training_time_local_tmp = zeros(num_stages, length(divideCross), 20);
training_time_synthesize_tmp = zeros(num_stages, length(divideCross), 20);
for i = 1:length(divideCross)
    training_time_local_tmp(:,i,:) = mean(train_time_results(i).time_local, 2);
    training_time_synthesize_tmp(:,i,:) = train_time_results(i).time_synthesize;
end
training_time_local = squeeze(sum(training_time_local_tmp, 1));
training_time_synthesize = squeeze(sum(training_time_synthesize_tmp, 1));
training_time_total = squeeze(sum(training_time_local_tmp+training_time_synthesize_tmp, 1));
training_time_total_mean_krr(2, :) = mean(training_time_total, 2);
training_time_local_mean_krr(2, :) = mean(training_time_local, 2);
training_time_synthesize_mean_krr(2, :) = mean(training_time_synthesize, 2);
training_time_total_std_krr(2, :) = std(training_time_total, [], 2);
training_time_local_std_krr(2, :) = std(training_time_local, [], 2);
training_time_synthesize_std_krr(2, :) = std(training_time_synthesize, [], 2);
disp(num2str(max(abs(mean(training_time_total, 2) - train_time_total_mean'))))
clear train_time_results train_time_total_mean training_time_total ...
    training_time_local training_time_synthesize;

% ls in batch mode
load([loadpath 'cancer_fixstagesNtr20000_ls_markov_baseline.mat'], ...
      'train_time_results');
training_time_mean_batch_ls(1) = train_time_results.time_total_mean;
training_time_std_batch_ls(1) = train_time_results.time_total_std;
clear train_time_results;

load([loadpath 'cancer_fixstagesNtr20000_ls_markovnon_baseline.mat'], ...
      'train_time_results');
training_time_mean_batch_ls(2) = train_time_results.time_total_mean;
training_time_std_batch_ls(2) = train_time_results.time_total_std;
clear train_time_results;

% fcnet in batch mode
load([loadpath 'cancer_fixstagesNtr20000_fcnet_markov_baseline_ExNum20.mat'], ...
      'train_time_results');
training_time_mean_batch_fcnet(1) = train_time_results.time_total_mean;
training_time_std_batch_fcnet(1) = train_time_results.time_total_std;
clear train_time_results;

load([loadpath 'cancer_fixstagesNtr20000_fcnet_markovnon_baseline_ExNum20.mat'], ...
      'train_time_results');
training_time_mean_batch_fcnet(2) = train_time_results.time_total_mean;
training_time_std_batch_fcnet(2) = train_time_results.time_total_std;
clear train_time_results;


% krr in batch mode
load([loadpath 'cancer_fixstagesNtr20000_krr_markov_baseline_optNtr10000.mat'], ...
      'train_time_results');
training_time_mean_batch_krr(1) = train_time_results.time_total_mean;
training_time_std_batch_krr(1) = train_time_results.time_total_std;
clear train_time_results

load([loadpath 'cancer_fixstagesNtr20000_krr_markovnon_baseline_optNtr10000_9号机.mat'], ...
      'train_time_results');
training_time_mean_batch_krr(2) = train_time_results.time_total_mean;
training_time_std_batch_krr(2) = train_time_results.time_total_std;
clear train_time_results


%% plot the curve of relation between survival time and number of local machines
% markov + mix
plot(divideCross, training_time_mean_krrsinglemac(1,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, training_time_mean_batch_krr(1)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, training_time_total_mean_krr(1,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);
hold on;
set(gca, 'FontSize',12, 'box', 'on', 'Ylim', [0.1, 2000], ...
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...                             
         'Xlim', [1, 101], 'YGrid','on', 'YMinorGrid','on');                   
ylabel('Training time (second)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, ...
        'NumColumns', 1, 'Location', 'southwest');
close;

% markovnon + mix
plot(divideCross, training_time_mean_krrsinglemac(2,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, training_time_mean_batch_krr(2)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, training_time_total_mean_krr(2,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);
hold on;
set(gca, 'FontSize',12, 'box', 'on', 'Ylim', [0.1, 2000], ...
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...                             
         'Xlim', [1, 101], 'YGrid','on', 'YMinorGrid','on');                   
ylabel('Training time (second)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR'}, ...
        'NumColumns', 1, 'Location', 'southwest');
close;


%% plot the bar of Training times for LS-DTR, DNN-DTR, KRR-DTR and DKRR
select_m_number = [10:10:50, 70, 100];
select_ind_number = select_m_number/2;
training_time_mean = [training_time_mean_batch_ls training_time_mean_batch_fcnet ...
                      training_time_total_mean_krr(:,select_ind_number)];
training_time_std = [training_time_std_batch_ls training_time_std_batch_fcnet ...
                      training_time_total_std_krr(:,select_ind_number)];

RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB = cbrewer('qual','Set2', 9, 'linear');
mycolor(1,:) = RGB1(8,:);
mycolor(2,:) = RGB2(9,:);
mycolor(3:9,:) = RGB([1 2 3 4 5 6 9], :);
errorbarcolor = brewermap(9, "Greys");

figureUnits = 'centimeters';
figureWidth = 14;
figureHeight = 12;
figureHandle = figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]); % define the new figure dimensions
hold on;
y = training_time_mean; 
neg = training_time_std;
pos = training_time_std;
m = size(y,1);
n = size(y,2);
x = 1:m;
GO = bar(x, y, 0.9);     

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
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...   
         'XTick', 1:m, 'XTickLabelRotation', 0, ...
         'YGrid','on',  'Xlim', [0.53, 2.48], ...
         'Xticklabel',{'M+J' 'N+J'});           
set(gca, 'Ylim', [0.1, 50000]);
ylabel('Training time (second)');
legendstr = {'LS', 'DNN', 'DKRR(10)', 'DKRR(20)', 'DKRR(30)', ...
             'DKRR(40)', 'DKRR(50)', 'DKRR(70)', 'DKRR(100)'};
legend(legendstr, 'NumColumns', 3, 'Location', 'northeast');
