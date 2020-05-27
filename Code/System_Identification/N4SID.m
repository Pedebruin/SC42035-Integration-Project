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


nx = settings.nx;
Ts = settings.Ts;
% Estimate room temperature from first 5 samples. 
T0 = settings.T0';


%% Main code
switch settings.system(end)
    case "1"
        % Check percistancy of exitation
        Ped1 = pexcit(data(:,1,1));
        
        % set system specific settings
        opt = ssestOptions( 'InitializeMethod','n4sid',...
                    'Focus','Simulation',...
                    'N4Weight','MOESP',...
                    'InitialState','estimate',...
                    'OutputOffset',T0(1),...
                    'Display','on',...
                    'N4Horizon',[75 0 20]);

        % Run N4SID and ss estimation algorithm. 
        nk = delayest(data(:,1,1));
        [ss,x0] = ssest(data(:,1,1),1:max(1,Ped1),'InputDelay',nk,opt);

    case "2"
        % Check percistancy of exitation
        Ped2 = pexcit(data(:,2,2));
        
        % set system specific settings
        opt = ssestOptions( 'InitializeMethod','n4sid',...
                    'Focus','Simulation',...
                    'N4Weight','MOESP',...
                    'InitialState','estimate',...
                    'OutputOffset',T0(2),...
                    'Display','on',...
                    'N4Horizon',[75 0 20]);
        
        % Run N4SID and ss estimation algorithm. 
        nk = delayest(data(:,2,2));
        [ss,x0] = ssest(data(:,2,2),1:max(1,Ped2),'InputDelay',nk,opt);
    case "o" 
        Ped = min(pexcit(data));
        
        % set system specific settings
        opt = ssestOptions( 'InitializeMethod','n4sid',...
                    'Focus','Simulation',...
                    'N4Weight','MOESP',...
                    'InitialState','estimate',...
                    'OutputOffset',T0,...
                    'Display','on',...
                    'N4Horizon',[75 0 20]);
        
        % Run N4SID and ss estimation algorithm. 
        nk1 = delayest(data(:,1,1));
        nk2 = delayest(data(:,2,2));
       
        [ss,x0] = ssest(data,min(Ped,nx),'InputDelay',[nk1 nk2],opt);      
 
end
end






