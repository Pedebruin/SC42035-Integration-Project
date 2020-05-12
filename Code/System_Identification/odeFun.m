function [dT,y] = odeFun(t,x,u, U,A,Ta,alpha,m,cp,epsilon,sigma,T_inf, varargin)
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

T = x;
Q = u;

dT_conv = (U*A*(Ta - T)+alpha*Q)/(m*cp);                % convective heat transfer
dT_rad = (epsilon*sigma*A*(T_inf^4-T^4)+alpha*Q)/(m*cp);    % Radiative heat transfer

dT = dT_rad + dT_conv;
y = T;
end