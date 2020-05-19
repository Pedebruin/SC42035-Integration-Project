function [fit] = analysePerformance(sys, idd_v, simulatedOutput)
y1 = simulatedOutput(:,1);
y2 = simulatedOutput(:,2);

fit1 = goodnessOfFit(y1, idd_v.y(:,1), 'NRMSE');
fit2 = goodnessOfFit(y2, idd_v.y(:,2), 'NRMSE');

fit = [fit1, fit2];
end