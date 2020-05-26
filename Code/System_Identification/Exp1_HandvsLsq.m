%Calculations already performed previously. Simply load workspace and make
%plots.
load('../Code/Experiments/StepResponse_H1-60.mat')

hold on;
plot(y1,'r.', 'DisplayName', 'Heater 1 output data');
plot(lsim(sysest,u1,time)+offset, 'g-', 'DisplayName', 'Hand calculations');
plot(lsim(d2c(sys),u1,time)+offset, 'b-', 'DisplayName', 'Least squares');
legend('Location', 'east');
xlabel('Time in [s]');
ylabel('Temperature in [ºC]');