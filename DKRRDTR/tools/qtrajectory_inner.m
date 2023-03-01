function qtrajectory = qtrajectory_inner(qcell)

qtrajectory.child=cell(0);

% qtrajectory.censored=[];
% qtrajectory.delta=[];
% qtrajectory.l=0;
% name='qtrajectory';
% p=algorithm(name); 
% p.is_data=1;
% qtrajectory= class(qtrajectory,'qtrajectory',p);

qtrajectory.child=qcell;
qtrajectory.l=length(qcell);

