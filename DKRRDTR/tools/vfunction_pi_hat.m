function actions =  vfunction_pi_hat(qfunction, X)
actions = qfunction_testing(qfunction, X);

if(sum(actions==0)>0 && ~isempty(qfunctions{1}))
    ind_actions0 = find(actions==0);
    actions(ind_actions0)=unidrnd(qfunctions{1}.size_of_action_space,length(ind_actions0),1);
end