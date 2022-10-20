function m=Res(X, sol)
% Cluster Centers
m = sol.Position;
k = size(m,1);
% Cluster Indices
ind = sol.Out.ind;    
Colors = hsv(k);
for j=1:k
Xj = X(ind==j,:);
end  
end