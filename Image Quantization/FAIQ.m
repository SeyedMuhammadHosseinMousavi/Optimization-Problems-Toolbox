%% Firefly Algorithm image color quantization using clustering

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
k = 8; % Number of Colors (cluster centers)
tic
%---------------------------------------------------
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables

% Firefly Algorithm Parameters
MaxIt = 50;         % Maximum Number of Iterations
nPop = 10;            % Number of Fireflies (Swarm Size)

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

%% Firefly Algorithm Main Loop
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
BestRes(it)=BestSol.Cost;    
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% Damp Mutation Coefficient
alpha = alpha*alpha_damp;

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
