function [sys] = GreyBox(data,params)
%{
This file estimates a grey box model for one heater of the temperature
control lab. 

data: iddata object containing the estimation experiment
params: struct containing the to be estimated parameters, their initial
values and wether they are fixed or not. 

%}

params.U.value          = 5;   % W/(m^2k)
params.A.value          = 0.0012; % m^2
params.Ta.value         = 23;     % Celcius
params.alpha.value      = 0.01;% from % to heat flow
params.m.value          = 0.004;   % kg
params.cp.value         = 500;    %J/kg
params.epsilon.value    = 0.9;
params.sigma.value      = 5.67e-8;
params.T_inf.value      = 23;

params.U.fixed          = true;
params.A.fixed          = true;
params.Ta.fixed         = true;
params.alpha.fixed      = true;
params.m.fixed          = false;
params.cp.fixed         = true;
params.epsilon.fixed    = true;
params.sigma.fixed      = true;
params.T_inf.fixed      = true;




%% set up idnlgrey model
file_name = 'odeFun';   % File describing the model structure.
Order = [1 1 1];        % Model orders [ny nu nx].
InitialState = T0;      % Initial initial state (initial temperature)
Ts =0;                  % Continuous time system

nlgr = idnlgrey(file_name, Order, ones(1,numel(fieldnames(params))), InitialState, Ts, ...
                'Name', 'Heater 1');

set(nlgr, 'InputName', 'Heater percentage', 'InputUnit', '%',...
          'OutputName', 'Temperature',...
          'OutputUnit', 'C',...
          'TimeUnit', 's');
      
% set up parameters in model   
nlgr = setpar(nlgr, 'Name', {   'U',...
                                'A',...
                                'Ta',...
                                'alpha',...
                                'm',...
                                'cp',...
                                'epsilon',...
                                'sigma',...
                                'T_inf'});
nlgr = setpar(nlgr, 'Unit', {'W/(m^2k)',...
                                'm^2',...
                                'C',...
                                'W/%',...
                                'kg',...
                                'J/kg',...
                                '-',...
                                'W/(m^2K^4)',...
                                'C'});
nlgr = setpar(nlgr, 'Fixed', {params.U.fixed,...
                                params.A.fixed,...
                                params.Ta.fixed,...
                                params.alpha.fixed,...
                                params.m.fixed,...
                                params.cp.fixed,...
                                params.epsilon.fixed,...
                                params.sigma.fixed,...
                                params.T_inf.fixed});                                                     
nlgr = setpar(nlgr, 'Value', {params.U.value,...
                                params.A.value,...
                                params.Ta.value,...
                                params.alpha.value,...
                                params.m.value,...
                                params.cp.value,...
                                params.epsilon.value,...
                                params.sigma.value,...
                                params.T_inf.value});
% set up state in model 
T0 = 20; % Initial guess
nlgr = setinit(nlgr, 'Name', 'Temperature');
nlgr = setinit(nlgr, 'unit', 'C');
nlgr = setinit(nlgr, 'Value', T0);
nlgr = setinit(nlgr, 'Fixed', false);
                            
%% Configure nlgreyest                            
opt = nlgreyestOptions('EstimateCovariance',true,...
                        'SearchMethod','lm',...
                        'Display','off');
sys = greyest(data, nlgr, opt);
end