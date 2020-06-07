function LQRc(Plant,r)
    %Calculate gains for discrete LQR controller and simulate.
    
    %TODO: Still does not work. Correct it!
    
    %% ==== SETUP: ====
    A = Plant.A;
    B = Plant.B;
    C = Plant.C;
    D = Plant.D;
    Ctilde = C;
    Dtilde = D;
    
    x0 = [-100,0,0,0,0]';
    
    % ---- calculate L (make A - LC Hurwitz): ----
    [L,prec,message] = place(A',C',[-0.05, -0.01, -0.05, -0.1, -1]');
    L = L'; 
    
    % ---- calculate optimum F (using discrete LQR): ----
    Q = eye(length(A));
    R = eye(size(B,2));
    [F,S,P] = lqr(A,B,Q,R); %F is gain, S is solution, P is eigenvalues of closedloop 
    
    % ---- calculate optimum G (by solving tracking equation): ----
    T = linsolve([[A,B];
                  [Ctilde,Dtilde]], ...
                  [zeros(5,2);
                   eye(2)]);
    Pi = T(1:5,:);
    Gamma = T(6:7,:);
    G = Gamma + F*Pi;
    
    %% ==== SIMULATION: ====
    
    % ---- Observer: ----
    obsys = ss(A-L*C, [B-L*D L], F, zeros(2,4));
    xhat0 = [0,0,0,0,0]';
    
%     % ---- Plant: ----
%     z = [0 0 0 0 0];
%     sys = ss(A, [z' B], [z; Ctilde; [z;z]; C], [0 1;0 Dtilde; eye(2); 0 D]);
    
    % ---- Controller: ----
    co = [G -obsys];
    cl = lft(Plant,co);
    
    
    %% ==== FIGURE: ====
    TimeSeries = 1:500;
    RefSeries = ones(length(TimeSeries),4)*50;
    
    [y,to] = lsim(cl, RefSeries, TimeSeries, [x0; xhat0]);
    
    figure(1);
    subplot(2,1,1);
    plot(to,y(:,1));
    grid on;
    title('Control action');
    subplot(2,1,2);
    plot(to, y(:,2), TimeSeries, RefSeries, 'r');
    grid on;
    title('Reference (red) and output');
    
%     % ==== FIGURE: ====
%     
%     fig = figure('Name','Control'); 
%     sgtitle('Method: LQR', 'Interpreter','latex');
%     ax11 = subplot(2,2,1);
%     ax12 = subplot(2,2,2);
%     ax21 = subplot(2,2,3);
%     ax22 = subplot(2,2,4);
%     hold(ax11, "on");
%     hold(ax12, "on");
%     hold(ax21, "on");
%     hold(ax22, "on");
%     
%     title(ax11,'Output Heater 1')
%     plot(ax11, TimeSeries, ySeries(1,:), 'r-', 'DisplayName', 'Plant');
%     plot(ax11, TimeSeries, yhatSeries(1,:), 'b-', 'DisplayName', 'Observer');
%     yline(ax11, r(1,1),'k-.', 'DisplayName', 'Reference');
%     xlabel(ax11,"Time in [s]")
%     ylabel(ax11,"Sensor 1 tempererature in [C]")
%     legend(ax11, 'Location', 'east')
% 
%     title(ax12,'Output Heater 2')
%     plot(ax12, TimeSeries, ySeries(2,:), 'r-', 'DisplayName', 'Plant');
%     plot(ax12, TimeSeries, yhatSeries(2,:), 'b-', 'DisplayName', 'Observer');
%     yline(ax12, r(2,1),'k-.', 'DisplayName', 'Reference');
%     xlabel(ax12,"Time in [s]")
%     ylabel(ax12,"Sensor 1 tempererature in [C]")
%     legend(ax12, 'Location', 'east') 
% 
%     title(ax21,'Input Heater 1')
%     plot(ax21, TimeSeries, uSeries(1,:), 'm-');
%     ylim(ax21, [0 100]);
%     xlabel(ax21,"Time in [s]")
%     ylabel(ax21,"Input heater 1 in [\%]")
% 
% 
%     title(ax22,'Input Heater 2')
%     plot(ax22, TimeSeries, uSeries(2,:), 'm-');
%     ylim(ax22, [0 100]);
%     xlabel(ax22,"Time in [s]")
%     ylabel(ax22,"Input heater 2 in [\%]")

end



%##########################################################################
% Sources:
%##########################################################################
%1) Input saturation command: https://nl.mathworks.com/matlabcentral/answers/30243-how-to-type-saturation-command-in-matlab



