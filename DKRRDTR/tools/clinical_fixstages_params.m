% paramaters for generating trajectory samples

function example = clinical_fixstages_params(example)

if ~isfield(example, 'n')
    example.n = 1000;
end

if ~isfield(example, 'seed')
    example.seed = -1;
end

if ~isfield(example, 'states')
    example.states =  [0.1, 1.2, 0.5;    % Constants in the eqations of wellness and tumor size
                       0.15, 1.2, 0.5];   
end

if ~isfield(example, 'mu')
    example.mu = [0, 1, 1];              % The cofficients in the hazard function \lambda(t)
end

if ~isfield(example, 'c0')
    example.c0 = 0.5;                    % The threshold in reward function
end

if ~isfield(example, 'IW')
    example.IW = [0, 2];                 % The endpoints of the interval for initial wellness
end

if ~isfield(example, 'IM')
    example.IM = [0, 2];                 % The endpoints of the interval for initial tumor size
end

if ~isfield(example, 'actions1')
    example.actions1 = [0.5, 1];         % The endpoints of the interval for drug level at stage 1
end

if ~isfield(example, 'actions2')
    example.actions2 = [0, 1];           % The endpoints of the interval for drug level at stage k (k>1)
end

if ~isfield(example, 'increment')
    example.increment = 0.01;            % The increments of discrete doge levels
end

if ~isfield(example, 'death_r')
    example.death_r = -6;               % The reward for death
end

if ~isfield(example, 'cure_r')
    example.cure_r = 1.5;                 % The reward for cured patient
end

if ~isfield(example, 'other_r')
    example.other_r = 0.5;                 % The reward for other results   
end
