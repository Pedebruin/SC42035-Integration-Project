clear; close all
%{
This file serves as the main file for the integration project.  

Written by:
    Pim de Bruin 
    Marco Delgado Gosalvez

For the course:
    SC42035 Integration Project Systems and Control (2019/20 Q4)
%}

%% Setup


          
%% Identification
% Load identifiation data
disp('Select data file')
[file,path]= uigetfile('Experiments/*.mat');
if isequal(file,0)
    error('No identification file has been selected')
else
    disp(['User selected: ', file]);
    load(fullfile(path,file),'h1s','h2s','t1s','t2s')
end

% Write identification data into iddata structure
Ts = 1;     %s
idd = iddata([t1s', t2s'], [h1s', h2s'], Ts,...
              'OutputName', {'Temperature 1'; 'Temperature 2'},...
              'OutputUnit', {'Degree C'; 'Degree C'},...
              'InputName', {'Heater power 1'; 'Heater power 2'},...
              'InputUnit', {'%';'%'});
                  
% N4SID 
n4sid_settings.nx = 6;
n4sid_settings.system = 'Siso 1';               % 'Siso 1', 'Siso 2', 'Mimo'
n4sid_settings.Ts = Ts;      
          
[ss1, x0] = N4SID(idd, n4sid_settings);







%% From here still a bit of a mess, but will fix that later. 

% Simulate estimated model with identification data. 
t = 1:length(t1s);
y = lsim(ss1,h1s,t,x0);

% Plot
figure 
subplot(2,1,1)
    hold on
    plot(t,y)
    plot(t,t1s)
subplot(2,1,2)
    hold on
    plot(t,h1s)