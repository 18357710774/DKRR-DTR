% paramaters for generating trajectory samples

function example = clinical_flexstages_params(example)

example.IW = [0.5,1];                % Intervals for wellness
example.IM = 1;                      % Tumor size for stage point
% example.threshold = 1;             % It is needed to move to the next stage if tumor is gearter than the threshhold

if ~isfield(example, 'n')
    example.n = 1000;
end

if ~isfield(example, 'seed')
    example.seed = -1;
end

if ~isfield(example, 'actions')
    example.actions = [0.5, 0.1;     % Constants in the eqations of wellness and tumor size for action A
                       0.25, 0.2];   % Constants in the eqations of wellness and tumor size for action B
                                     % The term in (30) of the paper should be replaced with T(u_i)/(5W(u_i))
end

if ~isfield(example, 'Mdot')
    example.Mdot = 4/3;              % The dynamic for the tumor M(t)=M(0)+M(0)*Mdot*time in equation (31)
end

if ~isfield(example, 'Wdot')
    example.Wdot = 0.5;              % The dynamic for the wellness: W(t)=W(0)+(1-W(0))*(1-2^{-Wdot*time}) in eqaution (31)
end

if ~isfield(example, 'c0')
    example.c0 = 0.15;               % The failure time distributed exp(example.c0*  (W+example.c1)/M
end
if ~isfield(example, 'c1')
    example.c1 = 2;
end

if ~isfield(example, 'max')
    example.max = 3;                 % length of trial
end







% function a = clinical_flexstages_params(num_trajectory, seed) 
% if nargin < 2
%     a.seed = -1;
% else
%     a.seed = seed;
% end
% a.n = num_trajectory;
% 
% a.IW = [0.5,1];                % Intervals for wellness
% a.IM = 1;                      % Tumor size for stage point
% 
% a.actions = [0.5, 0.1;         % Constants in the eqations of wellness and tumor size for action A
%              0.25, 0.2];       % Constants in the eqations of wellness and tumor size for action B
%                                % The term in (30) of the paper should be replaced with T(u_i)/(5W(u_i))
% 
% 
% a.Mdot = 4/3;                  % The dynamic for the tumor M(t)=M(0)+M(0)*Mdot*time in equation (31)
% a.Wdot = 0.5;                  % The dynamic for the wellness: W(t)=W(0)+(1-W(0))*(1-2^{-Wdot*time}) in eqaution (31)
% 
% a.threshold = 1;               % It is needed to move to the next stage if tumor is gearter than the threshhold
% 
% a.c0 = 0.15;                   % The failure time distributed exp(a.c0*  (W+a.c1)/M
% a.c1 = 2;
% 
% a.max = 3;                     % length of trial
% 
