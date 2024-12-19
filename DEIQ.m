%% Differential Evolution image color quantization using clustering

clear;
clc;
warning('off');
img=imread('baboon.jpg');
img=im2double(img);
% Separating color channels
R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
% Reshaping each channel into a vector and combine all three channels
X=[R(:) G(:) B(:)];

%% Starting 
k = 5; % Number of Colors (cluster centers)
tic
%---------------------------------------------------
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables

% DE Parameters
MaxIt=50;         % Maximum Iterations
nPop=10;         % Population Size
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
disp(['In Iteration # ' num2str(it) ': Highest Cost IS = ' num2str(BestCost(it))]);    
DECenters=Res(X, BestSol);
end
DElbl=BestSol.Out.ind;

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
Z=DECenters(DElbl',:);
R2=reshape(Z(:,1),size(R));
G2=reshape(Z(:,2),size(G));
B2=reshape(Z(:,3),size(B));
% Attaching color channels 
quantized=zeros(size(img));
quantized(:,:,1)=R2;
quantized(:,:,2)=G2;
quantized(:,:,3)=B2;

% Plot Results 
figure;
subplot(2,2,1);
imshow(img);title('Original');
subplot(2,2,2);
imshow(quantized);title('Quantized Image');
subplot(2,2,3);
[counts3, grayLevels3]=imhist(img,64);
bar(grayLevels3, counts3,'g','BarWidth', 1);
set(gca,'Color','c',FontSize = 15);
subplot(2,2,4);
[counts2, grayLevels2]=imhist(quantized,64);
bar(grayLevels2, counts2,'g','BarWidth', 1);
set(gca,'Color','c',FontSize = 15);

psnrvalue=psnr(img,quantized)
ssimvalue=ssim(img,quantized)
toc
