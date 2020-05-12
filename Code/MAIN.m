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
cd 'System_Identification';
N4SID = @N4SID;
FDSID = @FDSID;
cd ../

%% ==== EXPERIMENT DATA MANAGEMENT: ====
          
% ---- Load identifiation data: ----
disp('Select data file')
[file,path]= uigetfile('Experiments/*.mat');
if isequal(file,0)
    error('No identification file has been selected')
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
    n4sid_settings.system = 'siso 1';               
    n4sid_settings.Ts = Ts;      

    [ss1, x0] = N4SID(idd, n4sid_settings);

    % Simulate estimated model with identification data: 
    y = lsim(ss1,h1s,tdata,x0);
    ydata = [ydata;y'];

elseif makeFDSID
    % ---- Initial guess constructed from data: ----
    % Values found:
    K = 1/3;
    d = 15;
    tau = 47;
    init_tf = tf(K,[tau 1],'InputDelay',d);
    % Simulate with rough estimate:
    RoomTemp = idd.OutputData(1,1);
    y = lsim(init_tf,h1s,tdata); 
    ydata = [ydata; y' + RoomTemp];
    
    % ---- FDSID: ----
    [sys] = FDSID(idd, init_tf, RoomTemp);
    % Simulate estimated model with identification data: 
    y = lsim(sys,h1s,tdata);
    ydata = [ydata; y' + RoomTemp];
end

%% ==== PLOT: ====

% ---- Switches: ----
makefigure = 1;

if makefigure
    % ---- Figure setup: ----
    fig = figure(1); 
    ax1 = subplot(2,1,1);
    ax2 = subplot(2,1,2);
    hold(ax1, "on");
    hold(ax2, "on");
    
    % ---- Plots: ----
    title(ax1,"Output")
    plot(ax1,tdata,ydata, 'DisplayName', 'Simulation')
    plot(ax1,tdata,t1s, 'DisplayName', 'Data')
    ylim(ax1,[0 inf])
    xlabel(ax1,"Time in [s]")
    ylabel(ax1,"Sensors tempererature in [ºC]")
    legend(ax1, 'Location', 'east')
    
    title(ax2,"Input")
    plot(ax2,tdata,h1s, 'DisplayName', 'Heater 1')
    ylim(ax2,[0 100])
    xlabel(ax2,"Time in [s]")
    ylabel(ax2,"Input heaters in [%]")
    legend(ax2)
end

disp('Done.')
