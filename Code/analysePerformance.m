function [fit] = analysePerformance(sys, idd_v, Sim)
% get the data that needs to be compared
y1 = Sim(:,1);  % simulated output 1
y2 = Sim(:,2);  % simulated output 2

t1s = idd_v.y(:,1); % measured output 1
t2s = idd_v.y(:,2); % measured output 2

% Get the NMSE fit
fit1 = (1-goodnessOfFit(y1, t1s, 'NRMSE'))*100;
fit2 = (1-goodnessOfFit(y2, t2s, 'NRMSE'))*100;

fit = [round(fit1,2), round(fit2,2)];



% Get the pole-zero plot of the system
% pzmap(sys)


end