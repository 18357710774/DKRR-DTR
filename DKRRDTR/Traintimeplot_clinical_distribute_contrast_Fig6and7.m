clear; clc;
addpath(genpath('brewermap'));
addpath(genpath('cbrewer'));

loadpath = [cd '\SynResults\'];

%% ------------------------ Training Time Results --------------------------------
divideCross = 5:5:500;
ExNum = 500;
num_stages = 3;
N = 10000;
iota = 2;                % the number of actions

fea_mode = {'markovsingle', 'markovmulti', 'markovmulti', 'markovnon'};
action_mode = {'separ', 'separ', 'mix', 'mix'};

training_time_mean_krrsinglemac = zeros(4, length(divideCross));
training_time_total_mean_krr = zeros(4, length(divideCross));
training_time_local_mean_krr = zeros(4, length(divideCross));
training_time_synthesize_mean_krr = zeros(4, length(divideCross));

training_time_mean_batch_ls = zeros(4, 1);
training_time_mean_batch_fcnet = zeros(4, 1);
training_time_mean_batch_krr = zeros(4, 1);

training_time_std_krrsinglemac = zeros(4, length(divideCross));
training_time_total_std_krr = zeros(4, length(divideCross));
training_time_local_std_krr = zeros(4, length(divideCross));
training_time_synthesize_std_krr = zeros(4, length(divideCross));

training_time_std_batch_ls = zeros(4, 1);
training_time_std_batch_fcnet = zeros(4, 1);
training_time_std_batch_krr = zeros(4, 1);

for kk = 1:4
    fea_mode_tmp = fea_mode{kk};
    action_mode_tmp = action_mode{kk};

    load([loadpath 'clinical_flexiblestagesNtrVary_krr_' fea_mode_tmp '_' ...
      action_mode_tmp '_baseline.mat'], 'train_time_results');
    training_time_mean_krrsinglemac(kk, :) = train_time_results.time_total_mean;
    training_time_std_krrsinglemac(kk, :) = train_time_results.time_total_std;
    clear train_time_results;
    
    algoname = 'krr';
    load([loadpath 'distributed_clinical_flexstageNtr10000_' algoname '_' fea_mode_tmp '_' ...
          action_mode_tmp '_varym_Usplit.mat'], 'train_time_results', 'train_time_total_mean');
    training_time_local_tmp = zeros(num_stages, length(divideCross), ExNum);
    training_time_synthesize_tmp = zeros(num_stages, length(divideCross), ExNum);
    for i = 1:length(divideCross)
        training_time_local_tmp(:,i,:) = mean(train_time_results(i).time_local, 2);
        training_time_synthesize_tmp(:,i,:) = train_time_results(i).time_synthesize;
    end
    training_time_local = squeeze(sum(training_time_local_tmp, 1));
    training_time_synthesize = squeeze(sum(training_time_synthesize_tmp, 1));
    training_time_total = squeeze(sum(training_time_local_tmp+training_time_synthesize_tmp, 1));

    training_time_total_mean_krr(kk, :) = mean(training_time_total, 2);
    training_time_local_mean_krr(kk, :) = mean(training_time_local, 2);
    training_time_synthesize_mean_krr(kk, :) = mean(training_time_synthesize, 2);
    training_time_total_std_krr(kk, :) = std(training_time_total, [], 2);
    training_time_local_std_krr(kk, :) = std(training_time_local, [], 2);
    training_time_synthesize_std_krr(kk, :) = std(training_time_synthesize, [], 2);

    clear train_time_results train_time_total_mean training_time_total ...
        training_time_local training_time_synthesize;
    
    % baselines in batch mode
    algoname = 'ls';
    load([loadpath 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'train_time_results');
    training_time_mean_batch_ls(kk) = train_time_results.time_total_mean;
    training_time_std_batch_ls(kk) = train_time_results.time_total_std;
    clear train_time_results;
    
    % load the results of fcnet
    algoname = 'fcnet';
    load([loadpath 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'train_time_results');
    training_time_mean_batch_fcnet(kk) = train_time_results.time_total_mean;
    training_time_std_batch_fcnet(kk) = train_time_results.time_total_std;
    clear train_time_results;
    
    % load the results of krr
    algoname = 'krr';
    load([loadpath 'clinical_flexiblestagesNtr10000_' algoname '_' fea_mode_tmp '_' action_mode_tmp ...
          '_baseline.mat'], 'train_time_results');
    training_time_mean_batch_krr(kk) = train_time_results.time_total_mean;
    training_time_std_batch_krr(kk) = train_time_results.time_total_std;
    clear train_time_results
end

%% plot the curve of relation between survival time and number of local machines
% markovsingle + separately
plot(divideCross, training_time_mean_krrsinglemac(1,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, training_time_mean_batch_krr(1)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, training_time_total_mean_krr(1,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);
hold on;
% plot the estimated optimal number of local machines
kappa = 2;
m2 = (N*(kappa*iota+iota) + N*sqrt((kappa*iota+iota)^2+12*iota))/(2*iota);
m_star = round(sqrt(m2)); % estimated optimal number of local machines
% Linear Interpolation
aaa = divideCross(m_star<divideCross);
ind2 = aaa(1)/5;
ind1 = ind2-1;
m_tmp = [divideCross(ind1) divideCross(ind2)];
train_time_tmp = training_time_total_mean_krr(1,[ind1 ind2]);
train_time_star = interp1(m_tmp, train_time_tmp, m_star, 'linear');
scatter(m_star, train_time_star,120,'LineWidth',1.5,'Marker','pentagram', ...
        'MarkerEdgeColor',[0.717647058823529 0.274509803921569 1]);
set(gca, 'FontSize',12, 'box', 'on', 'Ylim', [0.0007, 20], ...
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...                             
         'Xlim', [0, 505], 'YGrid','on', 'YMinorGrid','on');                   
ylabel('Training time (second)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR', 'Estimated m*'}, ...
        'NumColumns', 1, 'Location', 'northeast');
close;

% markovmulti + separately
plot(divideCross, training_time_mean_krrsinglemac(2,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, training_time_mean_batch_krr(2)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, training_time_total_mean_krr(2,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);
hold on;
% plot the estimated optimal number of local machines
kappa = 3;
m2 = (N*(kappa*iota+iota) + N*sqrt((kappa*iota+iota)^2+12*iota))/(2*iota);
m_star = round(sqrt(m2)); % estimated optimal number of local machines
% Linear Interpolation
aaa = divideCross(m_star<divideCross);
ind2 = aaa(1)/5;
ind1 = ind2-1;
m_tmp = [divideCross(ind1) divideCross(ind2)];
train_time_tmp = training_time_total_mean_krr(2,[ind1 ind2]);
train_time_star = interp1(m_tmp, train_time_tmp, m_star, 'linear');
scatter(m_star, train_time_star,120,'LineWidth',1.5,'Marker','pentagram', ...
        'MarkerEdgeColor',[0.717647058823529 0.274509803921569 1]);
set(gca, 'FontSize',12, 'box', 'on', 'Ylim', [0.0007, 20], ...
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...                             
         'Xlim', [0, 505], 'YGrid','on', 'YMinorGrid','on');                   
ylabel('Training time (second)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR', 'Estimated m*'}, ...
        'NumColumns', 1, 'Location', 'northeast');
close;

% markovmulti + mix
plot(divideCross, training_time_mean_krrsinglemac(3,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, training_time_mean_batch_krr(3)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, training_time_total_mean_krr(3,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);
hold on;
% plot the estimated optimal number of local machines
kappa = 4;
m2 = (N*(kappa*iota+iota) + N*sqrt((kappa*iota+iota)^2+12*iota))/(2*iota);
m_star = round(sqrt(m2)); % estimated optimal number of local machines
% Linear Interpolation
aaa = divideCross(m_star<divideCross);
ind2 = aaa(1)/5;
ind1 = ind2-1;
m_tmp = [divideCross(ind1) divideCross(ind2)];
train_time_tmp = training_time_total_mean_krr(3,[ind1 ind2]);
train_time_star = interp1(m_tmp, train_time_tmp, m_star, 'linear');
scatter(m_star, train_time_star,120,'LineWidth',1.5,'Marker','pentagram', ...
        'MarkerEdgeColor',[0.717647058823529 0.274509803921569 1]);

set(gca, 'FontSize',12, 'box', 'on', 'Ylim', [0.0005, 100], ...
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...                             
         'Xlim', [0, 505], 'YGrid','on', 'YMinorGrid','on');                   
ylabel('Training time (second)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR', 'Estimated m*'}, ...
        'NumColumns', 1, 'Location', 'northeast');
close;

% markovnon + mix
plot(divideCross, training_time_mean_krrsinglemac(4,:), 'Color', ...
    [0.0745098039215686 0.623529411764706 1], 'LineWidth', 2);
hold on;
plot(divideCross, training_time_mean_batch_krr(4)*ones(1,length(divideCross)), ...
    'Color', 'black', 'LineWidth', 2, 'LineStyle', '-.');
hold on;
plot(divideCross, training_time_total_mean_krr(4,:), 'Color', ...
    [1 0.411764705882353 0.16078431372549],  'LineWidth', 2);
hold on;
% plot the estimated optimal number of local machines
l1 = 2; l2 = 2; l3 = 2;
k1 = 4; k2 = 7; k3 = 10;
T = num_stages;
l = l1+l2+l3;
aa = l1*(1+k1)+l2*(1+k2)+l3*(1+k3);
m2 = (N*aa + N*sqrt(aa^2+12*T*l))/(2*l);
m_star = sqrt(m2); % estimated optimal number of local machines
% Linear Interpolation
aaa = divideCross(m_star<divideCross);
ind2 = aaa(1)/5;
ind1 = ind2-1;
m_tmp = [divideCross(ind1) divideCross(ind2)];
train_time_tmp = training_time_total_mean_krr(4,[ind1 ind2]);
train_time_star = interp1(m_tmp, train_time_tmp, m_star, 'linear');
scatter(m_star, train_time_star,120,'LineWidth',1.5,'Marker','pentagram', ...
        'MarkerEdgeColor',[0.717647058823529 0.274509803921569 1]);

set(gca, 'FontSize',12, 'box', 'on', 'Ylim', [0.0005, 200], ...
         'XGrid', 'off', 'YGrid', 'on', 'YScale', 'log', ...                             
         'Xlim', [0, 505], 'YGrid','on', 'YMinorGrid','on');                   
ylabel('Training time (second)');
xlabel('The number of local machines');
legend({'S-KRR-DTR', 'KRR-DTR', 'DKRR-DTR', 'Estimated m*'}, ...
        'NumColumns', 1, 'Location', 'northeast');
close;


%% plot the bar of Training times for LS-DTR, DNN-DTR, KRR-DTR and DKRR
select_m_number = [10, 20, 50, 100, 300, 500];
select_ind_number = select_m_number/5;
training_time_mean = [training_time_mean_batch_ls training_time_mean_batch_fcnet ...
                      training_time_total_mean_krr(:,select_ind_number)];
training_time_std = [training_time_std_batch_ls training_time_std_batch_fcnet ...
                      training_time_total_std_krr(:,select_ind_number)];

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
         'YGrid','on',  ...
         'Xticklabel',{'S+S' 'M+S' 'M+J' 'N+J'});           
set(gca, 'Ylim', [0.001, 30000]);
ylabel('Training time (second)');
legendstr = {'LS-DTR', 'DNN-DTR', 'DKRR-DTR(10)', 'DKRR-DTR(20)', ...
             'DKRR-DTR(50)', 'DKRR-DTR(100)', 'DKRR-DTR(300)', 'DKRR-DTR(500)'};
legend(legendstr, 'NumColumns', 4, 'Location', 'north');
