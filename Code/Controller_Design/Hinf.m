function [K_Hinf, K_Musyn] = Hinf(G)
% ---- Set up generalised plant: ----
    % Wp
    s = tf([1 0],1);
    bw = 7e-2*2*pi;         % Bandwidth for each output [rad/s]
    M = 1.8;              % Upper bound for Hinf norm
    A = 1e-4;             % Attenuation of low frequency disturbances  
    W_p = (s/M + bw)/(s + bw*A);
    Wp = [W_p 0; 0 W_p];            % ideal sensitivity function S
    
    Wp.InputName = {'v1', 'v2'};
    Wp.Outputname = {'z31','z32'};
    
    % Wu
    Wu = tf(eye(2));                % ideal control input signal U
    Wu.InputName = {'Heater power 1','Heater power 2'};
    Wu.OutputName = {'z11','z12'};
        
    % Wt
    bw = 7e-2*2*pi;         % Bandwidth for each output [rad/s]
    M = 2;              % Upper bound for Hinf norm
    A = 1;             % Attenuation of low frequency disturbances
    W_t = (s/M + bw)/(s + bw*A);
    Wt = [W_t 0; 0 W_t];                % ideal transfer function T
    
    Wt.InputName = {'Temperature 1', 'Temperature 2'};
    Wt.OutputName = {'z21','z22'};
    
    SumR1 = sumblk('v1 = r1 - Temperature 1');
    SumR2 = sumblk('v2 = r2 - Temperature 2');
    Inputs = {'r1','r2'};
    Outputs = {'z11','z12','z21','z22','z31','z32'};
    
    P1 = connect(G,Wp,Wu,Wt,SumR1,SumR2,Inputs,Outputs);
    P2 = minreal([zeros(2) Wu;
                zeros(2) Wt*G;
                Wp -Wp*G;
                eye(2) -G]);

    % ---- Compute hinf controller: ----        
    ncont = 2; 
    nmeas = 2; 
    [K_Hinf,~,~] = hinfsyn(P2,nmeas,ncont);
    [K_Musyn,CLperf,info] = musyn(P1,nmeas,ncont,K_Hinf);
    K_Musyn = 0;
end

