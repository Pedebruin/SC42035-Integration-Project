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



%% Main code




disp('Select data file')
[file,path]= uigetfile('*.mat');
if isequal(file,0)
    disp('no file selected')
else
    disp(['User selected: ', file]);
    load(fullfile(path,file),'h1s','h2s','t1s','t2s')
end

opts = ['InputName','Heater power'];
data = iddata(t1s, h1s, 1, opts);
