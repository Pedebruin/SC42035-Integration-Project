function [sys] = GreyBox(data, params, settings)
%{
This file estimates a grey box model for one heater of the temperature
control lab. 

data: iddata object containing the estimation experiment
params: struct containing the to be estimated parameters, their initial
values and wether they are fixed or not. 

%}
T0 = settings.T0;
params.Ta.value = T0(1);

d1 = delayest(data(:,1,1));
d2 = delayest(data(:,2,2));
d = [d1 d2];
%% set up idnlgrey model for all 3 cases
file_name = 'odeFun';   % File describing the model structure.       
Ts = 0;                 % Continuous time system

switch settings.system(end) 
    case '1'
        varargin = {settings.system; d};
        Order = [1 1 1];    % Model orders [ny nu nx].
        InitialState = T0(1);   % Initial initial state (initial temperature)
        nlgr = idnlgrey(file_name, Order, ones(1,numel(fieldnames(params))), InitialState, Ts, ...
                'Name', 'Heater 1',...
                'FileArgument',varargin);
            
        % set inputs and outputs   
        set(nlgr, 'InputName', 'Heater 1 percentage',...
          'InputUnit', '%',...
          'OutputName', 'Temperature Heater 1',...
          'OutputUnit', 'C',...
          'TimeUnit', 's');
      
        % set states
        nlgr = setinit(nlgr, 'Name', 'Temperature Heater 1');
        nlgr = setinit(nlgr, 'unit', 'C');
        nlgr = setinit(nlgr, 'Fixed', true);    % is the initial state fixed?
        
        % cut data
        data = data(:,1,1);
    case '2'
        varargin = {settings.system; d};
        Order = [1 1 1];    % Model orders [ny nu nx].
        InitialState = T0(2);   % Initial initial state (initial temperature)
        nlgr = idnlgrey(file_name, Order, ones(1,numel(fieldnames(params))), InitialState, Ts, ...
                'Name', 'Heater 2',...
                'FileArgument',varargin);
        
        % set inputs and outputs
        set(nlgr, 'InputName', 'Heater 2 percentage',...
          'InputUnit', '%',...
          'OutputName', 'Temperature Heater 2',...
          'OutputUnit', 'C',...
          'TimeUnit', 's');
      
        % set states
        nlgr = setinit(nlgr, 'Name', 'Temperature Heater 2');
        nlgr = setinit(nlgr, 'unit', 'C');
        nlgr = setinit(nlgr, 'Fixed', true);    % is the initial state fixed? 
        
        % cut data
        data = data(:,2,2);
        
    case 'o'
        varargin = {settings.system; d};
        Order = [2 2 2];    % Model orders [ny nu nx].
        InitialState = T0';   % Initial initial state (initial temperature)
        nlgr = idnlgrey(file_name, Order, ones(1,numel(fieldnames(params))), InitialState, Ts, ...
                'Name', 'Heaters',...
                'FileArgument',varargin);
        
        % set inputs and outputs    
        set(nlgr, 'InputName', {'Heater 1 percentage'; 'Heater 2 percentage'} ,...
          'InputUnit', {'%';'%'},...
          'OutputName', {'Temperature Heater 1'; 'Temperature Heater 2'},...
          'OutputUnit', {'C'; 'C'},...
          'TimeUnit', 's');
      
        % set states
        nlgr = setinit(nlgr, 'Name', {'Temperature Heater 1';'Temperature Heater 2'});
        nlgr = setinit(nlgr, 'unit', {'C';'C'});
        nlgr = setinit(nlgr, 'Fixed', true);    % is the initial state fixed?
end



      
% set up parameters in model   (assume heaters are identical)
nlgr = setpar(nlgr, 'Name', {   'U',...
                                'A',...
                                'Ta',...
                                'alpha',...
                                'm',...
                                'cp',...
                                'epsilon',...
                                'sigma',...
                                'T_inf',...
                                'As'});
nlgr = setpar(nlgr, 'Unit', {'W/(m^2k)',...
                                'm^2',...
                                'C',...
                                'W/%',...
                                'kg',...
                                'J/kg',...
                                '-',...
                                'W/(m^2K^4)',...
                                'C',...
                                'm^2'});
nlgr = setpar(nlgr, 'Fixed', {params.U.fixed,...
                                params.A.fixed,...
                                params.Ta.fixed,...
                                params.alpha.fixed,...
                                params.m.fixed,...
                                params.cp.fixed,...
                                params.epsilon.fixed,...
                                params.sigma.fixed,...
                                params.T_inf.fixed,... 
                                params.As.fixed});
nlgr = setpar(nlgr, 'Value', {params.U.value,...
                                params.A.value,...
                                params.Ta.value,...
                                params.alpha.value,...
                                params.m.value,...
                                params.cp.value,...
                                params.epsilon.value,...
                                params.sigma.value,...
                                params.T_inf.value,...
                                params.As.value});
                       
%% Configure nlgreyest                            
opt = nlgreyestOptions('EstimateCovariance',true,...
                        'SearchMethod','lm',...
                        'Display','on');
% Turn off annoying warnings about input and output names :)
warning('off','Ident:analysis:DataModelNameUnitMismatch')
warning('off','Ident:analysis:DataModelIOReorder')

sys = nlgreyest(data, nlgr, opt);
end