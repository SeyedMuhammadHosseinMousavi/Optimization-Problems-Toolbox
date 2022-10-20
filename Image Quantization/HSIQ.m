
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

%% Harmony Search Parameters

MaxIt = 100;     % Maximum Number of Iterations
HMS = 10;         % Harmony Memory Size
nNew = 10;        % Number of New Harmonies

HMCR = 0.9;       % Harmony Memory Consideration Rate
PAR = 0.1;        % Pitch Adjustment Rate
FW = 0.02*(VarMax-VarMin);    % Fret Width (Bandwidth)
FW_damp = 0.995;              % Fret Width Damp Ratio

%% Initialization

% Empty Harmony Structure
empty_harmony.Position = [];
empty_harmony.Cost = [];
empty_harmony.Out = [];
% Initialize Harmony Memory
HM = repmat(empty_harmony, HMS, 1);
% Create Initial Harmonies
for i = 1:HMS
HM(i).Position = unifrnd(VarMin, VarMax, VarSize);
[HM(i).Cost HM(i).Out] = CostFunction(HM(i).Position);
end
% Sort Harmony Memory
[~, SortOrder] = sort([HM.Cost]);
HM = HM(SortOrder);
% Update Best Solution Ever Found
BestSol = HM(1);
% Array to Hold Best Cost Values
BestCost = zeros(MaxIt, 1);

%% Harmony Search 
for it = 1:MaxIt
% Initialize Array for New Harmonies
NEW = repmat(empty_harmony, nNew, 1);
% Create New Harmonies
for k = 1:nNew
% Create New Harmony Position
NEW(k).Position = unifrnd(VarMin, VarMax, VarSize);
for j = 1:nVar
if rand <= HMCR
% Use Harmony Memory
i = randi([1 HMS]);
NEW(k).Position(j) = HM(i).Position(j);
end
% Pitch Adjustment
if rand <= PAR
% DELTA = FW*unifrnd(-1, +1);    % Uniform
DELTA = FW*randn();            % Gaussian (Normal) 
NEW(k).Position(j) = NEW(k).Position(j);
end
end
% Apply Variable Limits
NEW(k).Position = max(NEW(k).Position, VarMin);
NEW(k).Position = min(NEW(k).Position, VarMax);
% Evaluation
[NEW(k).Cost NEW(k).Out] = CostFunction(NEW(k).Position);
end
% Merge Harmony Memory and New Harmonies
HM = [HM
NEW]; 
% Sort Harmony Memory
[~, SortOrder] = sort([HM.Cost]);
HM = HM(SortOrder);
% Truncate Extra Harmonies
HM = HM(1:HMS);
% Update Best Solution Ever Found
BestSol = HM(1);
% Store Best Cost Ever Found
BestCost(it) = BestSol.Cost;
% BestRes(it)=BestSol.Cost;    
% Show Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% Damp Fret Width
FW = FW*FW_damp;
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
