
%% Starting DE Clustering
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

% DE Parameters
MaxIt=100;       % Maximum Iterations
nPop=30;         % Population Size
%
beta_min=0.2;   % Lower Bound of Scaling Factor
beta_max=0.8;   % Upper Bound of Scaling Factor
pCR=0.2;        % Crossover Probability
tic
% Start
empty_individual.Position=[];
empty_individual.Cost=[];
empty_individual.Out=[];
BestSol.Cost=inf;
pop=repmat(empty_individual,nPop,1);
for i=1:nPop
pop(i).Position=unifrnd(VarMin,VarMax,VarSize);  
[pop(i).Cost, pop(i).Out]=CostFunction(pop(i).Position);  
if pop(i).Cost<BestSol.Cost
BestSol=pop(i);
end 
end
BestRes=zeros(MaxIt,1);

% DE Body
for it=1:MaxIt
for i=1:nPop        
x=pop(i).Position;        
A=randperm(nPop);        
A(A==i)=[];        
a=A(1);
b=A(2);
c=A(3);       
% Mutation
beta=unifrnd(beta_min,beta_max,VarSize);
y=pop(a).Position+beta.*(pop(b).Position-pop(c).Position);
y=max(y,VarMin);
y=min(y,VarMax);        
% Crossover
z=zeros(size(x));
j0=randi([1 numel(x)]);
for j=1:numel(x)
if j==j0 || rand<=pCR
z(j)=y(j);
else
z(j)=x(j);
end
end        
NewSol.Position=z;
[NewSol.Cost, NewSol.Out]=CostFunction(NewSol.Position);       
if NewSol.Cost<pop(i).Cost
pop(i)=NewSol;           
if pop(i).Cost<BestSol.Cost
BestSol=pop(i);
end
end
end    
% Update Best Cost
BestCost(it)=BestSol.Cost;    
% Iteration 
disp(['In Iteration' num2str(it) ':  DE Cost Is = ' num2str(BestCost(it))]);    
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