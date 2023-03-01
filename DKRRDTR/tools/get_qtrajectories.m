function [S, A, U, delta, atRisk] = get_qtrajectories(q)  
  
S = [];
A = [];
U = [];
delta = [];
atRisk = [];
qdata = q.data;

for i = 1:length(qdata)
    
    [Si,Ai,Ui,deltai,atRiski] = get_qtrajectory_data(qdata{i});
    S = [S, Si];
    A = [A, Ai];
    U = [U, Ui];
    delta = [delta, deltai];
    atRisk = [atRisk, atRiski];
end