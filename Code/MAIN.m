clear; close all
set(0,'defaulttextInterpreter','latex') 
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
makeFDSID = 0;
makeGreyBox = 1;

% Store chosen options in cell array for plotting later. 
k = 1;
methods = cell(1,3);
for i = {'makeN4SID','makeFDSID','makeGreyBox'}
    if eval(cell2mat(i)) == 1
        methods{k} = i;
    else 
        methods{k} = [];
    end
    k = k+1;
end


% ---- Arrays to store simulation data: ----
tdata = 0:length(t1s)-1;
ydata = [];

if makeN4SID
    % ---- N4SID: ---- 
    n4sid_settings.nx = 6;
    n4sid_settings.system = 'mimo';   % siso 1, siso 2, mimo          
    n4sid_settings.Ts = Ts;      

    [sys_n4sid, x0 , RoomTemp] = N4SID(idd, n4sid_settings);

    % Select appropriate input sequence
    switch n4sid_settings.system(end)
        case '1'
            u = h1s';
        case '2'
            u = h2s';
        case 'o'
            u = [h1s',h2s'];
    end
    
    % simulate system
    switch n4sid_settings.system(end)
        case '1'
            y = lsim(sys_n4sid,u,tdata,x0);
            N4SID_Sim = [y + RoomTemp, zeros(length(y),1)];  
        case '2'
            y = lsim(sys_n4sid,u,tdata,x0);
            N4SID_Sim = [zeros(length(y),1), y + RoomTemp];
        case 'o'
            y = lsim(sys_n4sid,u,tdata,x0);
            N4SID_Sim = y + RoomTemp;
    end   
end

if makeFDSID
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
    [sys_GreyBox] = FDSID(idd, init_tf, RoomTemp);
    % Simulate estimated model with identification data: 
    y = lsim(sys_GreyBox,h1s,tdata);
    FDSID_Sim = y' + RoomTemp;
end

if makeGreyBox
    GreyBox_settings.system = 'mimo';     % siso 1, siso 2, mimo           
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
    Grey.As.value         = 2e-4; 
    
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
    Grey.As.fixed         = false;

    % ---- Run GreyBox: ----
    [sys_GreyBox] = GreyBox(idd, Grey, GreyBox_settings);
    
    % Simulate estimated model with identification data: 
    switch GreyBox_settings.system(end)
        case '1'
            y = sim(sys_GreyBox,idd(:,1,1));
            GreyBox_Sim = [y.y(:), zeros(length(y.y),1)];  
        case '2'
            y = sim(sys_GreyBox,idd(:,2,2));
            GreyBox_Sim = [zeros(length(y.y),1), y.y(:)];
        case 'o'
            y = sim(sys_GreyBox,idd);
            GreyBox_Sim = y.y;
    end
end

%% ==== PLOT: ====
% ---- Switches: ----
makeFigure = 1;

if makeFigure
    for i = 1:length(methods)
        method = methods{i};
        if ~isempty(method) 
            method = char(method);
            method = method(5:end);
            ydata = eval(strcat(method,'_Sim'));
            makefigure(ydata, method,tdata, h1s, h2s, t1s, t2s, file);
        end
    end
end

disp('Done.')
