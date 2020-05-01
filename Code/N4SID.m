clear; close all
%{ 
This file fits a nth order model to a dataset using the N4SID subspace
identification method. 

Written by:
    Pim de Bruin 
    Marco Delgado Gosalvez

For the course:
    SC42035 Integration Project Systems and Control (2019/20 Q4)
%}

%% Settings
Nx = 4;


%% Main code
disp('Select data file')
[file,path]= uigetfile('*.mat');
if isequal(file,0)
    disp('no file selected')
else
    disp(['User selected: ', file]);
    load(fullfile(path,file),'h1s','h2s','t1s','t2s')
end

% Append initial zeros and equilibrium temperature
h1s = [zeros(1,Nx), h1s];
h2s = [zeros(1,Nx), h2s];
t1s = [ones(1,Nx)*t2s(1), t1s];
t2s = [ones(1,Nx)*t2s(1), t2s];

% Write into iddata structures
data1 = iddata(t1s', h1s', 1, 'OutputName', 'Temperature 1', 'InputName', 'Heater power 1');
data2 = iddata(t2s', h2s', 1, 'OutputName', 'Temperature 2', 'InputName', 'Heater power 2');

% Check percistancy of exitation
Ped1 = pexcit(data1);
Ped2 = pexcit(data2);

% Run N4SID algorithm. 
opt= n4sidOptions('Focus','Simulation','N4Weight','MOESP');
[Tf1,x0] = n4sid(data1,Nx,opt);


% Simulate estimated model
t = 1:length(t1s);
y = lsim(Tf1,h1s,t,x0);




% Plot
figure 
subplot(2,1,1)
    hold on
    plot(t,y)
    plot(t,t1s)
subplot(2,1,2)
    hold on
    plot(t,h1s)












