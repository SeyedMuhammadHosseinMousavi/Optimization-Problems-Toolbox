function [Accuracy, Sensitivity, Fmeasure, Precision, MCC, Dice, Jaccard, Specitivity] = SegPerformanceMetrics(A, B)

% A and B need to be binary images
% A is the ground truth, B is the segmented result.
% MCC - Matthews correlation coefficient
% Note: Sensitivity = Recall
% TP - true positive, FP - false positive, 
% TN - true negative, FN - false negative
% If A, B are binary images, but uint8 (0, 255),
% Need to convert to logical images.

if(isa(A,'logical'))
X = A;
else
X = imbinarize(A);
end
if(isa(B,'logical'))
Y = B;
else
Y = imbinarize(B);
end

% Evaluate TP, TN, FP, FN
sumindex = X + Y;
TP = length(find(sumindex == 2));
TN = length(find(sumindex == 0));
substractindex = X - Y;
FP = length(find(substractindex == -1));
FN = length(find(substractindex == 1));
Accuracy = (TP+TN)/(FN+FP+TP+TN);
Sensitivity = TP/(TP+FN);
Precision = TP/(TP+FP);
Fmeasure = 2*TP/(2*TP+FP+FN);
MCC = (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
Dice = 2*TP/(2*TP+FP+FN);
Jaccard = Dice/(2-Dice);
Specitivity = TN/(TN+FP);

end