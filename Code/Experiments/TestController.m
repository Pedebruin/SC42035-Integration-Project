close all; clear all; clc

tclab; % include tclab.m for initialization, also includes commands to control arduino.
disp('Arduino initialisation complete.')

%% ==== CONTROLLER SETUP: ====

% ---- Accessing folders: ----
addpath('..\System_Identification')
addpath('..\Controller_Design')
addpath('..\System_Identification\Models')
addpath('..\Functions')

% ---- Loading model: ----
TypeModel = 'n4sid';

switch TypeModel
    case 'n4sid'
        disp('Model chosen: n4sid');
        n4sid_file = dir('..\System_Identification\Models\FINAL\n4sid*.mat');
        load(n4sid_file.name);
        sys = pade(ss(sys_n4sid));
        sysd = c2d(sys,1);
    case 'fdsid'
        disp('Model chosen: fdsid');
        fdsid_file = dir('..\System_Identification\Models\FINAL\fdsid*.mat');
        load(fdsid_file.name);
        sysd = pade(minreal(ss(sys_FDSID)));
        sys = d2c(sysd);
    case 'greybox'
        disp('Model chosen: greybox');
        GreyBox_file = dir('..\System_Identification\Models\FINAL\GreyBox*.mat');
        load(GreyBox_file.name);
        error('Greybox still not available...');
    otherwise
        error('Unknown model. Insert valid name.');
end


% ---- Loading controller parameters: ----
TypeController = 'lqr';

switch TypeController
    case 'lqr'
        disp('Controller chosen: LQR');
        [L,F] = LQRd(sys,[0;0]); %gains + feedback parameters.
        xhat_k0 = [0,0,0,0,0]'; %observer initialisation.
    case 'hinf'
        disp('Controller chosen: HINF');
        error('HINF not ready yet.');
    otherwise
        error('Unknown controller. Insert valid name.');
end

%% ==== TEST SETUP ==== 

% ---- Signal shaping ----
TypeSignal       = 'step'; %Options: step, prbs
InitialRestTime  = 1;%min
PeriodSignal     = 10;%min
Multiplier       = 1;

switch TypeSignal
    case 'step'
        H1Ref = [ 50, 40]; %reference signal without multiplier.
        H2Ref = [ 40, 50]; %reference signal without multiplier.
        
        if length(H1Ref) ~= length(H2Ref)
            error('Signal arrays H1Signal and H2Signal are not of same length.');
        else
            LengthTest = ((InitialRestTime + ...
                PeriodSignal * length(H1Ref)) * 60) ...
                * Multiplier;
        end
    case 'prbs'
        Range = [0 50];         %make prbs go between 0% and 50% input.
        MinNrUnchanged = 200;   %min nr. of steps the prbs does not change, should be > time constant.
        Band = [0 1/MinNrUnchanged];
        LengthTest = (InitialRestTime + PeriodSignal * Multiplier)*60;
        
        prbsSignal = idinput([LengthTest,2], 'prbs', Band, Range); % prbs signal for 2 channels without multiplier.
        H1Ref = prbsSignal(:,1)';
        H2Ref = prbsSignal(:,2)'; 
    otherwise
        error('Not a valid signal type. Change TypeSignal variable.');
end

% ---- Preparing arrays ----
H1Initial = 0;
H2Initial = 0;
H1Ref = repmat(H1Ref,1,Multiplier); %repeating the reference signals by the number set by multiplier.
H2Ref = repmat(H2Ref,1,Multiplier); %repeating the reference signals by the number set by multiplier.

H1Input     = zeros(1,LengthTest);
H2Input     = zeros(1,LengthTest);
H1Output    = zeros(1,LengthTest);
H2Output    = zeros(1,LengthTest);

H1RefInput  = zeros(1,LengthTest);
H2RefInput  = zeros(1,LengthTest);
H1hatOutput = zeros(1,LengthTest);
H2hatOutput = zeros(1,LengthTest);

time = linspace(1,LengthTest,LengthTest);


%% ==== TEST RUNNER: ====
disp('Length experiment: ' + string(LengthExperiment/60) + ' min');
DoTest = input('Test good to go. Continue? (y/n) : ','s');

