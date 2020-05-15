function [fit] = analysePerformance(sys, Input_v, measuredOutput_v, simulatedOutput)
h1s = Input_v(:,1);
h2s = Input_v(:,2);
t1s = measuredOutput_v(:,1);
t2s = measuredOutput_v(:,2);

y1 = simulatedOutput(:,1);
y2 = simulatedOutput(:,2);




fit1 = goodnessOfFit(y1, t1s, 'NRMSE');
fit2 = goodnessOfFit(y2, t2s, 'NRMSE');

fit = [fit1, fit2];
end