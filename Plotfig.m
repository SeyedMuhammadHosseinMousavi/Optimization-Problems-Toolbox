function Plotfig(tour,model)
tour=[tour tour(1)];
x=model.x;
y=model.y;
plot(x(tour),y(tour),'-hr',...
'LineWidth',3,...
'MarkerSize',15,...
'MarkerFaceColor',[0.1 0.9 0.2],...
'MarkerEdgeColor','b');
ax = gca; 
ax.FontSize = 14; 
ax.FontWeight='bold';
set(gca,'Color','w')
grid on;
end