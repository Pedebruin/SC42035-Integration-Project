%load a file. Then run this script to create plot:



fig = figure(1);
sgtitle('Type Controller: ' + string(upper(Test.TypeController)), 'Interpreter','latex');
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
hold(ax1, 'on');
hold(ax2, 'on');

title(ax1,'Outputs','Interpreter','latex');
stairs(ax1,Test.idd.y(:,1),'r.','MarkerSize',10,'DisplayName','TCL output 1');
stairs(ax1,Test.idd.y(:,2),'b.','MarkerSize',10,'DisplayName','TCL output 2');
if strcmp(Test.TypeController,'lqr')
    stairs(ax1,Test.idd.y(:,3),'r-','LineWidth',1,'DisplayName','Observer output 1');
    stairs(ax1,Test.idd.y(:,4),'b-','LineWidth',1,'DisplayName','Observer output 2');
end    
stairs(ax1, Test.idd.u(:,3), 'm-','LineWidth',1,'DisplayName', 'Reference 1');
stairs(ax1, Test.idd.u(:,4), 'c-','LineWidth',1,'DisplayName', 'Reference 2');
xlabel(ax1,'Time in [s]','Interpreter','latex');
ylabel(ax1,'Tempererature in [C]','Interpreter','latex');
ylim(ax1, [0 60]);
legend(ax1,'Location','SouthEast');

title(ax2,'Inputs','Interpreter','latex');
stairs(ax2, Test.idd.u(:,1), 'r-','LineWidth',2,'DisplayName', 'Input 1');
stairs(ax2, Test.idd.u(:,2), 'b-','LineWidth',2,'DisplayName', 'Input 2');
xlabel(ax2,'Time in [s]','Interpreter','latex');
ylabel(ax2,'Applied input in [\%]','Interpreter','latex');
ylim(ax2, [0 100]);
legend(ax2,'Location','NorthEast');

