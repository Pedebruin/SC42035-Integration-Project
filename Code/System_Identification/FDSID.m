function [sys] = FDSID(idd, init_tf, offset)

    % ---- Extracting data: ----
    data = idd(:,1,1);
    
    % ---- Optimisation: ----

    % Specify optimisation parameters:
    opt = tfestOptions( 'InitializeMethod','iv',...
                        'OutputOffset',offset,...
                        'InitialCondition','zero',...
                        'Display','on');

    % Run optimisation:
    sys = tfest(data, 1, 0, NaN, opt);
    %sys = tfest(data,init_tf,opt);

end

