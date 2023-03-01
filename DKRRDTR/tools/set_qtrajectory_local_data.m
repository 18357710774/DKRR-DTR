function qd_locals = set_qtrajectory_local_data(qd)

num_machines = qd.num_machines;
idx_local = qd.idx_local;
num_stages = qd.infos.stages;

qd_locals = cell(1, num_machines);
for k = 1:num_machines
    qd_local_tmp.infos = qd.infos;
    for i = 1:num_stages
        qd_local_tmp.data{i}.Z = qd.data{i}.Z(idx_local{k},:);
        qd_local_tmp.data{i}.Rpre = qd.data{i}.Rpre(idx_local{k},:);
        qd_local_tmp.data{i}.A = qd.data{i}.A(idx_local{k},:);
        qd_local_tmp.data{i}.U = qd.data{i}.U(idx_local{k},:);
        qd_local_tmp.data{i}.AtRisk = qd.data{i}.AtRisk(idx_local{k},:);
        qd_local_tmp.data{i}.SumU = qd.data{i}.SumU(idx_local{k},:);
        qd_local_tmp.data{i}.X = qd.data{i}.X(idx_local{k},:);
    end
    qd_locals{k} = qd_local_tmp;
    clear qd_local_tmp;
end