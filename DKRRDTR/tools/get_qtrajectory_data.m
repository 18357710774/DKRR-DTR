function [retX, retU, retA, retAtRisk, retCured, retDeath, retActionSpace, retZ, retSumU, retRpre] = get_qtrajectory_data(d)
 
% Return the qdata entries
% RetZ are the covariates
% RetA are actions
% RetU is the time spent at this stage
% retDelta is if 1 no censoring occur up to and include this stage
% retAtRisk is 1 if no censoring or failure event happend up to this stage
% retSumU is the time spent up to and include this stage

if isfield(d, 'Z')
    retZ = d.Z;
else
    retZ = [];
end

if isfield(d, 'Rpre')
    retRpre = d.Rpre;
else
    retRpre = [];
end

if isfield(d, 'A')
    retA = d.A;
else
    retA = [];
end

if isfield(d, 'X')
    retX = d.X;
else
    retX = [];
end

if isfield(d, 'U')
    retU = d.U;
else
    retU = [];
end

if isfield(d, 'AtRisk')
    retAtRisk = d.AtRisk;
else
    retAtRisk = [];
end

if isfield(d, 'Cured')
    retCured = d.Cured;
else
    retCured = [];
end

if isfield(d, 'Death')
    retDeath = d.Death;
else
    retDeath = [];
end

if isfield(d, 'action_space')
    retActionSpace = d.action_space;
else
    retActionSpace = [];
end

if isfield(d, 'SumU')
    retSumU = d.SumU;
else
    retSumU = [];
end