if DoTest == 'y'
    
    figure(1) %figure to see experiment running.
    
    for i = 1:LengthTest
        tic;
        textwaitbar(i,LengthTest,'Progress');
        
        % ---- Check what reference to follow from list: ----
        switch TypeSignal
            case 'step'
                currentPeriod = 1 + floor((i - (InitialRestTime*60))/(PeriodSignal*60)); %select current element in signal array.
                if currentPeriod > length(H1Ref) %make that last step is still part of last period/element.
                    currentPeriod = length(H1Ref);
                end
            case 'prbs'
                currentPeriod = i - InitialRestTime * 60;
        end

        % ---- Activate Controller: ----
        switch TypeController
            case 'lqr'
                % ---- Apply input: ----
                if i < max(InitialRestTime*60,10) %for safety of observer, give time to adjust + temperature read.
                    u_k0 = [H1Initial;H2Initial];
                elseif i == max(InitialRestTime*60,10)
                    oldPeriod = 0;
                    T0 = mean([H1Output(1:i),H2Output(1:i)]);
                else
                    %Calculate Target:
                    if oldPeriod ~= currentPeriod
                        oldPeriod = currentPeriod;
                        [~,~,xref,uref] = LQRd(sys,[H1Ref(oldPeriod);H2Ref(oldPeriod)]-T0); %calculate target.
                    end
                    %Feedback:
                    u_k0 = -F*(xhat_k0 - xref) + uref;
                    u_k0 = min(100, max(0, u_k0)); %Input saturation.
                end
                h1(u_k0(1));
                h2(u_k0(2));

                % ---- Read temperatures: ----
                t1 = T1C();
                t2 = T2C();
                y_k0 = [t1;t2];

                % ---- Observer: ----
                yhat_k0 = sysd.C*xhat_k0 + sysd.D*u_k0;
                xhat_k1 = sysd.A*xhat_k0 + sysd.B*u_k0 + L*(y_k0 - yhat_k0);

                % ---- Prepare next iteration: ----
                xhat_k0 = xhat_k1;
            case 'hinf'
                error('HINF controller not finished yet. Cannot give feedback.');
        end
            

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
            H1Input(i) = H1Initial;       
            H2Input(i) = H2Initial;
            H1RefInput(i) = H1Initial;       
            H2RefInput(i) = H2Initial;
        else
            H1Input(i) = u_k0(1);       
            H2Input(i) = u_k0(2);
            H1RefInput(i) = H1Ref(currentPeriod);       
            H2RefInput(i) = H2Ref(currentPeriod);
        end
        H1Output(i) = t1;                  
        H2Output(i) = t2;
        H1hatOutput(i) = yhat_k0(1);
        H2hatOutput(i) = yhat_k0(2);
        
        % ---- Figure of results so far: ----

        clf %clear current window (for new update)
       
        subplot(2,1,1)
        hold on
        plot(time(1:i),H1Output(1:i),'r.','MarkerSize',10,'DisplayName','Output 1');
        plot(time(1:i),H2Output(1:i),'b.','MarkerSize',10,'DisplayName','Output 2');
        plot(time(1:i),H1hatOutput(1:i),'r-','MarkerSize',1,'DisplayName','Observer 1');
        plot(time(1:i),H2hatOutput(1:i),'b-','MarkerSize',1,'DisplayName','Observer 2');
        plot(time(1:i),H1RefInput(1:i),'m-','DisplayName','Reference 1');
        plot(time(1:i),H2RefInput(1:i),'c-','DisplayName','Reference 2');
        ylabel('Temperature (degC)')
        legend('Location','NorthWest')
        
        subplot(2,1,2)
        hold on
        plot(time(1:i),H1Input(1:i),'r-','LineWidth',2,'DisplayName','Input 1');
        plot(time(1:i),H2Input(1:i),'b-','LineWidth',2,'DisplayName','Input 2');
        ylabel('Heater (0-5.5 V)')
        xlabel('Time (sec)')
        legend('Location','NorthWest')
        
        drawnow;
        t = toc;
        pause(max(0.01,1.0-t)) %Synchronise to 1 sec before next for loop step.
    end

    disp('Experiment is complete.');
    disp('Turning off heaters. Caution! May still be hot!');
    h1(0);
    h2(0);
    led(0); %Turning off led.

    
    %% ==== SAVING DATA ====

    disp('Saving data...');

    % ---- Preparing data for export: ----
    DateSerial = now;
    Test.Date = datetime(DateSerial,'ConvertFrom','datenum');
    
    Test.TypeController = TypeController;
    Test.TypeModel = TypeModel;
    Test.TypeSignal = TypeSignal;
    Test.InitialRestTime = InitialRestTime;
    Test.PeriodSignal = PeriodSignal;
    Test.Multiplier = Multiplier;
    Test.H1Ref = H1Ref;
    Test.H2Ref = H2Ref;
    Test.H1Initial = H1Initial;
    Test.H2Initial = H2Initial;
    Test.LengthExperiment = LengthTest;
    
    if strcmp(TypeSignal,'prbs') %added fields if prbs signal.
        Test.Range = Range;
        Test.MinNrUnchanged = MinNrUnchanged;
        Test.Band = Band;
    end
    
    Test.idd = iddata([H1Output', H2Output',H1hatOutput',H2hatOutput'],...
                  [H1Input', H2Input',H1RefInput', H2RefInput'], 1,...
                  'OutputName', {'Temperature 1'; 'Temperature 2'; 'Observer 1'; 'Observer 2'},...
                  'OutputUnit', {'Degree C'; 'Degree C'; 'Degree C'; 'Degree C'},...
                  'InputName', {'Heater power 1'; 'Heater power 2'; 'Heater reference 1'; 'Heater reference 2'},...
                  'InputUnit', {'%';'%';'%';'%'});

    % ---- Exporting data: ----
    
    switch TypeSignal
        case 'step'
            H1RefString = sprintf('%.0f-' , H1Ref);
            H1RefString = H1RefString(1:end-1);% strip final comma
            H2RefString = sprintf('%.0f-' , H2Ref);
            H2RefString = H2RefString(1:end-1);% strip final comma
            
            Filename = string( ...
                string(TypeController) + ...
                '_' + string(TypeModel) + ...
                '_' + string(TypeSignal) + ...
                '_R1-' + H1RefString + ...
                '_R2-' + H2RefString + ...
                '_MLT' + string(Multiplier) + ...
                '_LEN' + string(LengthTest) + ...
                '_' + string(DateSerial) + ...
                '.mat');
            
        case 'prbs'
            RangeString = sprintf('%.0f-' , Range);
            MinString = sprintf('%.0f-' , MinNrUnchanged);
            
            Filename = string( ...
                string(TypeController) + ...
                '_' + string(TypeModel) + ...
                '_' + string(TypeSignal) + ...
                '_Range' + RangeString(1:end-1) + ...
                '_Min' + MinString(1:end-1) + ...
                '_MLT' + string(Multiplier) + ...
                '_LEN' + string(LengthTest) + ...
                '_' + string(DateSerial) + ...
                '.mat');
        
    end     
    
    save(Filename,'Test');

    disp('Data saved.');
    load handel %Play success sound.
    sound(y,Fs)
else
    disp('Experiment cancelled.')
end

disp('Done.');