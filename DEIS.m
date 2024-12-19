clear;
clc;
warning('off');
% Loading
img=imread('m.jpg');
img=im2double(img);
gray=rgb2gray(img);
gray=imadjust(gray);
% Reshaping image to vector
X=gray(:);

%% Starting 
k = 4; % Number of segments
tic
%---------------------------------------------------
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables


% DE Parameters
MaxIt=100;         % Maximum Iterations
nPop=4;         % Population Size
%
beta_min=0.2;   % Lower Bound of Scaling Factor
beta_max=0.8;   % Upper Bound of Scaling Factor
pCR=0.2;        % Crossover Probability

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
b=A(1);
c=A(1);       
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
disp(['In Iteration # ' num2str(it) ': Highest Cost IS = ' num2str(BestCost(it))]);    
% DECenters=Res(X, BestSol);
end
FAlbl=BestSol.Out.ind;

% Plot 
% figure('Renderer', 'painters', 'Position', [50 50 250 250])
plot(BestCost,'k','LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
ax = gca; 
ax.FontSize = 12; 
ax.FontWeight='bold';
grid on;

%% Converting cluster centers and its indexes into image 
gray2=reshape(FAlbl(:,1),size(gray));
segmented = label2rgb(gray2); 
% Plot Results 
figure;
subplot(1,2,1)
imshow(img,[]);title('Original');
subplot(1,2,2)
imshow(segmented,[]);title('Segmented Image');
toc

