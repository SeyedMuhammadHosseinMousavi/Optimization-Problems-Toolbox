function [z sol]=MyCost(x,model)
global NFE;
NFE=NFE+1;
sol=ParseSolution(x,model);
z=sol.Cmax;
end