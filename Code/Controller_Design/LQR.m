function LQR(G,r)
    %Convert G to discrete form:
    sysd = c2d(G, 1);
    
    %---- calculate L (make A - LC Hurwitz): ----
    L = ones(5,2)*0.01;
    ALC_hurwitz = sysd.A - L*sysd.C; 
    if not(all(abs(ALC_hurwitz(:)) < 1)) %Check if A - LC hurwitz, all values must be in the unit circle.
        error('A - LC is not Hurwitz! Adjust the gain L.')
    end
    
    
    %---- calculate optimum F (using discrete LQR): ----
    Q = eye(length(sysd.A));
    R = eye(size(sysd.B,2));
    [F,S,P] = dlqr(sysd.A,sysd.B,Q,R); %F is gain, S is solution, P is eigenvalues of closedloop 
    
    
    %---- calculate optimum G: ----
    
    % define performance equation z = Ctilde*x + Dtilde*u
    Ctilde = sysd.C;
    Dtilde = sysd.D;
    
    % solve tracking equation:
    T = linsolve([[sysd.A,sysd.B];[Ctilde,Dtilde]],[zeros(5,5);eye(5)]);
    Pi = T(1:5,:);
    Gamma = T(6:7,:);
    G = Gamma + F*Pi;

    
    %% ==== Simulation: ====
    
    TimeSeries = 1:1:500;
    x_k0 = [0,0,0,0,0]';
    
    ySeries = zeros(5,length(TimeSeries));
    C = eye(5); %show every state
    D = zeros(5,2); %no feedthrough
    
    for i = TimeSeries
        
        % ---- Feedback: ----
        u_k0 = -F*x_k0 + G*r;
        
        % ---- Plant: ----
        
        %State equations:
        x_k1 = sysd.A*x_k0 + sysd.B*u_k0;

        %Output equations:
        y_k0 = C*x_k0 + D*u_k0;
        
        % ---- Observer: ----
        
        
        % ---- Loop management: ----
        
        %Record output:
        ySeries(:,i) = y_k0;
        
        %Prepare next iteration:
        x_k0 = x_k1;
    end
    
    plot(TimeSeries, ySeries)

end