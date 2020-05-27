function [fit] = analysePerformance(sys, idd_v, Sim_data)

% Get the NMSE fit
fit = (1-goodnessOfFit(Sim_data, idd_v.y, 'NRMSE'))'*100;
fit = round(fit,2);



% Get the residual analysis (Still in progress)
figure()
resid(idd_v, sys);


%{
% plot power of input signal
y = fft(idd_v.u(:,1));
n = length(idd1.u);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(y).^2/n;    % power of the DFT

figure()
semilogx(f,power)
xline(7e-4)
xlabel('Frequency')
ylabel('Power')
%}



end