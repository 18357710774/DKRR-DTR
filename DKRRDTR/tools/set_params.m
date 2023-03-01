function net = set_params(net, opt)

if isfield(opt, 'showWindow')
    net.trainParam.showWindow = opt.showWindow;
end

if isfield(opt, 'MaxEpochs')
    net.trainParam.epochs = opt.MaxEpochs;
end

if isfield(opt, 'lr')
    net.trainParam.lr = opt.lr;
end

if isfield(opt, 'min_grad')
    net.trainParam.min_grad = opt.min_grad;
end

if isfield(opt, 'mu_max')
    net.trainParam.mu_max = opt.mu_max;
end

if isfield(opt, 'net_initFcn')
    net.initFcn = opt.net_initFcn;
end

if isfield(opt, 'layers_initFcn')
    for i = 1:length(net.layers)
        net.layers{i}.initFcn = opt.layers_initFcn;
    end
end
            
if isfield(opt, 'transferFcn')
    net.layers{1}.transferFcn = opt.transferFcn;
    net.layers{2}.transferFcn = 'purelin';
end

if isfield(opt, 'performFcn')
    net.performFcn = opt.performFcn;
end
