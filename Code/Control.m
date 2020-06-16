clear; close all
set(0,'defaulttextInterpreter','latex') 
%{
This file serves as the main file for the control part of the integration project.  

Written by:
    Pim de Bruin 
    Marco Delgado Gosalvez

For the course:
    SC42035 Integration Project Systems and Control (2019/20 Q4)
%}
%% ==== SETTINGS: ====

%% ==== SETUP: ====
% ---- Accessing folders: ----
addpath('System_Identification')
addpath('Controller_Design')
addpath('System_Identification/Models')
addpath('Functions')

% ---- Loading models: ----
n4sid_file = dir('.\System_Identification\Models\FINAL\n4sid*.mat');
fdsid_file = dir('.\System_Identification\Models\FINAL\fdsid*.mat');
GreyBox_file = dir('.\System_Identification\Models\FINAL\GreyBox*.mat');

load(n4sid_file.name)
load(fdsid_file.name)
load(GreyBox_file.name)

% ---- Get workable models: ----
n4sid = pade(ss(sys_n4sid),1); %Use pade approximation to convert ct ss with delay to ct ss without delay by adding more states.
fdsid = pade(minreal(ss(d2c(sys_FDSID))));
% still need to linearise the greybox model! 

% ---- Choose plant to use: ----
G = n4sid;
%G = fdsid;

% .... Pole zero plots: ....
makePZmap = 0;
if makePZmap
    figure(2);
    %pzmap(G);          %continuous pzmap.
    pzmap(c2d(G,1));   %discrete pzmap.
    axis equal;
end

% ---- Choose controller: ----
controller_hinf = 1;
controller_lqr = 0;

%% ==== CHECK PLANT PROPERTIES: ====

% ---- Controllability: ----
Nr_uncontrollable_states = length(G.A) - rank(ctrb(G.A,G.B));
disp(string(Nr_uncontrollable_states) + ' uncontrollable states.');

% ---- Observability: ----
Nr_unobservable_states = length(G.C) - rank(obsv(G.A,G.C));
disp(string(Nr_unobservable_states) + ' unobservable states.');


%% ==== SETTINGS: ==== 
    rs = [50;40];

%% ==== LQR: ====
if controller_lqr
    r = [50;40];
    Plant = G;
    LQRd(Plant,r,'makeSimulation',true);
end

%% ==== HINF: ====
if controller_hinf
    % Can still use the continuous time system. The command used is
    % sdhinfsyn, which samples the system itself. So the controller is
    % still a discrete time controller K. 
    [K_Hinf, K_Musyn] = Hinf(G);
    
        % ---- Simulate system: ----
    T = 600;  % s
    Gd = c2d(G,1,'zoh');
    
    T0 = G.UserData;
    R = (rs' - T0');
    K = K_Hinf;
    
    simOut = sim('System','StartTime','0','StopTime',num2str(T));  
    y = simOut.get('y') + T0';
    u = simOut.get('u');
    tdata = simOut.get('tout');
    Simulink.sdi.clear
    
    
    % ---- Figure setup: ----
    fig = figure('Name','Control'); 
    sgtitle('Method: Hinf', 'Interpreter','latex');
    ax11 = subplot(2,1,1);
    ax12 = subplot(2,1,2);
    hold(ax11, "on");
    hold(ax12, "on");
 

    % ---- Plots: ----
    title(ax11,'Output Heater 1')
    stairs(ax11,tdata,y(:,1),'r', 'DisplayName', 'Hinf')
    yline(ax11,rs(1),'m-','DisplayName','r(1)')
    ylim(ax11,[-1 60])
    xlabel(ax11,"Time in [s]")
    ylabel(ax11,"Sensor 1 tempererature in [C]")
    legend(ax11, 'Location', 'northeast')

    title(ax11,'output Heater 2')
    stairs(ax11,tdata,y(:,2),'b', 'DisplayName', 'Hinf')
    ylim(ax11,[-1 60])
    yline(ax11,rs(2),'c-','DisplayName','r(2)')
    xlabel(ax11,"Time in [s]")
    ylabel(ax11,"Sensor 1 tempererature in [C]")

    title(ax12,"Input heater 1")
    stairs(ax12,tdata,u(:,1),'r', 'DisplayName', 'Heater 1')
    ylim(ax12,[-1 101])
    xlabel(ax12,"Time in [s]")
    ylabel(ax12,"Input heater 1 in [\%]")
    legend(ax12)

    title(ax12,"Input heater 2")
    stairs(ax12,tdata,u(:,2),'b', 'DisplayName', 'Heater 2')
    ylim(ax12,[-1 101])
    xlabel(ax12,"Time in [s]")
    ylabel(ax12,"Input heater 2 in [\%]")
end
