function y=Mutate(x)
n=numel(x);
i=randsample(n,2);
i1=i(1);
i2=i(2);
y=x;
y([i1 i2])=x([i2 i1]);
end
