function [ss,x0,T0] = N4SID(data, settings)
%{ 
This file fits a nth order model to a dataset using the N4SID subspace
identification method and levenberg marquand optimisation.  

Written by:
    Pim de Bruin 
    Marco Delgado Gosalvez

For the course:
    SC42035 Integration Project Systems and Control (2019/20 Q4)
---------------------------------------------------------------------------
Inputs:
    data --> iddata object with identification experiment
    settings --> Struct with some quick access settings
        settings.nx : Initial guess for model order 
        settings.system :   Siso 1  Identify siso model on heater 1
                            Siso 2  Identify siso model on heater 2
                            Mimo    Identify Mimo model on system
%}                          


%% Settings

opt = ssestOptions( 'InitializeMethod','n4sid',...
                    'Focus','Simulation',...
                    'N4Weight','MOESP',...
                    'InitialState','estimate',...
                    'OutputOffset',[],...
                    'Display','on');
nx = settings.nx;
Ts = settings.Ts;
% Estimate room temperature from first 5 samples. 
T0 = mean(data.y(1:5,:),1);

% Append initial zeros and equilibrium 
Prefix = iddata([ones(nx,1)*T0(1), ones(nx,1)*T0(2)],...
                zeros(nx,2),Ts,...
              'OutputName', {'Temperature 1'; 'Temperature 2'},...
              'OutputUnit', {'Degree C'; 'Degree C'},...
              'InputName', {'Heater power 1'; 'Heater power 2'},...
              'InputUnit', {'%';'%'});          
data = [Prefix; data];


%% Main code
switch settings.system(end)
    case "1"
        % Check percistancy of exitation
        Ped1 = pexcit(data(:,1,1));
        
        % set system specific settings
        opt = ssestOptions( 'OutputOffset', T0(1));

        % Run N4SID and ss estimation algorithm. 
        nk = delayest(data(:,1,1));
        [ss,x0] = ssest(data(:,1,1),1:max(1,Ped1),'InputDelay',nk,opt);

    case "2"
        % Check percistancy of exitation
        Ped2 = pexcit(data(:,2,2));
        
        % set system specific settings
        opt = ssestOptions( 'OutputOffset', T0(2));
        
        % Run N4SID and ss estimation algorithm. 
        nk = delayest(data(:,2,2));
        [ss,x0] = ssest(data(:,2,2),1:max(1,Ped2),'InputDelay',nk,opt);
    case "o" 
        Ped3 = min(pexcit(data));
        
        % set system specific settings
        opt = ssestOptions( 'OutputOffset', T0');
        
        % Run N4SID and ss estimation algorithm. 
        nk1 = delayest(data(:,1,1));
        nk2 = delayest(data(:,2,2));
       
        [ss,x0] = ssest(data,1:max(1,Ped3),'InputDelay',[nk1 nk2],opt);      
 
end
end






