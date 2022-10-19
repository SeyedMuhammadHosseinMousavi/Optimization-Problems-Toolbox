
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


%% Firefly Algorithm Parameters

MaxIt=200;         % Maximum Number of Iterations
nPop=10;            % Number of Fireflies (Swarm Size)

gamma=1;            % Light Absorption Coefficient
beta0=2;            % Attraction Coefficient Base Value
alpha=0.2;          % Mutation Coefficient
alpha_damp=0.98;    % Mutation Coefficient Damping Ratio
delta=0.05*(VarMax-VarMin);     % Uniform Mutation Range
m=2;

if isscalar(VarMin) && isscalar(VarMax)
dmax = (VarMax-VarMin)*sqrt(nVar);
else
dmax = norm(VarMax-VarMin);
end

nMutation = 3;      % Number of Additional Mutation Operations

%% Start

% Empty Firefly Structure
firefly.Position=[];
firefly.Cost=[];
firefly.Sol=[];
% Initialize Population Array
pop=repmat(firefly,nPop,1);
% Initialize Best Solution Ever Found
BestSol.Cost=inf;
% Create Initial Fireflies
for i=1:nPop
pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
[pop(i).Cost, pop(i).Sol]=CostFunction(pop(i).Position);
if pop(i).Cost<=BestSol.Cost
BestSol=pop(i);
end
end
% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

%% Firefly Algorithm Body

for it=1:MaxIt
newpop=repmat(firefly,nPop,1);
for i=1:nPop
newpop(i).Cost = inf;
for j=1:nPop
if pop(j).Cost < pop(i).Cost || i==j
rij=norm(pop(i).Position-pop(j).Position)/dmax;
beta=beta0*exp(-gamma*rij^m);
e=delta*unifrnd(-1,+1,VarSize);
%e=delta*randn(VarSize);
newsol.Position = pop(i).Position ...
    + beta*rand(VarSize).*(pop(j).Position-pop(i).Position) ...
    + alpha*e;
newsol.Position=max(newsol.Position,VarMin);
newsol.Position=min(newsol.Position,VarMax);
[newsol.Cost, newsol.Sol]=CostFunction(newsol.Position);
if newsol.Cost <= newpop(i).Cost
newpop(i) = newsol;
if newpop(i).Cost<=BestSol.Cost
BestSol=newpop(i);
end
end
end
end

% Perform Mutation
for k=1:nMutation
newsol.Position = Mutate(pop(i).Position);
[newsol.Cost, newsol.Sol]=CostFunction(newsol.Position);
if newsol.Cost <= newpop(i).Cost
newpop(i) = newsol;
if newpop(i).Cost<=BestSol.Cost
BestSol=newpop(i);
end
end
end
end

% Merge
pop=[pop
newpop]; 
% Sort
[~, SortOrder]=sort([pop.Cost]);
pop=pop(SortOrder);
% Truncate
pop=pop(1:nPop);
% Store Best Cost Ever Found
BestCost(it)=BestSol.Cost;
% Show Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% Damp Mutation Coefficient
alpha = alpha*alpha_damp;
end

%% Results

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


