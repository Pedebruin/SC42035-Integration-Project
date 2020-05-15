function [dT,y] = odeFun(t,x,u, U,A,Ta,alpha,m,cp,epsilon,sigma,T_inf,As, varargin)
%{
t       = current time
x       = state vector at time t
u       = input vector at time t

->U       = heat transfer coefficient of control volume
->A       = surface area of control volume
Ta      = Surrounding air temperature
T       = actual heater temperature
alpha   = parameter to convert from % heater to heat flow : alpha = 0.01 W/%
Q       = heater percentage
->m       = mass of control volume
cp      = heat capacity of control volume

epsilon = emmisivity
sigma   = stefan bolzman constant
->T_inf   = temperature of surrounding environment
%}

persistent Qhist

system = varargin{1}{1};
delay = varargin{1}{2};

T = x;
Q = u;


% delay the input to the model by max(delay) amount of samples
% if isempty(Qhist)
%     Qhist = zeros(max(delay), size(u,2));
% end
% Qhist = [Q; Qhist(1:end-1,:)];
% Q = Qhist(max(delay),:);  

% Actual model    
switch system(end)
    case '1'
        dT_conv = (U*A*(Ta - T)+alpha*Q)/(m*cp);                % convective heat transfer
        dT_rad = (epsilon*sigma*A*(T_inf^4-T^4)+alpha*Q)/(m*cp);    % Radiative heat transfer

        dT = dT_rad + dT_conv;
        y = T;
        
    case '2'
        dT_conv = (U*A*(Ta - T)+alpha*Q)/(m*cp);                % convective heat transfer
        dT_rad = (epsilon*sigma*A*(T_inf^4-T^4)+alpha*Q)/(m*cp);    % Radiative heat transfer

        dT = dT_rad + dT_conv;
        y = T;
        
    case 'o'
        Qc12 = U*As*(T(2)-T(1));                % convective heat flow from 1 to 2
        Qr12 = epsilon*sigma*A*(T(2)^4+T(1)^4); % radiative heat flow from 1 to 2
        
        
        dT_conv = [(U*A*(Ta - T(1)) + Qc12 + alpha*Q(1))/(m*cp);     % convective heat transfer H1
                    (U*A*(Ta - T(2))- Qc12 + alpha*Q(2))/(m*cp)];   % convective heat transfer H2
                
        dT_rad = [(epsilon*sigma*A*(T_inf^4-T(1)^4)  + Qr12 +alpha*Q(1))/(m*cp);       % Radiative heat transfer H1
                    (epsilon*sigma*A*(T_inf^4-T(2)^4)- Qr12 +alpha*Q(2))/(m*cp)];    % Radiative heat transfer H2

        dT = dT_rad + dT_conv;
        y = T;
end