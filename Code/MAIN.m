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
disp('Select identification data file')
[file,path]= uigetfile('Experiments/*.mat');
if isequal(file,0)
    error('No identification file has been selected')
else
    disp(['    User selected: ', file]);
    load(fullfile(path,file),'Experiment');
    
    % Write into appropriate struct
    idd_i = Experiment.idd;
    lengthExperiment = Experiment.LengthExperiment;
end


%% ==== IDENTIFICATION: ====

% ---- Switches: ----
maken4sid = 1;
makeFDSID = 0;
makeGreyBox = 0;


% Store chosen options in cell array for plotting later. 
k = 1;
methods = cell(1,3);
for i = {'maken4sid','makeFDSID','makeGreyBox'}
    if eval(cell2mat(i)) == 1
        methods{k} = char(i);
        methods{k} = methods{k}(5:end);
    else 
        methods{k} = [];
    end
    k = k+1;
end

% ---- Arrays to store simulation data: ----
tdata = 0:lengthExperiment-1;
ydata = [];
T0 = mean(idd_i.y(1:55,:),1);

if maken4sid
    % ---- N4SID: ---- 
    disp('Estimation: N4SID')
    n4sid_settings.nx = 6;
    n4sid_settings.system = 'mimo';   % siso 1, siso 2, mimo          
    n4sid_settings.Ts = idd_i.Ts;  
    n4sid_settings.T0 = T0;

    [sys_n4sid, x0 , T0_n4sid] = N4SID(idd_i, n4sid_settings);
end

if makeFDSID
    disp('Estimation: FDSID')
    
    % ---- FDSID: ----
    FDSID_settings.system = 'siso 1'; % siso 1, siso 2, mimo
    FDSID_settings.T0 = T0;
    [sys_FDSID] = FDSID(idd_i, FDSID_settings);

end

if makeGreyBox
    disp('Estimation: GreyBox')
    GreyBox_settings.system = 'mimo';     % siso 1, siso 2, mimo   
    GreyBox_settings.T0 = T0;
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
    [sys_GreyBox] = GreyBox(idd_i, Grey, GreyBox_settings);
end




%% ==== MODEL VALIDATION: ====
makeFigure = 1;

% ---- Select validation set: ----
disp('Select validation data file:')
[file,path]= uigetfile('Experiments/*.mat');
if isequal(file,0)
    error('No validation file has been selected')
else
    disp(['    User selected: ', file]);
    load(fullfile(path,file),'Experiment');
    
    % Write into appropriate struct
    idd_v = Experiment.idd;
end

% ---- Simulate systems using validation dataset: ----
if maken4sid
    disp('Simulating n4sid')
    switch n4sid_settings.system(end)
        case '1'
            y = lsim(sys_n4sid, idd_v.u(:,1), tdata, x0);
            n4sid_Sim = [y + T0_n4sid', zeros(length(y),1)];  
        case '2'
            y = lsim(sys_n4sid, idd_v.u(:,2), tdata, x0);
            n4sid_Sim = [zeros(length(y),1), y + T0_n4sid'];
        case 'o'
            y = lsim(sys_n4sid, idd_v.u, tdata, x0);
            n4sid_Sim = y + T0_n4sid';
    end   
end

if makeFDSID
    disp('Simulating FDSID')
    switch FDSID_settings.system(end)
        case '1'
            y = lsim(sys_FDSID, idd_v.u(:,1), tdata);
            FDSID_Sim = [y + T0, zeros(length(y),1)];  
        case '2'
            y = lsim(sys_FDSID, idd_v.u(:,2), tdata);
            FDSID_Sim = [zeros(length(y),1), y + T0];
        case 'o'
            y = lsim(sys_FDSID, idd_v.u, tdata);
            FDSID_Sim = y + T0;
    end   
end

if makeGreyBox
    disp('Simulating GreyBox')
    switch GreyBox_settings.system(end)
        case '1'
            y = sim(sys_GreyBox, idd_v(:,1,1));
            GreyBox_Sim = [y.y(:), zeros(length(y.y),1)];  
        case '2'
            y = sim(sys_GreyBox, idd_v(:,2,2));
            GreyBox_Sim = [zeros(length(y.y),1), y.y(:)];
        case 'o'
            y = sim(sys_GreyBox, idd_v);
            GreyBox_Sim = y.y;
    end
end



% Evaluate performance of simulated systems and plot
for i = 1:length(methods)                   % for every possible method
    method = methods{i};
    if ~isempty(method)                     % if method is used   
        
        sys = eval(strcat('sys_',method));  % identified model
        Sim = eval(strcat(method,'_Sim'));  % Simulation result
        
        [fit] = analysePerformance(sys, idd_v, Sim);   % get validation results
        
        if makeFigure
            makefigure(method, Sim, idd_v, tdata, fit);    % make plot
        end
    end
end



load handel %Play success sound.
sound(y,Fs)
disp('Done.')
