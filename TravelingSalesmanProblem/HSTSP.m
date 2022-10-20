
clc;
clear;
close all;

%% Problem 
x=[13 25 91 86 66 87 50 22 19 3 67 86 52 5 21 65 14 88 70 40];
y=[19 28 37 100 10 32 56 97 47 27 43 39 89 5 79 56 1 21 18 20];

model=MakeModel(x,y);
tic
CostFunction=@(s) CostF(s,model);        % Cost Function
nVar=model.n;             % Number of Decision Variables
VarSize=[1 nVar];         % Decision Variables Matrix Size
VarMin=0;                 % Lower Bound of Variables
VarMax=1;                 % Upper Bound of Variables


%% Harmony Search Parameters

MaxIt = 500;     % Maximum Number of Iterations
HMS = 50;         % Harmony Memory Size

nNew = 15;        % Number of New Harmonies
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

%% Harmony Search Main Loop

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
% Show Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% Damp Fret Width
FW = FW*FW_damp;
% Plot Res
figure(1);
Plotfig(BestSol.Sol.tour,model);
end
toc
time=toc

%% ITR
% figure(1);
% Plotfig(BestSol.Sol.tour,model);

figure;
plot(BestCost,'k', 'LineWidth', 2);
xlabel('ITR');
ylabel('Cost Value');
ax = gca; 
ax.FontSize = 14; 
ax.FontWeight='bold';
set(gca,'Color','c')
grid on;
