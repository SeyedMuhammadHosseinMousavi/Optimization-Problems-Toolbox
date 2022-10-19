
clc;
clear;
close all;

%% Problem 
tic
Items = [6 3 4 6 8 7 4 7 7 5 5 6 7 7 6 4 8 7 8 8 2 1 4 9 6];
BinSize = 35;

model = CreateModel(Items,BinSize);  % Create Bin Packing Model

CostFunction = @(x) BinPackingCost(x, model);  % Objective Function

nVar = 2*model.n-1;     % Number of Decision Variables
VarSize = [1 nVar];     % Decision Variables Matrix Size
VarMin = 0;     % Lower Bound of Decision Variables
VarMax = 1;     % Upper Bound of Decision Variables

%% Harmony Search Parameters

MaxIt = 200;     % Maximum Number of Iterations
HMS = 10;         % Harmony Memory Size
nNew = 5;        % Number of New Harmonies

HMCR = 0.9;       % Harmony Memory Consideration Rate
PAR = 0.1;        % Pitch Adjustment Rate
FW = 0.02*(VarMax-VarMin);    % Fret Width (Bandwidth)
FW_damp = 0.995;              % Fret Width Damp Ratio

%% Initialization

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
end

%% Res
figure;
plot(BestCost,'k', 'LineWidth', 2);
xlabel('ITR');
ylabel('Cost Value');
ax = gca; 
ax.FontSize = 14; 
ax.FontWeight='bold';
set(gca,'Color','c')
grid on;

%% Statistics
items=model.v;
itemindex=BestSol.Sol.B;
sizebins=size(itemindex);
for i=1: sizebins(1,1)
itemvalue{i}=items(itemindex{i});
end;
itemvalue=itemvalue';
%
disp(['Number of Items is ' num2str(model.n)]);
disp(['Items are ' num2str(items)]);
disp(['Bins size is ' num2str(model.Vmax)]);
disp(['Selected bins is ' num2str(BestCost(end))]);
disp(['Selected bins indexes are ']);
itemindex
disp(['Selected bins values are ']);
itemvalue
toc


