clear; close all
%{
This file serves as the main file for the integration project.  

Written by:
    Pim de Bruin 
    Marco Delgado Gosalvez

For the course:
    SC42035 Integration Project Systems and Control (2019/20 Q4)
%}

%% ==== SETUP: ====

% ---- Accessing functions from folders: ----
cd 'System Identification';
N4SID = @N4SID;
FDSID = @FDSID;
cd ../

%% ==== EXPERIMENT DATA MANAGEMENT: ====
          
% ---- Load identifiation data: ----
disp('Select data file')
[file,path]= uigetfile('*.mat');
if isequal(file,0)
    disp('no file selected')
else
    disp(['User selected: ', file]);
    load(fullfile(path,file),'h1s','h2s','t1s','t2s')
end

% ---- Write identification data into iddata structure: ----
Ts = 1;     %s
idd = iddata([t1s', t2s'], [h1s', h2s'], Ts,...
              'OutputName', {'Temperature 1'; 'Temperature 2'},...
              'OutputUnit', {'Degree C'; 'Degree C'},...
              'InputName', {'Heater power 1'; 'Heater power 2'},...
              'InputUnit', {'%';'%'});
          

%% ==== IDENTIFICATION: ====

% ---- Switches: ----
makeN4SID = 0;
makeFDSID = 1;

% ---- Arrays to store simulation data: ----
tdata = 1:length(t1s);
ydata = [];

if makeN4SID
    % ---- N4SID: ---- 
    n4sid_settings.nx = 6;
    n4sid_settings.system = 'siso 1';               % Still under construction
    n4sid_settings.Ts = Ts;      

    [ss1, x0] = N4SID(idd, n4sid_settings);

    % Simulate estimated model with identification data: 
    y = lsim(ss1,h1s,tdata,x0);
    ydata = [ydata;y'];

elseif makeFDSID
    % ---- FDSID: ----
    [sys] = FDSID(idd);
    
end

%% ==== PLOT: ====

% ---- Switches: ----
makefigure = 0;

if makefigure
    figure(1) 
    subplot(2,1,1)
        hold on
        plot(tdata,ydata)
        plot(tdata,t1s)
    subplot(2,1,2)
        hold on
        plot(tdata,h1s)
end

disp('Done.')