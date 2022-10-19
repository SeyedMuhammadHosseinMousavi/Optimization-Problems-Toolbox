function [z, sol] = BinPackingCost(x, model)
n = model.n;
v = model.v;
Vmax = model.Vmax;
[~, q]=sort(x);
Sep = find(q>n);
From = [0 Sep] + 1;
To = [Sep 2*n] - 1;
B = {};
for i=1:n
Bi = q(From(i):To(i));
if numel(Bi)>0
B = [B; Bi];
end
end
nBin = numel(B);
Viol = zeros(nBin,1);
for i=1:nBin
Vi = sum(v(B{i}));
Viol(i) = max(Vi/Vmax-1, 0);
end
MeanViol = mean(Viol);
alpha = 2*n;
z = nBin + alpha*MeanViol;
sol.nBin = nBin;
sol.B = B;
sol.Viol = Viol;
sol.MeanViol = MeanViol;
end