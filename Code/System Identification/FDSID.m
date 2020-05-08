function [sys] = FDSID(init_sys, idd)

    opt = tfestOptions( 'InitializeMethod','iv',...
                        'OutputOffset',[17],...
                        'InitialCondition','zero',...
                        'Display','on');

    % ---- Refinement: ----
    data = idd(:,1,1);
    sys = tfest(data,init_sys,opt);

end
