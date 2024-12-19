function [z, out] = ClusterCost(m, X)
% Calculate Distance Matrix
d = pdist2(X, m);
% Assign Clusters and Find Closest Distances
[dmin, ind] = min(d, [], 2);
% Sum of Within-Cluster Distance
WCD = sum(dmin);
z=WCD;
out.d=d;
out.dmin=dmin;
out.ind=ind;
out.WCD=WCD;
end