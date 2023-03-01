% paramaters for generating trajectory samples

function example = drug_manystages_params(example)

if ~isfield(example, 'n')
    example.n = 1000;
end

if ~isfield(example, 'seed')
    example.seed = -1;
end

if ~isfield(example, 'N0')
    example.N0 = 1;                            % The initial condition of the normal cell population
end

if ~isfield(example, 'T0')
    example.T0 = 0.2;                          % The initial condition of the tumor cell population
end

if ~isfield(example, 'I0')
    example.I0 = 0.15;                         % The initial condition of the immune cell population
end

if ~isfield(example, 'B0')
    example.B0 = 0;                            % The initial drug concentration
end

if ~isfield(example, 'a')
    example.a = [0.2, 0.3, 0.1];               % The cofficients for death of immune cell, tumor cell and normal cell due to medicine toxicity
end

if ~isfield(example, 'b')
    example.b = [1.0, 1.0];                    % The reciprocal carrying capacity for tumor cell and normal cell in the logistic growth law
end

if ~isfield(example, 'c')
    example.c = [1.0, 0.5, 1.0, 1.0];          % The cofficients for death due to other cells
end

if ~isfield(example, 'd')
    example.d = [0.2, 1.0];                    % The cofficient for death of immune cell due to immune cell, and the cofficient for decay of drug concentration
end

if ~isfield(example, 'r')
    example.r = [1.5, 1.0];                    % The growth rate for tumor cell and normal cell in the logistic growth law
end

if ~isfield(example, 'alpha')
    example.alpha = 0.3;               
end

if ~isfield(example, 'rho')
    example.rho = 0.01;              
end

if ~isfield(example, 's')
    example.s = 0.33;              
end

if ~isfield(example, 'deltaT')
    example.deltaT = 0.25;                      % Sampling time (deltaT day) for discretization of ODE model 
end

if ~isfield(example, 'days')
    example.days = 150;                         % Observing time (day)         
end