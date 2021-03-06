clear; close all
set(0,'defaulttextInterpreter','latex') 
%{
This file serves as the main file for the identification part of the integration project.  

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
addpath('System_Identification/Functions')

% ---- Settings: ----
identification = 0;         % Identify models?
Validation = 1;             % Validate models?
    maken4sid   = 1;        % Use N4SID?
    makeFDSID   = 0;        % Use FDSID?
    makeGreyBox = 0;        % Use Grey Box?
makeFigure = 1;             % Plot the result?
    
system = 'mimo';            % siso 1, siso 2, mimo?



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

%% ==== IDENTIFICATION: ====
if identification
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
    end

    % pre processing ====
        % bandwidth is about 7e-4 Hz.
    idd_i.y = lowpass(idd_i.y,5e-3,1); % filter at 5e-3, actual bandwidth is 1e-3, so all good. 

    % ---- Arrays to store simulation data: ----
    ydata = [];
    T0 = mean(idd_i.y(1:55,:),1);

    if maken4sid
        % ---- N4SID: ---- 
        disp('Estimation: N4SID')
        N = 20;                            % till what order do you want to estimate the model?
        n4sid_settings.system = system;     % siso 1, siso 2, mimo          
        n4sid_settings.Ts = idd_i.Ts;  
        n4sid_settings.T0 = T0;
      
        orderPlot = 0;
        
        if orderPlot
            % fit multiple order models to get the fit percentage per order
            fits = zeros(2,N);
            vaf = zeros(1,N);
            for i = 1:N
                n4sid_settings.nx = i;    
                [sys_n4sid, x0_n4sid , T0_n4sid] = N4SID(idd_i, n4sid_settings);
                fits(:,i) = sys_n4sid.Report.Fit.FitPercent;
            end

            % plot fit percentage per order
            figure 
            hold on
            plot(1:N,mean(fits,1),'o')
        end

        % Do actual estimation with variable model oder, select based on
        % last figure and singular value plot!
        n4sid_settings.nx = 1:N;
        [sys_n4sid, x0_n4sid , T0_n4sid] = N4SID(idd_i, n4sid_settings);

        save(strcat('./System_Identification/Models/n4sid_',file),'sys_n4sid');
    end

    if makeFDSID
        disp('Estimation: FDSID')

        % ---- FDSID: ----
        FDSID_settings.system = system; % siso 1, siso 2, mimo
        FDSID_settings.T0 = T0;
        FDSID_settings.Ts = idd_i.Ts; 
        [sys_FDSID] = FDSID(idd_i, FDSID_settings);
        

        save(strcat('./System_Identification/Models/fdsid_',file),'sys_FDSID');
    end

    if makeGreyBox
        disp('Estimation: GreyBox')
        GreyBox_settings.system = system;     % siso 1, siso 2, mimo   
        GreyBox_settings.T0 = T0;
        % ---- Setup initial parameters: ----
        % Initial values:
        Grey.U.value          = 5;      % W/(m^2k)
        Grey.A.value          = 0.0012; % m^2
        Grey.Ta.value         = 23;     % Celcius
        Grey.alpha.value      = 0.01;   % from % to heat flow
        Grey.m.value          = 0.004;  % kg
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


        save(strcat('./System_Identification/Models/GreyBox_',file),'sys_GreyBox');
    end
end



%% ==== MODEL VALIDATION: ====
if Validation 
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
        lengthExperiment = Experiment.LengthExperiment;
    end
    tdata = 0:lengthExperiment-1;
    T0 = mean(idd_v.y(1:55,:),1);

    
    % Filtering
    % idd_v.y = lowpass(idd_v.y,5e-3,1);



    % ---- Simulate systems using validation dataset: ----
    if maken4sid
        
        % if it is not generated previously, select it from other models. 
        if ~exist('sys_n4sid')
            disp('select n4sid model')
            [file,path]= uigetfile('System_Identification/Models/n4sid*.mat');
            if isequal(file,0)
                error('No model has been selected')
            else
                disp(['     User selected: ', file]);
                load(fullfile(path,file),'sys_n4sid');
                x0_n4sid = sys_n4sid.Report.Parameters.X0;
            end
        end
            
        disp('Simulating n4sid')
        switch system(end)
            case '1'
                y = lsim(sys_n4sid, idd_v.u(:,1), tdata, x0_n4sid);
                n4sid_Sim = [y + T0(1), zeros(length(y),1)];  
            case '2'
                y = lsim(sys_n4sid, idd_v.u(:,2), tdata, x0_n4sid);
                n4sid_Sim = [zeros(length(y),1), y + T0(2)'];
            case 'o'
                y = lsim(sys_n4sid, idd_v.u, tdata, x0_n4sid);
                n4sid_Sim = y + T0;
        end   
    end

    
    
    if makeFDSID
        
        % if it is not generated previously, select it from other models. 
        if ~exist('sys_FDSID')
            disp('select FDSID model')
            [file,path]= uigetfile('System_Identification/Models/fdsid*.mat');
            if isequal(file,0)
                error('No model has been selected')
            else
                disp(['     User selected: ', file]);
                load(fullfile(path,file),'sys_FDSID');
            end
        end
        
        disp('Simulating FDSID')
        switch system(end)
            case '1'
                y = lsim(sys_FDSID, idd_v.u(:,1), tdata);
                FDSID_Sim = [y + T0(1), zeros(length(y),1)];  
            case '2'
                y = lsim(sys_FDSID, idd_v.u(:,2), tdata);
                FDSID_Sim = [zeros(length(y),1), y + T0(2)];
            case 'o'
                y = lsim(sys_FDSID, idd_v.u, tdata);
                FDSID_Sim = y + T0; 
        end   
    end

    
    
    if makeGreyBox
        
        % if it is not generated previously, select it from other models. 
        if ~exist('sys_GreyBox')
            disp('select GreyBox model')
            [file,path]= uigetfile('System_Identification/Models/GreyBox*.mat');
            if isequal(file,0)
                error('No model has been selected')
            else
                disp(['     User selected: ', file]);
                load(fullfile(path,file),'sys_GreyBox');
            end
        end
        
        disp('Simulating GreyBox')
        switch system(end)
            case '1'
                y = sim(sys_GreyBox, idd_v(:,1,1), T0');
                GreyBox_Sim = [y.y(:), zeros(length(y.y),1)];  
            case '2'
                y = sim(sys_GreyBox, idd_v(:,2,2), T0');
                GreyBox_Sim = [zeros(length(y.y),1), y.y(:)];
            case 'o'
                y = sim(sys_GreyBox, idd_v, T0');
                GreyBox_Sim = y.y;
        end
    end


    % Evaluate performance of simulated systems and plot
    for i = 1:length(methods)                   % for every possible method
        method = methods{i};
        if ~isempty(method)                     % if method is used   

            sys = eval(strcat('sys_',method));  % identified model
            Sim = eval(strcat(method,'_Sim'));  % Simulation result

            [fit] = analysePerformance(sys, idd_v, Sim, makeFigure);   % get validation results

            if makeFigure
                makefigure(method, Sim, idd_v, tdata, fit);    % make plot
            end
        end
    end
end


% % load handel %Play 'hallelujah' sound.
% load gong   %Play 'gong' sound.
% sound(y,Fs)
% disp('Done.')
