
function makefigure(ydata,method, tdata, measuredInput, measuredOutput,fit)
%{
This function plots the simulation in ydata for both heaters against the
output data measured from the lab in t1s and t2s. 

ydata: simulation data to be plotted
method: the method used for this data
h1s, h2s: input data for both heaters
t1s, t2s: output data for both heaters
file: file that was used for identification
%}

ydata1 = ydata(:,1);
ydata2 = ydata(:,2);

h1s = measuredInput(:,1)';
h2s = measuredInput(:,2)';
t1s = measuredOutput(:,1)';
t2s = measuredOutput(:,2)';



% ---- Figure setup: ----
fig = figure('Name',method); 
sgtitle(['Method: ',method], 'Interpreter','latex');
ax11 = subplot(2,2,1);
ax12 = subplot(2,2,2);
ax21 = subplot(2,2,3);
ax22 = subplot(2,2,4);
hold(ax11, "on");
hold(ax12, "on");
hold(ax21, "on");
hold(ax22, "on");

% ---- Plots: ----
title(ax11,['Output Heater 1',num2str(fit(1))])
plot(ax11,tdata,ydata1, 'DisplayName', method)
plot(ax11,tdata,t1s, 'DisplayName', 'Data')
ylim(ax11,[0 45])
xlabel(ax11,"Time in [s]")
ylabel(ax11,"Sensor 1 tempererature in [C]")
legend(ax11, 'Location', 'east')

title(ax12,['output Heater 2',num2str(fit(2))])
plot(ax12,tdata,ydata2, 'DisplayName', method)
plot(ax12,tdata,t2s, 'DisplayName', 'Data')
ylim(ax12,[0 45])
xlabel(ax12,"Time in [s]")
ylabel(ax12,"Sensor 1 tempererature in [C]")
legend(ax12, 'Location', 'east')            

title(ax21,"Input heater 1")
plot(ax21,tdata,h1s, 'DisplayName', 'Heater 1')
ylim(ax21,[0 100])
xlabel(ax21,"Time in [s]")
ylabel(ax21,"Input heater 1 in [\%]")
legend(ax21)

title(ax22,"Input heater 2")
plot(ax22,tdata,h2s, 'DisplayName', 'Heater 1')
ylim(ax22,[0 100])
xlabel(ax22,"Time in [s]")
ylabel(ax22,"Input heater 2 in [\%]")
legend(ax22)


end