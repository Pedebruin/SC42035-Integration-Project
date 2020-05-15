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

% ---- Accessing folders: ----
addpath('System_Identification')

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
makeGreyBox = 0;

% ---- Arrays to store simulation data: ----
tdata = 1:length(t1s);
ydata = [];

if makeN4SID
    % ---- N4SID: ---- 
    n4sid_settings.nx = 6;
    n4sid_settings.system = 'siso 1';   % Just to prepare for future steps           
    n4sid_settings.Ts = Ts;      

    [ss1, x0 , RoomTemp] = N4SID(idd, n4sid_settings);

    % Simulate estimated model with identification data: 
    y = lsim(ss1,h1s,tdata,x0);
    ydata = [ydata;y' + RoomTemp(1)];
elseif makeFDSID
    % ---- Initial guess constructed from data: ----
    % Values found:
    K = 1/3; %TODO: Automate this process
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
    
elseif makeGreyBox
    % ---- Setup initial parameters: ----
    % Initial values:
    Grey.U.value          = 5;   % W/(m^2k)
    Grey.A.value          = 0.0012; % m^2
    Grey.Ta.value         = 23;     % Celcius
    Grey.alpha.value      = 0.01;% from % to heat flow
    Grey.m.value          = 0.004;   % kg
    Grey.cp.value         = 500;    %J/kg
    Grey.epsilon.value    = 0.9;
    Grey.sigma.value      = 5.67e-8;
    Grey.T_inf.value      = 23;
    
    % Fixed or not?
    Grey.U.fixed          = true;
    Grey.A.fixed          = false;
    Grey.Ta.fixed         = false;
    Grey.alpha.fixed      = true;
    Grey.m.fixed          = false;
    Grey.cp.fixed         = true;
    Grey.epsilon.fixed    = true;
    Grey.sigma.fixed      = true;
    Grey.T_inf.fixed      = false;

    % ---- Run GreyBox: ----
    [sys] = GreyBox(idd(:,1,1),Grey);
    % Simulate estimated model with identification data: 
    y = sim(sys,idd(:,1,1));
    ydata = [ydata; y.y(:)];   
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
