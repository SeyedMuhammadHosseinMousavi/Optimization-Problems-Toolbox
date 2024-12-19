function sol=ParseSolution(x,model)

I=model.I;
J=model.J;
p=model.p;
s=model.s;

[~, q]= sort(x);

% Delimiters Position
DelPos=find(q>I);

% Determine Start and End of Machines Job Sequence
From=[0 DelPos]+1;
To=[DelPos I+J]-1;

% Create Jobs List
L=cell(J,1);
for j=1:J
L{j}=q(From(j):To(j));
end

% Time-based Simulation
ST=zeros(I,1);
PT=zeros(I,1);
FT=zeros(I,1);
MCT=zeros(J,1);
for j=1:J
for i=L{j}
k=find(L{j}==i);
if k==1
ST(i)=0;
else
PreviousJob=L{j}(k-1);
ST(i)=FT(PreviousJob)+s(PreviousJob,i,j);
end

PT(i)=p(i,j);

FT(i)=ST(i)+PT(i);
end

if ~isempty(L{j})
MCT(j)=FT(L{j}(end));
end

end

Cmax=max(MCT);

sol.L=L;
sol.ST=ST;
sol.PT=PT; 
sol.FT=FT;
sol.MCT=MCT;
sol.Cmax=Cmax;

end