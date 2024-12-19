function m=PlotRes(X, sol,f1,f2)
% Cluster Centers
m = sol.Position;
k = size(m,1);
% Cluster Indices
ind = sol.Out.ind;
Colors = hsv(k);
for j=1:k
Xj = X(ind==j,:);
plot(Xj(:,f1),Xj(:,f2),'o','MarkerSize',8,'LineWidth',3,'Color',Colors(j,:));
ax = gca; 
ax.FontSize = 12; 
ax.FontWeight='bold';
hold on;
grid on;
end
hold off;
end

