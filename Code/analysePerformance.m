function [fit] = analysePerformance(sys, idd_v, Sim_data)

% Get the NMSE fit
fit = (1-goodnessOfFit(Sim_data, idd_v.y, 'NRMSE'))'*100;
fit = round(fit,2);



% Get the residual analysis (Still in progress)
figure()
resid(idd_v, sys);


end