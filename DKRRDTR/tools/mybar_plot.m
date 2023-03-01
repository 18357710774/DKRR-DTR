function GO = mybar_plot(val_mean_fixedpolicy, val_std_fixedpolicy, m_val_mean, m_val_std)
% 图片尺寸设置（单位：厘米）
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = 12;

% 窗口设置
figure;
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]); 
hold on;

% plot the results of fixed treatments
% 颜色设置
RGB = cbrewer('seq', 'Blues', 15, 'linear');
RGB = RGB(6:15,:);
errorbarcolor = brewermap(9, "Greys");
% 绘制柱图
x1 = 0.25:0.25:2.5;
y1 = val_mean_fixedpolicy; 
[~, indsort] = sort(y1, 'ascend');
neg1 = val_std_fixedpolicy;
pos1 = val_std_fixedpolicy;
Go = bar(x1, y1, 0.85);
% 单独设置第i个组第j个柱子的颜色
Go.FaceColor = 'flat';
Go.EdgeColor = 'black';
for i = 1:10
    Go.CData(indsort(i),:) = RGB(i,:);
end
% 获取误差线 x 坐标值
xx1 = Go.XEndPoints;
% 绘制误差线
hold on
errorbar(xx1, y1, neg1, pos1, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);

% plot the results of LS-DTR, DNN-DTR and KRR-DTR
% 颜色设置
RGB1 = cbrewer('seq', 'Purples', 12, 'linear');
RGB2 = cbrewer('seq', 'Greens', 12, 'linear');
RGB3 = cbrewer('seq', 'Reds', 12, 'linear');
RGB1  = RGB1([5,8],:);
RGB2  = RGB2([5,8],:);
RGB3  = RGB3([5,8],:);
RGB = cat(3,RGB1,RGB2,RGB3);
errorbarcolor = brewermap(9, "Greys");

% 绘制柱图
y = m_val_mean; 
neg = m_val_std;
pos = m_val_std;
m = size(y,1);
n = size(y,2);
x = (1:m) + 2.35;
GO = bar(x, y, 0.9);     

% 单独设置第i个组第j个柱子的颜色
for i = 1 : m
    for j = 1 : n
        GO(1, j).FaceColor = 'flat';
        GO(1, j).CData(i,:) = squeeze(RGB(i,:,j));
        GO(1,j).EdgeColor = 'black';
    end
end

% 获取误差线 x 坐标值
xx = zeros(m, n);
for i = 1 : n
    xx(:, i) = GO(1, i).XEndPoints';
end
% 绘制误差线
hold on
errorbar(xx, y, neg, pos, 'LineStyle', 'none', 'Color', errorbarcolor(9,:), 'LineWidth', 1);
hold off

set(gca, 'FontSize',12, 'box', 'on', ...
         'XGrid', 'off', 'YGrid', 'on', ...                              % 网格
         'XTick', [0.25:0.25:2.5 3.35:1:4.35], ...
         'XTickLabelRotation', 45, ...
         'Xticklabel',{'0.1', '0.2', '0.3', '0.4', '0.5', ...
                       '0.6', '0.7', '0.8', '0.9', '1.0', ...
                       'M+J', 'N+J'});                                   % X坐标轴刻度标签