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
k = 4; % Number of Segments
tic
%---------------------------------------------------
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables

%% Harmony Search Parameters

MaxIt = 40;     % Maximum Number of Iterations
HMS = 4;         % Harmony Memory Size

nNew = 2;        % Number of New Harmonies
HMCR = 0.9;       % Harmony Memory Consideration Rate
PAR = 0.1;        % Pitch Adjustment Rate
FW = 0.02*(VarMax-VarMin);    % Fret Width (Bandwidth)
FW_damp = 0.995;              % Fret Width Damp Ratio

%% Start

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
BestRes(it)=BestSol.Cost;    
% Show Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% Damp Fret Width
FW = FW*FW_damp;
% FACenters=Res(X, BestSol);
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
