function [fit] = analysePerformance(sys, idd_v, Sim_data, makeFigure)

% Get the NMSE fit
fit = (1-goodnessOfFit(Sim_data, idd_v.y, 'NRMSE'))'*100;
fit = round(fit,2);


if makeFigure
    % Get the residual analysis (Still in progress)
    figure()
    resid(idd_v, sys);



    % plot power of input signal
    fs = 1;
    y = fft(idd_v.u(:,1));
    n = length(idd_v.u);          % number of samples
    f = (0:n-1)*(fs/n);     % frequency range
    power = abs(y).^2/n;    % power of the DFT

    figure()
    semilogx(f,power)
    xline(1e-3)
    xline(7e-4,'--')
    legend('Power of input signal','BW after estimation','BW initial approximation')
    xlabel('Frequency')
    ylabel('Power')
end
end