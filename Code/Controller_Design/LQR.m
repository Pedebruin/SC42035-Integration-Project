function LQR(Plant,r)
    %Convert G to discrete form:
    Ts = 1;
    sysd = c2d(Plant, Ts);
    
    %---- calculate L (make A - LC Hurwitz): ----
    L = ones(5,2)*-0.01;
    ALC_hurwitz = eig(sysd.A - L*sysd.C); 
    if not(all(abs(ALC_hurwitz(:)) < 1)) %Check if A - LC hurwitz, all values must be in the unit circle.
        error('A - LC is not Hurwitz! Adjust the gain L.')
    end
    
    %checking poles:
%     hold on;
%     scatter(real(eig(sysd.A)), imag(eig(sysd.A)), 'bx');
%     scatter(real(eig(sysd.A - L*sysd.C)), imag(eig(sysd.A - L*sysd.C)), 'r.');
%     rectangle('Position',[-1 -1 2 2],'Curvature',[1 1]);
%     axis equal;
    
    
    %---- calculate optimum F (using discrete LQR): ----
    Q = eye(length(sysd.A));
    R = eye(size(sysd.B,2));
    [F,S,P] = dlqr(sysd.A,sysd.B,Q,R); %F is gain, S is solution, P is eigenvalues of closedloop 

    
%     %---- calculate optimum G: ----
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
    
    zSeries = zeros(2,length(TimeSeries));
    ySeries = zeros(2,length(TimeSeries));
    yhatSeries = zeros(2,length(TimeSeries));
    xSeries = zeros(5,length(TimeSeries));
    xhatSeries = zeros(5,length(TimeSeries));
    
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
        
        %Record output:
        zSeries(:,i) = z_k0;
        ySeries(:,i) = y_k0;
        yhatSeries(:,i) = yhat_k0;
        xSeries(:,i) = x_k0;
        xhatSeries(:,i) = xhat_k0;
        
        %Prepare next iteration:
        x_k0 = x_k1;
        xhat_k0 = xhat_k1;
    end
    
    
    %% ==== Figure: ====
    
    % TODO: Add here idd and then simply plot that. Still need input series
    % then. 
    
    figure(1);
    hold on;
    %plot(TimeSeries, zSeries);
    plot(TimeSeries, ySeries, 'r-');
    plot(TimeSeries, yhatSeries, 'b-');
%     plot(TimeSeries, xSeries, 'r-');
%     plot(TimeSeries, xhatSeries, 'b-');
%     yline(r(1,1),'r-');
%     yline(r(2,1),'b-');
    hold off;
end



%##########################################################################
% Sources:
%##########################################################################
%1) Input saturation command: https://nl.mathworks.com/matlabcentral/answers/30243-how-to-type-saturation-command-in-matlab