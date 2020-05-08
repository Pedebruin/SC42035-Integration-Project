function [sys] = FDSID(init_sys, idd)

    % ---- Refinement: ----
    data = idd(:,1,1);
    sys = tfest(data,init_sys);

end
