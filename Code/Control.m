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
n4sid = pade(ss(sys_n4sid),1);
fdsid = minreal(pade(ss(sys_n4sid)));
% still need to linearise the greybox model! 


% ---- Choose plant to use: ----
G = n4sid;
%G = fdsid;


%% ==== HINF: ====
% ---- Set up generalised plant: ----
s= tf([1 0],1);
bw = 7e-3*2*pi;       % Bandwidth for each output [rad/s]
M_1 = 1.8;          % Upper bound for Hinf norm
A_1 = 1e-4;         % Attenuation of low frequency disturbances  
W_p = (s/M_1 + bw)/(s + bw*A_1);




Wp = [W_p 0; 0 W_p];            % ideal sensitivity function S
Wu = tf(eye(2));                % ideal control input signal U
Wt = tf(eye(2));                % ideal transfer function T

P = minreal([zeros(2) Wu;
            zeros(2) Wt*G;
            Wp -Wp*G;
            eye(2) -G]);
          
% ---- Compute hinf controller: ----        
ncont = 2; 
nmeas = 2; 
[K,~,~] = hinfsyn(P,nmeas,ncont);

% ---- Simulate system: ----
r = [45 37];                % Degree C
T = 1500;                   % s


T0 = G.UserData;
R = (r - T0');

simOut = sim('System','StartTime','0','StopTime',num2str(T));  
y = simOut.get('y') + T0';
u = simOut.get('u');
tdata = simOut.get('tout');
Simulink.sdi.clear



% ---- Figure setup: ----
fig = figure('Name','Control'); 
sgtitle('Method: Hinf', 'Interpreter','latex');
ax11 = subplot(2,2,1);
ax12 = subplot(2,2,2);
ax21 = subplot(2,2,3);
ax22 = subplot(2,2,4);
hold(ax11, "on");
hold(ax12, "on");
hold(ax21, "on");
hold(ax22, "on");

% ---- Plots: ----
title(ax11,'Output Heater 1')
plot(ax11,tdata,y(:,1), 'DisplayName', 'Hinf')
yline(ax11,r(1),'--')
ylim(ax11,[-1 101])
xlabel(ax11,"Time in [s]")
ylabel(ax11,"Sensor 1 tempererature in [C]")
legend(ax11, 'Location', 'northeast')

title(ax12,'output Heater 2')
plot(ax12,tdata,y(:,2), 'DisplayName', 'Hinf')
ylim(ax12,[-1 101])
yline(ax12,r(2),'--')
xlabel(ax12,"Time in [s]")
ylabel(ax12,"Sensor 1 tempererature in [C]")
legend(ax12, 'Location', 'northeast')            

title(ax21,"Input heater 1")
plot(ax21,tdata,u(:,1), 'DisplayName', 'Heater 1')
ylim(ax21,[-1 101])
xlabel(ax21,"Time in [s]")
ylabel(ax21,"Input heater 1 in [\%]")
legend(ax21)

title(ax22,"Input heater 2")
plot(ax22,tdata,u(:,2), 'DisplayName', 'Heater 2')
ylim(ax22,[-1 101])
xlabel(ax22,"Time in [s]")
ylabel(ax22,"Input heater 2 in [\%]")
legend(ax22)
