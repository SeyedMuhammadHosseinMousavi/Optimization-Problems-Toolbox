
clc;
clear;
close all;

%% Problem 
Items = [6 3 4 6 8 7 4 7 7 5 5 6 7 7 6 4 8 7 8 8 2 1 4 9 6];
BinSize = 35;

model = CreateModel(Items,BinSize);  % Create Bin Packing Model

CostFunction = @(x) BinPackingCost(x, model);  % Objective Function

nVar = 2*model.n-1;     % Number of Decision Variables
VarSize = [1 nVar];     % Decision Variables Matrix Size
VarMin = 0;     % Lower Bound of Decision Variables
VarMax = 1;     % Upper Bound of Decision Variables

%% DE Parameters
tic
MaxIt = 200;      % Maximum Number of Iterations
nPop = 10;        % Population Size

beta_min = 0.2;   % Lower Bound of Scaling Factor
beta_max = 0.8;   % Upper Bound of Scaling Factor
pCR = 0.2;        % Crossover Probability

%% Start

empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Sol = [];
BestSol.Cost = inf;
pop = repmat(empty_individual, nPop, 1);
for i = 1:nPop
pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
[pop(i).Cost pop(i).Sol] = CostFunction(pop(i).Position);
if pop(i).Cost<BestSol.Cost
BestSol = pop(i);
end
end
BestCost = zeros(MaxIt, 1);

%% DE

for it = 1:MaxIt
for i = 1:nPop
x = pop(i).Position;
A = randperm(nPop);
A(A == i) = [];
a = A(1);
b = A(2);
c = A(3);

% Mutation
%beta = unifrnd(beta_min, beta_max);
beta = unifrnd(beta_min, beta_max, VarSize);
y = pop(a).Position+beta.*(pop(b).Position-pop(c).Position);
y = max(y, VarMin);
y = min(y, VarMax);
% Crossover
z = zeros(size(x));
j0 = randi([1 numel(x)]);
for j = 1:numel(x)
if j == j0 || rand <= pCR
z(j) = y(j);
else
z(j) = x(j);
end
end
NewSol.Position = z;
[NewSol.Cost NewSol.Sol]= CostFunction(NewSol.Position);
if NewSol.Cost<pop(i).Cost
pop(i) = NewSol;
if pop(i).Cost<BestSol.Cost
BestSol = pop(i);
end
end
end

% Update Best Cost
BestCost(it) = BestSol.Cost;
% Show Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
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


