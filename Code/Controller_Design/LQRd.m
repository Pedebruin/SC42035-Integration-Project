function LQRd(Plant,r)
    %Calculate gains for discrete LQR controller and simulate.
    
    %% ==== SETUP: ====
    %Convert G to discrete form:
    Ts = 1;
    sysd = c2d(Plant, Ts);
    
    % ---- calculate L (make A - LC Hurwitz): ----
    %L = ones(5,2)*-0.01;
    %Using the following command improves L: 
    %>>> [L,prec,message] = place(sysd.A',sysd.C',[0.96, 0.99, 0.98, 0.92, 0.51]');
%     L = [    0.0707   -0.1467    0.0527   -0.0008    2.9859;
%             -0.0602    0.0282    0.0435    0.0021    0.8821]';
    [L,prec,message] = place(sysd.A',sysd.C',eig(sysd.A) - 0.06);
    L = L';
    ALC_hurwitz = eig(sysd.A - L*sysd.C); 
    if not(all(abs(ALC_hurwitz(:)) < 1)) %Check if A - LC hurwitz, all values must be in the unit circle.
        error('A - LC is not Hurwitz! Adjust the gain L.')
    end
    
    %checking poles:
%     for i = -0.5:0.1:0.5
%     L = ones(5,2)*i;
%     hold on;
%     scatter(real(eig(sysd.A)), imag(eig(sysd.A)), 'bx');
%     scatter(real(eig(sysd.A - L*sysd.C)), imag(eig(sysd.A - L*sysd.C)), 'r.');
%     rectangle('Position',[-1 -1 2 2],'Curvature',[1 1]);
%     axis equal;
%     end;
    
    
    % ---- calculate optimum F (using discrete LQR): ----
    Q = eye(length(sysd.A));
    R = eye(size(sysd.B,2));
    [F,S,P] = dlqr(sysd.A,sysd.B,Q,R); %F is gain, S is solution, P is eigenvalues of closedloop 

    
%     % ---- calculate optimum G: ----
%     
%     % define performance equation z = Ctilde*x + Dtilde*u
%     Ctilde = sysd.C;
%     Dtilde = sysd.D;
%     
%     % solve tracking equation:
%     T = linsolve([[sysd.A,sysd.B];
%                   [Ctilde,Dtilde]], ...
%                   [zeros(5,2);
%                    eye(2)]);
%     Pi = T(1:5,:);
%     Gamma = T(6:7,:);
%     G = Gamma + F*Pi;

    % ---- Calculate target: ----
    % define performance equation z = Ctilde*x + Dtilde*u
    Ctilde = sysd.C;
    Dtilde = sysd.D;
    
    %Calculate target selection:
    T = linsolve([[eye(5) - sysd.A, -sysd.B];
                  [Ctilde, zeros(2,2)]], ...
                  [zeros(5,1);
                   r]);
    xref = T(1:5,:);
    uref = T(6:7,:);
    
    %% ==== Simulation: ====
    
    TimeSeries = 1:1:1000;
    x_k0 = [-100,0,0,0,0]';
    xhat_k0 = [0,0,0,0,0]';
    
    umax = 100;%
    umin = 0;%
    
    ySeries = zeros(2,length(TimeSeries));
    yhatSeries = zeros(2,length(TimeSeries));
    uSeries = zeros(2,length(TimeSeries));
    
    for i = TimeSeries
        
        % ---- Feedback: ----
        %u_k0 = -F*xhat_k0 + G*r;
        u_k0 = -F*(xhat_k0 - xref) + uref;
        %Input saturation:
        u_k0 = min(umax, max(umin, u_k0));

        % ---- Plant: ----
        
        %State equations:
        x_k1 = sysd.A*x_k0 + sysd.B*u_k0;

        %Output equations:
        y_k0 = sysd.C*x_k0 + sysd.D*u_k0;
        
        %Performance equations:
        z_k0 = Ctilde*x_k0 + Dtilde*u_k0;
        
        % ---- Observer: ----
        yhat_k0 = sysd.C*xhat_k0 + sysd.D*u_k0;
        xhat_k1 = sysd.A*xhat_k0 + sysd.B*u_k0 + L*(y_k0 - yhat_k0);
        
        % ---- Loop management: ----
        
        %Record input & output:
        ySeries(:,i) = y_k0;
        yhatSeries(:,i) = yhat_k0;
        uSeries(:,i) = u_k0;
        
        %Prepare next iteration:
        x_k0 = x_k1;
        xhat_k0 = xhat_k1;
    end
    
    
    %% ==== Figure: ====
    
    fig = figure('Name','Control'); 
    sgtitle('Method: LQR', 'Interpreter','latex');
    ax11 = subplot(2,2,1);
    ax12 = subplot(2,2,2);
    ax21 = subplot(2,2,3);
    ax22 = subplot(2,2,4);
    hold(ax11, "on");
    hold(ax12, "on");
    hold(ax21, "on");
    hold(ax22, "on");
    
    title(ax11,'Output Heater 1')
    plot(ax11, TimeSeries, ySeries(1,:), 'r-', 'DisplayName', 'Plant');
    plot(ax11, TimeSeries, yhatSeries(1,:), 'b-', 'DisplayName', 'Observer');
    yline(ax11, r(1,1),'k-.', 'DisplayName', 'Reference');
    xlabel(ax11,"Time in [s]")
    ylabel(ax11,"Sensor 1 tempererature in [C]")
    legend(ax11, 'Location', 'east')

    title(ax12,'Output Heater 2')
    plot(ax12, TimeSeries, ySeries(2,:), 'r-', 'DisplayName', 'Plant');
    plot(ax12, TimeSeries, yhatSeries(2,:), 'b-', 'DisplayName', 'Observer');
    yline(ax12, r(2,1),'k-.', 'DisplayName', 'Reference');
    xlabel(ax12,"Time in [s]")
    ylabel(ax12,"Sensor 1 tempererature in [C]")
    legend(ax12, 'Location', 'east') 

    title(ax21,'Input Heater 1')
    plot(ax21, TimeSeries, uSeries(1,:), 'm-');
    ylim(ax21, [0 100]);
    xlabel(ax21,"Time in [s]")
    ylabel(ax21,"Input heater 1 in [\%]")


    title(ax22,'Input Heater 2')
    plot(ax22, TimeSeries, uSeries(2,:), 'm-');
    ylim(ax22, [0 100]);
    xlabel(ax22,"Time in [s]")
    ylabel(ax22,"Input heater 2 in [\%]")

end



%##########################################################################
% Sources:
%##########################################################################
%1) Input saturation command: https://nl.mathworks.com/matlabcentral/answers/30243-how-to-type-saturation-command-in-matlab