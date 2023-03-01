function [vf, ret_maxQi_plus_one, time_cost] = distributed_cancer_vfunction_training(qt, opt)

trajectory_length = qt.infos.stages;
qtdata = qt.data;
info_split.idx_local = qt.idx_local;
info_split.Nr = qt.Nr;

qfi.action_mode = opt.action_mode;
qfi.name = opt.algoname;
if isfield(opt, 'algoparams')
    qfi.params = opt.algoparams;
end

qfunctions = cell(1,trajectory_length);
ret_maxQi_plus_one = cell(1,trajectory_length);
time_cost = struct('time_local', {}, 'time_synthesize',{});
for i = trajectory_length:-1:1
    % train the qfunction backwards
    if i == trajectory_length
        [maxQi_plus_one, qfi, time_cost(i)] = distributed_cancer_qfunction_training(qfi, qtdata{i}, info_split);
    else
        qti_i_plus_one = {qtdata{i}, maxQi_plus_one};
        [maxQi_plus_one, qfi, time_cost(i)] = distributed_cancer_qfunction_training(qfi, qti_i_plus_one, info_split);
    end
    qfunctions{i} = qfi;
    ret_maxQi_plus_one{i} = maxQi_plus_one;
    qfi = rmfield(qfi, 'algos');
end

vf.qfunctions = qfunctions;
vf.info_split = info_split;
