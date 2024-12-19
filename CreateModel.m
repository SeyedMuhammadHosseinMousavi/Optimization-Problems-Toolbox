function model=CreateModel(I,J,Pmin,Pmax,Smin,Smax)

% I Tasks
% J Machines
% p Process time 
% S setup time
% Cmax Maximum machine completion time is 

I=I; % Tasks
J=J; % Machines
Pmin=Pmin;
Pmax=Pmax;
p=randi([Pmin Pmax],I,J); % Process time 
I=size(p,1);
J=size(p,2);
% S is setup time 
Smin=Smin;
Smax=Smax;
for i=1:J
s(:,:,i)=randi([Smin Smax],I,I);
end;

model.I=I;
model.J=J;
model.p=p;
model.s=s;
model.nVar=I+J-1;
end








