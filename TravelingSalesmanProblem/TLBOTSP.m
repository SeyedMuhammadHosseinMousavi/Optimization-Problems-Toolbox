
clc;
clear;
close all;

%% Input Model 
% Display uigetfile dialog
filterspec = {'*.csv'};
[f, p] = uigetfile(filterspec);
fileadd=fullfile(p,f);
filecon=load(fileadd);

x=filecon(1,:);
y=filecon(2,:);
xchar=num2str(x);
ychar=num2str(y);

model=MakeModel(x,y);

tic

% Cost
CostFunction=@(s) CostF(s,model);        % Cost Function
nVar=model.n;             % Number of Decision Variables
VarSize=[1 nVar];         % Decision Variables Matrix Size
VarMin=0;                 % Lower Bound of Variables
VarMax=1;                 % Upper Bound of Variables

%% TLBO Parameters
MaxIt = 100;         % Maximum Number of Iterations
nPop = 70;           % Population Size

%% Start 
% Empty Individuals
empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Sol = [];

% Population Array
pop = repmat(empty_individual, nPop, 1);
% Initialize Best Solution
BestSol.Cost = inf;
% Population Members
for i = 1:nPop
pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
[pop(i).Cost pop(i).Sol] = CostFunction(pop(i).Position);
if pop(i).Cost < BestSol.Cost
BestSol = pop(i);
end
end
% Best Cost Record
BestCost = zeros(MaxIt, 1);

%% TLBO 
for it = 1:MaxIt
% Calculate Population Mean
Mean = 0;
for i = 1:nPop
Mean = Mean + pop(i).Position;
end
Mean = Mean/nPop;
% Select Teacher
Teacher = pop(1);
for i = 2:nPop
if pop(i).Cost < Teacher.Cost
Teacher = pop(i);
end
end

% Teacher Phase
for i = 1:nPop
% Create Empty Solution
newsol = empty_individual;
% Teaching Factor
TF = randi([1 2]);
% Teaching (moving towards teacher)
newsol.Position = pop(i).Position ...
+ rand(VarSize).*(Teacher.Position - TF*Mean);
% Clipping
newsol.Position = max(newsol.Position, VarMin);
newsol.Position = min(newsol.Position, VarMax);
% Evaluation
[newsol.Cost newsol.Sol] = CostFunction(newsol.Position);
% Comparision
if newsol.Cost<pop(i).Cost
pop(i) = newsol;
if pop(i).Cost < BestSol.Cost
BestSol = pop(i);
end
end
end

% Learner Phase
for i = 1:nPop
A = 1:nPop;
A(i) = [];
j = A(randi(nPop-1));
Step = pop(i).Position - pop(j).Position;
if pop(j).Cost < pop(i).Cost
Step = -Step;
end
% Create Empty Solution
newsol = empty_individual;
% Teaching (moving towards teacher)
newsol.Position = pop(i).Position + rand(VarSize).*Step;
% Clipping
newsol.Position = max(newsol.Position, VarMin);
newsol.Position = min(newsol.Position, VarMax);
% Evaluation
[newsol.Cost newsol.Sol] = CostFunction(newsol.Position);
% Comparision
if newsol.Cost<pop(i).Cost
pop(i) = newsol;
if pop(i).Cost < BestSol.Cost
BestSol = pop(i);
end
end
end
BestCost(it) = BestSol.Cost;
% Iteration 
disp(['In ITR ' num2str(it) ': TLBO Cost Value Is = ' num2str(BestCost(it))]);

% Plot Res
figure(1);
Plotfig(BestSol.Sol.tour,model);
end

toc
time=toc;

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



