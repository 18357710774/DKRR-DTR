function [Wa, Ma, R, mu] =  status_computation(W, example, A)

Wa = (W-example.actions(1,1)).*(A==1) + ...     % if treatment A, W(u_i^+|A) = W(u_i) - 0.5
     (W-example.actions(2,1)).*(A==2);          % if treatment B, W(u_i^+|B) = W(u_i) - 0.25
Wa = max(Wa, 0);

Ma = (example.actions(1,2)./W).*(A==1) + ...    % if treatment A, T(u_i^+|A) = T(u_i) * 0.1 / W(u_i), where T(u_i)=1
     (example.actions(2,2)./W).*(A==2);         % if treatment B, T(u_i^+|B) = T(u_i) * 0.2 / W(u_i), where T(u_i)=1
Ma = min(Ma, 1);

R = (1/example.Mdot)*(1-Ma)./Ma;                % Let T(u) = T(u_i^+) + 4*T(u_i^+)(u-u_i)/3 = 1 
                                                %      ==> u-u_i = (1-T(u_i^+)) * (3/4) / T(u_i^+)
mu = example.c0*(Wa+example.c1)./Ma;            % Model the survival function of the patient as an exponential 
                                                % distribution with mean (3/20) * (W(u_i^+)+2) / T(u_i^+)