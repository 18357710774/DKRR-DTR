function qd_true = merge_drug_qtrajectory_data(qd_cell)

[m, n] = size(qd_cell);
qd_true = cell(1, n);
for k = 1:n
    Ntmp = cell(m, 1);
    Ttmp = cell(m, 1);
    Itmp = cell(m, 1);
    Btmp = cell(m, 1);
    Atmp = cell(m, 1);
    Utmp = cell(m, 1);
    Xtmp = cell(m, 1);
    for j = 1:m
        Ntmp{j} = qd_cell{j,k}.N;
        Ttmp{j} = qd_cell{j,k}.T;
        Itmp{j} = qd_cell{j,k}.I;
        Btmp{j} = qd_cell{j,k}.B;
        Atmp{j} = qd_cell{j,k}.A;
        Utmp{j} = qd_cell{j,k}.U;
        Xtmp{j} = qd_cell{j,k}.X;
    end
    qd_true{k}.N = cell2mat(Ntmp);
    qd_true{k}.T = cell2mat(Ttmp);
    qd_true{k}.I = cell2mat(Itmp);
    qd_true{k}.B = cell2mat(Btmp);
    qd_true{k}.A = cell2mat(Atmp);
    qd_true{k}.U = cell2mat(Utmp);
    qd_true{k}.X = cell2mat(Xtmp);
end
