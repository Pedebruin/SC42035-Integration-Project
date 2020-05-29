function LQR(G,r)
    %Convert G to discrete form:
    sysd = c2d(G, 1);

    %---- calculate optimum F (using discrete LQR): ----
    Q = eye(length(sysd.A));
    R = eye(size(sysd.B,2));
    [F,S,P] = dlqr(sysd.A,sysd.B,Q,R); %F is gain, S is solution, P is eigenvalues of closedloop 
    
    %---- calculate optimum G: ----
    % define performance equation z = C_ x + D_ u
    C_ = eye(length(sysd.A));
    D_ = zeros(5,2);
    % solve tracking equation:
    %T = linsolve([[sysd.A,sysd.B];[C_,D_]],[zeros(8,2);eye(2)]);
    T = linsolve([[sysd.A,sysd.B];[C_,D_]],[zeros(5,5);eye(5)]);
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
        
        %Feedback:
        u_k0 = -F*x_k0 + G*r;
        
        %State equations:
        x_k1 = sysd.A*x_k0 + sysd.B*u_k0;

        %Output equations:
        y_k0 = C*x_k0 + D*u_k0;
        
        %Record output:
        ySeries(:,i) = y_k0;
        
        %Prepare next iteration:
        x_k0 = x_k1;
    end
    
    plot(TimeSeries, ySeries)

end