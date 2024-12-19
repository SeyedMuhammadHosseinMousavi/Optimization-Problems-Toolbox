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
k = 2; % Number of Segments
tic
%---------------------------------------------------
CostFunction=@(m) ClusterCost(m, X);     % Cost Function
VarSize=[k size(X,2)];           % Decision Variables Matrix Size
nVar=prod(VarSize);              % Number of Decision Variables
VarMin= repmat(min(X),k,1);      % Lower Bound of Variables
VarMax= repmat(max(X),k,1);      % Upper Bound of Variables

% TLBO Parameters
MaxIt = 10;      % Maximum Number of Iterations
nPop = 20;        % Population Size (Swarm Size)

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
segmented=im2double(segmented);
% Plot Results 
figure;
subplot(1,2,1)
imshow(img,[]);title('Original');
subplot(1,2,2)
imshow(segmented,[]);title('Segmented Image');
%%%%%
forGT=imbinarize(rgb2gray(segmented));
% figure;
% imshow(forGT);
% seg=imbinarize(rgb2gray(segmented));
gt=imread('GT.jpg');
gt=imbinarize(rgb2gray(gt));
% % Statistics
[Accuracy, Sensitivity, Fmeasure, Precision,...
MCC, Dice, Jaccard, Specitivity] = SegPerformanceMetrics(gt, forGT);
disp(['Accuracy is : ' num2str(Accuracy) ]);
disp(['Precision is : ' num2str(Precision) ]);
disp(['Recall or Sensitivity is : ' num2str(Sensitivity) ]);
disp(['F-Score or Fmeasure is : ' num2str(Fmeasure) ]);
disp(['Dice is : ' num2str(Dice) ]);
disp(['Jaccard is : ' num2str(Jaccard) ]);
disp(['Specitivity is : ' num2str(Specitivity) ]);
disp(['MCC is : ' num2str(MCC) ]);
disp(['PSNR is : ' num2str(psnr(im2double((gt)), im2double((forGT)))) ]);
disp(['SSIM is : ' num2str(ssim(im2double((gt)), im2double((forGT)))) ]);
toc
