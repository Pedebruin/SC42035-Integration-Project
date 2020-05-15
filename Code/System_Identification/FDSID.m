function [sys] = FDSID(idd, init_tf, offset)

    % ---- Extracting data: ----
    data = idd(:,1,1);
    
    % ---- Estimate delay: ----
    d = delayest(data,1,1); %Estimate delay for an ARX 1-1 model. WEIRD!
    
    % ---- Least sqaures: ----
    
    % Setting up vectors and matrices:
    y = data.y;
    u = data.u;
    offset = mean(y(1:d));
    ydata = y(1+d:end) - offset;
    Hdata = [-y(d:end-1) + offset, u(1:end-d)];
%     ydata = y(1+d:end);
%     Hdata = [-y(d:end-1), u(1:end-d)];
    
    
    % Least squares:
%     thetaHat = (Hdata' * Hdata)\(Hdata' * ydata);
    thetaHat = pinv(Hdata)*ydata;
    
%     % ---- Optimisation: ----
% 
%     % Specify optimisation parameters:
%     opt = tfestOptions( 'InitializeMethod','iv',...
%                         'OutputOffset',offset,...
%                         'InitialCondition','zero',...
%                         'Display','on');
% 
%     % Run optimisation:
%     sys = tfest(data, 1, 0, NaN, opt);
%     %sys = tfest(data,init_tf,opt);

    sys = tf([thetaHat(2)],[1 1+thetaHat(1)],'IODelay',d);

end


%commands that should have worked:
% a = arx(data,[1 0 d])
% idtf(a)
