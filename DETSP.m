
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


%% DE Parameters

MaxIt = 500;      % Maximum Number of Iterations
nPop = 50;        % Population Size

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

%% DE Body

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
% Plot Res
figure(1);
Plotfig(BestSol.Sol.tour,model);
end

toc
time=toc
%% ITR

% figure;
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
