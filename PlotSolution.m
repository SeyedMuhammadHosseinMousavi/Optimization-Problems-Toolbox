function PlotSolution(sol,model)
I=model.I;
J=model.J;
L=sol.L;
ST=sol.ST;
FT=sol.FT;

H=1;
h=0.75;

for j=1:J
y1=(j-1)*H;
y2=y1+h;
for i=L{j}

x1=ST(i);
x2=FT(i);

X=[x1 x2 x2 x1];
Y=[y1 y1 y2 y2];

C='green';

fill(X,Y,C);
hold on;

xm=(x1+x2)/2;
ym=(y1+y2)/2;
text(xm,ym,num2str(i),...
'FontWeight','bold',...
'HorizontalAlignment','center',...
'VerticalAlignment','middle');
end
end

Cmax=sol.Cmax;
plot([Cmax Cmax],[0 J*H],'y','LineWidth',3);
text(Cmax,J*H,['C-Max = ' num2str(Cmax)],...
'FontWeight','bold',...
'HorizontalAlignment','right',...
'VerticalAlignment','top',...
'Color','blue');
title('Parallel Machine Scheduling','FontSize', 15,'FontWeight','bold');
xlabel(' Tasks','FontSize', 15,'FontWeight','bold');
ylabel(' Machines','FontSize', 15,'FontWeight','bold');
ax = gca; 
ax.FontSize = 12; 
ax.FontWeight='bold';
grid on;
hold off;
end