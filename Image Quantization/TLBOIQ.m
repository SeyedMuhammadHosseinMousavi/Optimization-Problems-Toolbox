
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
k = 6; % Number of Colors (cluster centers)
tic
%---------------------------------------------------
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables

% TLBO Parameters
MaxIt = 100;      % Maximum Number of Iterations
nPop = 10;        % Population Size (Swarm Size)

%% Start 

% Empty Individuals
empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Out = [];

% Population Array
pop = repmat(empty_individual, nPop, 1);
% Initialize Best Solution
BestSol.Cost = inf;
% Population Members
for i = 1:nPop
pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
[pop(i).Cost pop(i).Out] = CostFunction(pop(i).Position);
if pop(i).Cost < BestSol.Cost
BestSol = pop(i);
end
end
% Best Cost Record
BestCost = zeros(MaxIt, 1);

%% TLBO Body
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
[newsol.Cost newsol.Out] = CostFunction(newsol.Position);
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
[newsol.Cost newsol.Out] = CostFunction(newsol.Position);
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
disp(['In Iteration ' num2str(it) ': TLBO Cost Is = ' num2str(BestCost(it))]);
FACenters=Res(X, BestSol);
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
Z=FACenters(FAlbl',:);
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
