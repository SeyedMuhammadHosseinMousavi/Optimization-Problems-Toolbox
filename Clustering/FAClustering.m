clear;
warning('off');
% Loading
X = load("iris.csv");
%
k = 3; % Number of Clusters
%
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables
tic
%% Firefly Algorithm Parameters
MaxIt = 100;         % Maximum Number of Iterations
nPop = 30;            % Number of Fireflies (Swarm Size)

gamma = 1;            % Light Absorption Coefficient
beta0 = 2;            % Attraction Coefficient Base Value
alpha = 0.2;          % Mutation Coefficient
alpha_damp = 0.98;    % Mutation Coefficient Damping Ratio
delta = 0.05*(VarMax-VarMin);     % Uniform Mutation Range
m = 2;
if isscalar(VarMin) && isscalar(VarMax)
dmax = (VarMax-VarMin)*sqrt(nVar);
else
dmax = norm(VarMax-VarMin);
end

% Start
% Empty Firefly Structure
firefly.Position = [];
firefly.Cost = [];
firefly.Out = [];

% Initialize Population Array
pop = repmat(firefly, nPop, 1);
% Initialize Best Solution Ever Found
BestSol.Cost = inf;
% Create Initial Fireflies
for i = 1:nPop
pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
[pop(i).Cost, pop(i).Out] = CostFunction(pop(i).Position);
if pop(i).Cost <= BestSol.Cost
BestSol = pop(i);
end
end
% Array to Hold Best Cost Values
BestCost = zeros(MaxIt, 1);

%% Firefly Algorithm Body
for it = 1:MaxIt
newpop = repmat(firefly, nPop, 1);
for i = 1:nPop
newpop(i).Cost = inf;
for j = 1:nPop
if pop(j).Cost < pop(i).Cost
rij = norm(pop(i).Position-pop(j).Position)/dmax;
beta = beta0.*exp(-gamma.*rij^m);
e = delta.*unifrnd(-1, +1, VarSize);
%e = delta*randn(VarSize);
newsol.Position = pop(i).Position ...
+ beta.*rand(VarSize).*(pop(j).Position-pop(i).Position) ...
+ alpha.*e;
newsol.Position = max(newsol.Position, VarMin);
newsol.Position = min(newsol.Position, VarMax);
[newsol.Cost newsol.Out] = CostFunction(newsol.Position);
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
newpop];  
% Sort
[~, SortOrder] = sort([pop.Cost]);
pop = pop(SortOrder);
% Truncate
pop = pop(1:nPop);
% Store Best Cost Ever Found
BestCost(it) = BestSol.Cost;
disp(['In Iteration ' num2str(it) ': FA Cost Is= ' num2str(BestCost(it))]);
% Damp Mutation Coefficient
alpha = alpha*alpha_damp;
end

% Features
f1=1;
f2=3;
figure(1);
PlotRes(X, BestSol,f1,f2);
% ITR
figure;
plot(BestCost,'k','LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
ax = gca; 
ax.FontSize = 12; 
ax.FontWeight='bold';
grid on;
toc