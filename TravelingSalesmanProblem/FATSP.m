
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

%% Firefly Algorithm Parameters

MaxIt = 200;         % Maximum Number of Iterations
nPop = 50;            % Number of Fireflies (Swarm Size)

gamma = 2;            % Light Absorption Coefficient
beta0 = 4;            % Attraction Coefficient Base Value
alpha = 0.2;          % Mutation Coefficient
alpha_damp = 0.98;    % Mutation Coefficient Damping Ratio
delta = 0.05*(VarMax-VarMin);     % Uniform Mutation Range

m = 2;

if isscalar(VarMin) && isscalar(VarMax)
dmax = (VarMax-VarMin)*sqrt(nVar);
else
dmax = norm(VarMax-VarMin);
end

%% Start

% Empty Firefly Structure
firefly.Position = [];
firefly.Cost = [];
firefly.Sol = [];

% Initialize Population Array
pop = repmat(firefly, nPop, 1);

% Initialize Best Solution Ever Found
BestSol.Cost = inf;

% Create Initial Fireflies
for i = 1:nPop
pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
[pop(i).Cost pop(i).Sol] = CostFunction(pop(i).Position);

if pop(i).Cost <= BestSol.Cost
BestSol = pop(i);
end
end

% Array to Hold Best Cost Values
BestCost = zeros(MaxIt, 1);

%% Firefly Algorithm Main Loop

for it = 1:MaxIt

newpop = repmat(firefly, nPop, 1);
for i = 1:nPop
newpop(i).Cost = inf;
for j = 1:nPop
if pop(j).Cost < pop(i).Cost
rij = norm(pop(i).Position-pop(j).Position)/dmax;
beta = beta0*exp(-gamma*rij^m);
e = delta*unifrnd(-1, +1, VarSize);
%e = delta*randn(VarSize);

newsol.Position = pop(i).Position ...
    + beta*rand(VarSize).*(pop(j).Position-pop(i).Position) ...
    + alpha*e;

newsol.Position = max(newsol.Position, VarMin);
newsol.Position = min(newsol.Position, VarMax);

[newsol.Cost newsol.Sol] = CostFunction(newsol.Position);

if newsol.Cost <= newpop(i).Cost
newpop(i) = newsol;
if newpop(i).Cost <= BestSol.Cost
BestSol = newpop(i);
end
end
end
end
end

% Merge
pop = [pop
newpop];  %#ok
% Sort
[~, SortOrder] = sort([pop.Cost]);
pop = pop(SortOrder);
% Truncate
pop = pop(1:nPop);
% Store Best Cost Ever Found
BestCost(it) = BestSol.Cost;
% Show Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% Damp Mutation Coefficient
alpha = alpha*alpha_damp;
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
