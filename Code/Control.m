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
n4sid = pade(ss(sys_n4sid),1); %Use pade approximation to convert ct ss with delay to ct ss without delay by adding more states.
fdsid = pade(minreal(ss(d2c(sys_FDSID))));
% still need to linearise the greybox model! 


% % pole zero maps:
% pzmap(n4sid)
% pzmap(fdsid)


% G = n4sid;
% Wu = 1;
% Wt = 1;
% Wp = 1;
% 
% P = [0 Wu;
%     0 G*Wu];
%     








%{
ncont = 2; 
nmeas = 2; 
[K,CL,gamma] = hinfsyn(P,nmeas,ncont);
%}