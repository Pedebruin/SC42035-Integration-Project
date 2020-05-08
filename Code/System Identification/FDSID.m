function [sys] = FDSID(data)

    % ---- Initial guess constructed from data: ----
    K = 1/3;
    d = 15;
    tau = 47;
    init_sys = tf(K,[tau 1],'InputDelay',d);
    
    % ---- Refinement: ----
    sys = tfest(data,init_sys);

end
