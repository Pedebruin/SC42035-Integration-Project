%load a file. Then run this script to create plot:

fig = figure(1);
sgtitle('Type Signal: ' + string(upper(Experiment.TypeSignal)),'Interpreter','latex');
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
hold(ax1, 'on');
hold(ax2, 'on');

title(ax1,'Outputs','Interpreter','latex');
plot(ax1,Experiment.idd.y(:,1),'r.','MarkerSize',10,'DisplayName','Output 1');
plot(ax1,Experiment.idd.y(:,2),'b.','MarkerSize',10,'DisplayName','Output 2');
xlabel(ax1,'Time in [s]','Interpreter','latex');
ylabel(ax1,'Temperature in [C]','Interpreter','latex');
legend(ax1,'Location','SouthEast');

title(ax2,'Inputs','Interpreter','latex');
plot(ax2, Experiment.idd.u(:,1), 'r-','LineWidth',2,'DisplayName', 'Input 1');
plot(ax2, Experiment.idd.u(:,2), 'b--','LineWidth',2,'DisplayName', 'Input 2');
xlabel(ax2,'Time in [s]','Interpreter','latex');
ylabel(ax2,'Applied input in [\%]','Interpreter','latex');
%ylim(ax2, [0 100]);
legend(ax2,'Location','NorthEast');