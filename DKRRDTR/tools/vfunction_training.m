function [qfunctions, ret_maxQi_plus_one, time_cost] = vfunction_training(qt, opt)

trajectory_length = qt.infos.stages;
qtdata = qt.data;

qfi.size_of_action_space = qt.infos.size_of_action_space;
qfi.action_mode = opt.action_mode;
qfi.name = opt.algoname;
if isfield(opt, 'algoparams')
    qfi.params = opt.algoparams;
end

qfunctions = cell(1,trajectory_length);
ret_maxQi_plus_one = cell(1,trajectory_length);
time_cost = zeros(1, trajectory_length);
for i = trajectory_length:-1:1
    % train the qfunction backwards
    if i == trajectory_length
        [maxQi_plus_one, qfi, time_cost(i)] = qfunction_training(qfi, qtdata{i});
    else
        qti_i_plus_one = {qtdata{i}, maxQi_plus_one};
        [maxQi_plus_one, qfi, time_cost(i)] = qfunction_training(qfi, qti_i_plus_one);
    end
    qfunctions{i} = qfi;
    ret_maxQi_plus_one{i} = maxQi_plus_one;
    qfi = rmfield(qfi, 'algos');
end
