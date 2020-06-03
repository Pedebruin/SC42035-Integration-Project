function [K] = Hinf(G)
% ---- Set up generalised plant: ----
    s = tf([1 0],1);
    bw = 7e-3*2*pi;         % Bandwidth for each output [rad/s]
    M_1 = 1.8;              % Upper bound for Hinf norm
    A_1 = 1e-4;             % Attenuation of low frequency disturbances  
    W_p = (s/M_1 + bw)/(s + bw*A_1);




    Wp = [W_p 0; 0 W_p];            % ideal sensitivity function S
    Wu = tf(eye(2));                % ideal control input signal U
    Wt = tf(eye(2));                % ideal transfer function T

    P = minreal([zeros(2) Wu;
                zeros(2) Wt*G;
                Wp -Wp*G;
                eye(2) -G]);

    % ---- Compute hinf controller: ----        
    ncont = 2; 
    nmeas = 2; 
    [K,~,~] = hinfsyn(P,nmeas,ncont);

    % ---- Simulate system: ----
    r = [45 37];                % Degree C
    T = 1500;                   % s


    T0 = G.UserData;
    R = (r - T0');

    CL = feedback(K*G,tf(eye(2)));
end

