
clc;
clear;
close all;
global NFE;
NFE=0;

%% Problem 
I=20; % Tasks
J=6; % Machines
Pmin=10; % Process time  min
Pmax=50; % Process time max
Smin=3; % Setup time min
Smax=9; % Setup time max
model=CreateModel(I,J,Pmin,Pmax,Smin,Smax);        % Create Model of the Problem

CostFunction=@(x) MyCost(x,model);       % Cost Function
nVar=model.nVar;        % Number of Decision Variables
VarSize=[1 nVar];       % Size of Decision Variables Matrix
VarMin = 0;          % Lower Bound of Decision Variables
VarMax = 1;          % Upper Bound of Decision Variables
tic
%% Harmony Search Parameters
MaxIt = 100;     % Maximum Number of Iterations
HMS = 20;         % Harmony Memory Size

nNew = 10;        % Number of New Harmonies
HMCR = 0.9;       % Harmony Memory Consideration Rate
PAR = 0.1;        % Pitch Adjustment Rate
FW = 0.02*(VarMax-VarMin);    % Fret Width (Bandwidth)
FW_damp = 0.995;              % Fret Width Damp Ratio

%% Start
% Empty Harmony Structure
empty_harmony.Position = [];
empty_harmony.Cost = [];
empty_harmony.Sol = [];
% Initialize Harmony Memory
HM = repmat(empty_harmony, HMS, 1);
% Create Initial Harmonies
for i = 1:HMS
HM(i).Position = unifrnd(VarMin, VarMax, VarSize);
[HM(i).Cost HM(i).Sol] = CostFunction(HM(i).Position);
end
% Sort Harmony Memory
[~, SortOrder] = sort([HM.Cost]);
HM = HM(SortOrder);
% Update Best Solution Ever Found
BestSol = HM(1);
% Array to Hold Best Cost Values
BestCost = zeros(MaxIt, 1);

%% Harmony Search Body
for it = 1:MaxIt
% Initialize Array for New Harmonies
NEW = repmat(empty_harmony, nNew, 1);
% Create New Harmonies
for k = 1:nNew
% Create New Harmony Position
NEW(k).Position = unifrnd(VarMin, VarMax, VarSize);
for j = 1:nVar
if rand <= HMCR
% Use Harmony Memory
i = randi([1 HMS]);
NEW(k).Position(j) = HM(i).Position(j);
end
% Pitch Adjustment
if rand <= PAR
%DELTA = FW*unifrnd(-1, +1);    % Uniform
DELTA = FW*randn();            % Gaussian (Normal) 
NEW(k).Position(j) = NEW(k).Position(j)+DELTA;
end
end
% Apply Variable Limits
NEW(k).Position = max(NEW(k).Position, VarMin);
NEW(k).Position = min(NEW(k).Position, VarMax);
% Evaluation
[NEW(k).Cost NEW(k).Sol] = CostFunction(NEW(k).Position);
end
% Merge Harmony Memory and New Harmonies
HM = [HM
NEW]; 
% Sort Harmony Memory
[~, SortOrder] = sort([HM.Cost]);
HM = HM(SortOrder);
% Truncate Extra Harmonies
HM = HM(1:HMS);
% Update Best Solution Ever Found
BestSol = HM(1);
% Store Best Cost Ever Found
BestCost(it) = BestSol.Cost;
% Store NFE
nfe(it)=NFE;

% Iteration 
disp(['In Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Cost is = ' num2str(BestCost(it))]);
% Plot Res
figure(1);
PlotSolution(BestSol.Sol,model);
end

%% Show Results
% figure(1);
% PlotSolution(BestSol.Sol,model);

figure;
plot(BestCost,'k','LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
ax = gca; 
ax.FontSize = 12; 
ax.FontWeight='bold';
grid on;
toc
