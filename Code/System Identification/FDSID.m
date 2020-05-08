function [sys] = FDSID(idd)

    % ---- Initial guess constructed from data: ----
    K = 1/3;
    d = 15;
    tau = 47;
    init_sys = tf(K,[tau 1],'InputDelay',d);
    
    % ---- Refinement: ----
    data = idd(:,1,1);
    sys = tfest(data,init_sys);

end
