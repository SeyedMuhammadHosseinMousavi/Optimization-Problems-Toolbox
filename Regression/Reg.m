% warning('off');

clear;
% Data=load("Data.csv");
% Inputs=Data(:,1:end-1);
% Targets=Data(:,end);
%% Input Model 
% Display uigetfile dialog
filterspec = {'*.csv'};
[f, p] = uigetfile(filterspec);
fileadd=fullfile(p,f);
filecon=load(fileadd);
Inputs=filecon(:,1:end-1);
Targets=filecon(:,end);

%% Learning 

n = 9; % Neurons

%----------------------------------------
% 'trainlm'	    Levenberg-Marquardt
% 'trainbr' 	Bayesian Regularization (good)
% 'trainrp'  	Resilient Backpropagation
% 'traincgf'	Fletcher-Powell Conjugate Gradient
% 'trainoss'	One Step Secant (good)
% 'traingd' 	Gradient Descent
% Creating the NN ----------------------------
net = feedforwardnet(n,'trainoss');

%---------------------------------------------
% configure the neural network for this dataset
[net tr]= train(net,Inputs', Targets');

perf = perform(net,Inputs, Targets); % mse
% Current NN Weights and Bias
Weights_Bias = getwb(net);
% MSE Error for Current NN
Outputs=net(Inputs');
Outputs=Outputs';
% Final MSE Error and Correlation Coefficients (CC)
Err_MSE=mse(Targets,Outputs);
CC1= corrcoef(Targets,Outputs);
CC1= CC1(1,2);

%-----------------------------------------------------
%% Nature Inspired Regression
% Create Handle for Error
h = @(x) MSEHandle(x, net, Inputs', Targets');
tic
sizenn=size(Inputs);sizenn=sizenn(1,1);
%-----------------------------------------
%% Please select
MaxIt = 5;       % Maximum Number of Iterations
nPop = 5;        % Population Size 

[x,err,BestCost] = hs(h, sizenn*n+n+n+1,MaxIt,nPop);

% Plot ITR
% figure;
plot(BestCost,'k', 'LineWidth', 2);
xlabel('ITR');
ylabel('Cost Value');
ax = gca; 
ax.FontSize = 14; 
ax.FontWeight='bold';
set(gca,'Color','c')
grid on;

%%-------------------------------------------------------------------------
net = setwb(net, x');
% Optimized NN Weights and Bias
getwb(net);
% Error for Optimized NN
Outputs2=net(Inputs');
Outputs2=Outputs2';
% Final MSE Error and Correlation Coefficients (CC)
Err_MSE2=mse(Targets,Outputs2);
CC2= corrcoef(Targets,Outputs2);
CC2= CC2(1,2);

%% Plot Regression
f = figure;  
f.Position = [100 100 700 550]; 
% Metaheuristics
subplot(3,1,1)
[population3,gof3] = fit(Targets,Outputs2,'poly3');
plot(Targets,Outputs2,'o',...
'LineWidth',1,...
'MarkerSize',8,...
'MarkerEdgeColor','g',...
'MarkerFaceColor',[0.9,0.3,0.1]);
title(['R =  ' num2str(1-gof3.rmse)],['MSE =  ' num2str(Err_MSE2)]); 
hold on
plot(population3,'b-','predobs');
xlabel('Targets');ylabel('Outputs');   grid on;
ax = gca; 
ax.FontSize = 12; ax.LineWidth=2;
% legend({'Regression'},'FontSize',12,'TextColor','blue');hold off
subplot(3,1,2)
% Error
Errors=Targets-Outputs2;
ErrorMean=mean(Errors);
ErrorStd=std(Errors);
subplot(3,1,2);
plot(Targets,'m');hold on;
plot(Outputs2,'k');legend('Target','Output');
title('Training Part');xlabel('Sample Index');grid on;
subplot(3,1,3);
h=histfit(Errors, 50);
h(1).FaceColor = [.3 .8 0.3];
title(['Train Error Mean =    ' num2str(ErrorMean) '   ,' ...
    '   Train Error STD =    ' num2str(ErrorStd)]);grid on;

% Correlation Coefficients
% fprintf('Normal Correlation Coefficients Is =  %0.4f.\n',CC1);
fprintf('New Correlation Coefficients Is =  %0.4f.\n',CC2);
toc
