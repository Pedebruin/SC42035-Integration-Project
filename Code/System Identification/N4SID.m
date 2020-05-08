function [ss1,x0] = N4SID(data, settings)
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
                    'Display','on');
nx = settings.nx;
Ts = settings.Ts;


%% Main code
% Append initial zeros and equilibrium 
Output = data.OutputData;
Prefix = iddata([ones(nx,1)*Output(1,1), ones(nx,1)*Output(1,2)],...
                zeros(nx,2),Ts,...
              'OutputName', {'Temperature 1'; 'Temperature 2'},...
              'OutputUnit', {'Degree C'; 'Degree C'},...
              'InputName', {'Heater power 1'; 'Heater power 2'},...
              'InputUnit', {'%';'%'});          
data = [Prefix; data];


% Check percistancy of exitation
Ped1 = pexcit(data(:,1,1));

% Run N4SID and ss estimation algorithm. 
nk = delayest(data(:,1,1));
[ss1,x0] = ssest(data(:,1,1),1:Ped1,'InputDelay',nk,opt);
end






