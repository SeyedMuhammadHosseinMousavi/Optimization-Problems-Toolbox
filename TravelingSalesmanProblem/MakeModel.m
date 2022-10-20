function model=MakeModel(x,y)
x=x;
y=y;
n=numel(x);
d=zeros(n,n);
for i=1:n-1
for j=i+1:n
d(i,j)=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
d(j,i)=d(i,j);
end
end
model.n=n;
model.x=x;
model.y=y;
model.d=d;
end