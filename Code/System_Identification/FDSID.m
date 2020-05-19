function [sys] = FDSID(idd, settings)

    offset = settings.T0;

    switch settings.system(end)
        case "1" 
            u1 = idd.u(:,1);
            y1 = idd.y(:,1);
            d1 = delayest(idd(:,1,1),1,1); %Estimate delay for input 1.
            
            y1vec = y1(1+d1:end) - offset;
            H1mat = [-y1(d1:end-1) + offset, u1(1:end-d1)];
            
            thetaHat1 = pinv(H1mat)*y1vec;
            sys = tf([thetaHat1(2)],[1 1+thetaHat1(1)],'IODelay',d1);
        case "2"
            u2 = idd.u(:,2);
            y2 = idd.y(:,2);
            d2 = delayest(idd(:,2,2),1,1); %Estimate delay for input 2.
            
            y2vec = y2(1+d2:end) - offset;
            H2mat = [-y2(d2:end-1) + offset, u2(1:end-d2)];
            
            thetaHat2 = pinv(H2mat)*y2vec;
            sys = tf([thetaHat2(2)],[1 1+thetaHat2(1)],'IODelay',d2);
        case "o"
            u1 = idd.u(:,1);
            y1 = idd.y(:,1);
            u2 = idd.u(:,2);
            y2 = idd.y(:,2);
            d1 = delayest(idd(:,1,1),1,1); %Estimate delay for input 1.
            d2 = delayest(idd(:,2,2),1,1); %Estimate delay for input 2.
            d = max([d1,d2]);
            
            y1vec = y1(1+d:end) - offset;
            H1mat = [-y1(d:end-1) + offset, u1(1-d1+d:end-d1), u2(1-d2+d:end-d2)];
            y2vec = y2(1+d:end) - offset;
            H2mat = [-y2(d:end-1) + offset, u1(1-d1+d:end-d1), u2(1-d2+d:end-d2)];
            
            thetaHat1 = pinv(H1mat)*y1vec;
            thetaHat2 = pinv(H2mat)*y2vec;
            g11 = tf([thetaHat1(2)],[1 1+thetaHat1(1)],'IODelay',d1);
            g12 = tf([thetaHat1(3)],[1 1+thetaHat1(1)],'IODelay',d2);
            g21 = tf([thetaHat2(2)],[1 1+thetaHat2(1)],'IODelay',d1);
            g22 = tf([thetaHat2(3)],[1 1+thetaHat2(1)],'IODelay',d2);
            sys = [[g11 g12]; 
                   [g21 g22]];
    end
    
end


%commands that should have worked:
% a = arx(data,[1 0 d])
% idtf(a)
