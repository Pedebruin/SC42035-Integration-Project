function [K_Hinf, K_Musyn] = Hinf(G)
% Outputs a discretised controller with sampling frequency of 1s for
% Hinfinity controla nd Mu synthesis. 

% ---- Set up generalised plant: ----
    
    % Wp
    W_p = makeweight(1e5, [35e-4*(2*pi) db2mag(3)], 1); % Design it upside down!
    Wp = [W_p 0; 0 W_p];            % ideal sensitivity function S   
    
    % Wt
    W_t = makeweight(1, [2e-2*(2*pi) db2mag(3)], db2mag(100)); %Design it upside down!
    Wt = [W_t 0; 0 W_t];             % ideal transfer function T
    
    % ---- Compute hinf controller: ----  
    P = augw(G,Wp,[],Wt);
    
    [K_Hinf,~,~] = mixsyn(G, Wp, [], Wt); %Wp, Wu, Wt
    
    CL = feedback(G*K_Hinf,tf(eye(2)));
    Sens = feedback(tf(eye(2)),G*K_Hinf);
    
    K_Hinf = c2d(K_Hinf,1,'zoh');
    K_Musyn = tf(eye(2)); % not implemented..
    
    
   
    % figure
    makefigure = false;
    
    if makefigure
        figure()
        bodemag(1/Wp,Sens,Wp*Sens);
        title('1/Wp, S');
        legend('1/Wp','S','S*Wp');

        figure()
        bodemag(1/Wt,CL,Wt*CL);
        title('Wt, T');
        legend('Wt','T','T*Wt');
    end
end

