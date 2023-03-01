%% -------------- Initialization-methods --------------------
% WeightsInitializer — Function to initialize weights
% 'glorot' (default) | 'he' | 'orthogonal' | 'narrow-normal' | 'zeros' | 'ones' | function handle
% BiasInitializer — Function to initialize bias
% 'zeros' (default) | 'narrow-normal' | 'ones' | function handle

function modnet = fcnet(d_input, d_output, hidden_neuron_number, act_type, initializer)

if nargin < 4
    initializer = "glorot";
end

switch act_type
    case 'sigmoid'
        activationLayer = sigmoidLayer;
        nameLayer = 'sigmoid';
    case 'relu'
        activationLayer = reluLayer;
        nameLayer = 'relu';
    case 'leakyrelu' 
        activationLayer = leakyReluLayer;
        nameLayer = 'leakyrelu';
    case 'tanh' 
        activationLayer = tanhLayer;
        nameLayer = 'tanh';
    case 'clippedrelu'
        activationLayer = clippedReluLayer;
        nameLayer = 'clippedrelu';
    case 'elu'
        activationLayer = eluLayer;
        nameLayer = 'elu';
    case 'swish'
        activationLayer = swishLayer;
        nameLayer = 'swish';
end

hidden_layers_num = length(hidden_neuron_number);     % number of hidden layers (excluding the input and output layer)
modnet = layerGraph;

activationLayertmp = activationLayer;
activationLayertmp.Name = [nameLayer '_1'];
tmp = [featureInputLayer(d_input, "Name", "featureinput")
       fullyConnectedLayer(hidden_neuron_number(1), "Name", "fc_1", ...
                           "WeightsInitializer", initializer)
       activationLayertmp];
modnet = addLayers(modnet, tmp);

if hidden_layers_num == 1
    i = 1;
else
    for i = 2:hidden_layers_num
        activationLayertmp = activationLayer;
        activationLayertmp.Name = [nameLayer '_' num2str(i)];
        tmp = [fullyConnectedLayer(hidden_neuron_number(i),"Name",['fc_' num2str(i)], ...
                                   "WeightsInitializer", initializer)
               activationLayertmp];
        modnet = addLayers(modnet, tmp);
        modnet = connectLayers(modnet,[nameLayer '_' num2str(i-1)], ['fc_' num2str(i)]);
    end
end
tmp = [fullyConnectedLayer(d_output, "Name", ['fc_' num2str(i+1)], ...
                           "WeightsInitializer", initializer)
       regressionLayer("Name","regressionoutput")];
modnet = addLayers(modnet, tmp);

modnet = connectLayers(modnet,[nameLayer '_' num2str(hidden_layers_num)], ['fc_' num2str(hidden_layers_num+1)]);