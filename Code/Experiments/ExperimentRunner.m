close all; clear all; clc

% include tclab.m for initialization, also includes commands to control arduino.
tclab;
disp('Experiment Runner ready')

%% ==== EXPERIMENT SETUP ==== 

% ---- Signal shaping ----

InitialRestTime  = 1;%min
PeriodSignal     = 30;%min
Multiplier       = 1;

Keyword = "Step";
H1Signal = [80,0];
H2Signal = [0,0];

H1Initial = 0;
H2Initial = 0;

if length(H1Signal) ~= length(H2Signal)
    beep on;
    beep;
    beep off;
    error('Signal arrays H1Signal and H2Signal are not of same length.');
else
    LengthExperiment = ((InitialRestTime + ...
        PeriodSignal * length(H1Signal)) * 60) ...
        * Multiplier;
end

disp('Length experiment: ' + string(LengthExperiment/60) + ' min');

% ---- Preparing arrays ----
H1Output = zeros(1,LengthExperiment);
H2Output = zeros(1,LengthExperiment);
H1Input = zeros(1,LengthExperiment);
H2Input = zeros(1,LengthExperiment);
time = linspace(1,LengthExperiment,LengthExperiment);


%% ==== EXPERIMENT ====

DoExperiment = input('Experiment good to go. Continue? (y/n) : ','s');

if DoExperiment == 'y'
    
    figure(1) %figure to see experiment running.
    
    for i = 1:LengthExperiment
        tic;
        textwaitbar(i,LengthExperiment,'Progress');
        
        % ---- Give inputs: ----
        
        if i <= (InitialRestTime*60) 
            h1(H1Initial);
            h2(H2Initial);
        else
            currentPeriod = 1 + floor((i - (InitialRestTime*60))/(PeriodSignal*60)); %select current period in signal
            if currentPeriod > length(H1Signal) %make that last step is still part of last period.
                currentPeriod = length(H1Signal);
            end
            h1(H1Signal(currentPeriod));
            h2(H2Signal(currentPeriod));
        end

        % ---- Read temperatures: ----
        t1 = T1C();
        t2 = T2C();

        % ---- LED brightness for safety: ----
        % The LED will turn on at >30degC, and increase the brightness the
        % hotter it gets. 
        brightness1 = (t1 - 30)/50.0;  % <30degC off, >100degC full brightness
        brightness2 = (t2 - 30)/50.0;  % <30degC off, >100degC full brightness
        brightness = max(brightness1,brightness2);
        brightness = max(0,min(1,brightness)); % limit 0-1
        led(brightness);

        % ---- Insert input and output into data vectors: ----
        if i <= (InitialRestTime*60) 
            H1Input(i) = 0;       
            H2Input(i) = 0;
        else
            H1Input(i) = H1Signal(currentPeriod);       
            H2Input(i) = H2Signal(currentPeriod);
        end
        H1Output(i) = t1;                  
        H2Output(i) = t2;
        
        
        % ---- Figure of results so far: ----

        clf %clear current window (for new update)
       
        subplot(2,1,1)
        plot(time(1:i),H1Output(1:i),'r.','MarkerSize',10);
        hold on
        plot(time(1:i),H2Output(1:i),'b.','MarkerSize',10);
        ylabel('Temperature (degC)')
        legend('Temperature 1','Temperature 2','Location','NorthWest')
        
        subplot(2,1,2)
        plot(time(1:i),H1Input(1:i),'r-','LineWidth',2);
        hold on
        plot(time(1:i),H2Input(1:i),'b--','LineWidth',2);
        ylabel('Heater (0-5.5 V)')
        xlabel('Time (sec)')
        legend('Heater 1','Heater 2','Location','NorthWest')
        
        drawnow;
        t = toc;
        pause(max(0.01,1.0-t)) %Synchronise to 1 sec before next for loop step.
    end

    disp('Experiment is complete.');
    disp('Turning off heaters. Caution! May still be hot!');
    h1(0);
    h2(0);

    
    %% ==== SAVING DATA ====

    disp('Saving data...');

    % ---- Preparing data for export: ----
    DateSerial = now;
    Experiment.Date = datetime(DateSerial,'ConvertFrom','datenum');

    Experiment.InitialRestTime = InitialRestTime;
    Experiment.PeriodSignal = PeriodSignal;
    Experiment.Multiplier = Multiplier;
    Experiment.H1Signal = H1Signal;
    Experiment.H2Signal = H2Signal;
    Experiment.H1Initial = H1Initial;
    Experiment.H2Initial = H2Initial;
    Experiment.LengthExperiment = LengthExperiment;

    Experiment.idd = iddata([H1Output', H2Output'], [H1Input', H2Input'], 1,...
                  'OutputName', {'Temperature 1'; 'Temperature 2'},...
                  'OutputUnit', {'Degree C'; 'Degree C'},...
                  'InputName', {'Heater power 1'; 'Heater power 2'},...
                  'InputUnit', {'%';'%'});

    % ---- Exporting data: ----
    
    H1String = sprintf('%.0f-' , H1Signal);
    H1String = H1String(1:end-1);% strip final comma
    H2String = sprintf('%.0f-' , H2Signal);
    H2String = H2String(1:end-1);% strip final comma
    
    Filename = string( ...
        Keyword + ...
        '_H1-' + H1String + ...
        '_H2-' + H2String + ...
        '_MLT' + string(Multiplier) + ...
        '_LEN' + string(LengthExperiment) + ...
        '_' + string(DateSerial) + ...
        '.mat');

    save(Filename,'Experiment');

    disp('Data saved.');
    load handel %Play success sound.
    sound(y,Fs)
end

disp('Done.');