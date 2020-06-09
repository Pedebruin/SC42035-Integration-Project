%load a file. Then run this script to create plot:

fig = figure(1);
sgtitle('TypeSignal: ' + string(Experiment.TypeSignal), 'Interpreter','latex');
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
hold(ax1, "on");
hold(ax2, "on");

title(ax1,'Output')
plot(ax1, Experiment.idd.y(:,1), 'r-', 'DisplayName', 'Output 1');
plot(ax1, Experiment.idd.y(:,2), 'b-', 'DisplayName', 'Output 2');
xlabel(ax1,"Time in [s]")
ylabel(ax1,"Tempererature in [C]")
legend(ax1, 'Location', 'east')

title(ax2,'Input')
plot(ax2, Experiment.idd.u(:,1), 'r-', 'DisplayName', 'Input 1');
plot(ax2, Experiment.idd.u(:,2), 'b-', 'DisplayName', 'Input 2');
xlabel(ax2,"Time in [s]")
ylabel(ax2,"Applied input in [\%]")
legend(ax2, 'Location', 'east')