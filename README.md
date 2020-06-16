# Integration-Project
To contain the code for the integration project for S&amp;C 2019/2020 SC42035

Written by:  
Pim de Bruin            4545702  
Marco Delgado Gosalvez  4268083  

This README is structured in the following main topics:
* [Content](##content)
  * [General directories](###general-directories)
  * [Code files](###code-files)
* [Run Instructions](##run-instructions)
* [Dependancies](##dependancies)
---
## Content
### General directories
* Code  
  This directory contains all the code that was written for the project. 
* Project  
  This directory contains all the project planning related files and figures.
  * Presentations  
    This directory contains the presentations for the first two discussions
  * Project plan   
    This directory contains the updated project planning files (gantt chart)
* Report  
This directory contains all the figures and presentables related to the report. The actual report is written in an online latex editor. 
This repository can be found on our [GITHUB](https://github.com/Pedebruin/SC42035-Integration-Project) repository. 
  * Figures  
    This folder contains the figures used in the report. 
### Code files
Within the code directory, the code is devised into the following structure:
* Code
  * `Control.m`  
  This is the main file for controller design. Within this file, the required controller can be selected, built and simulated. 
  * `Identification.m`  
  This is the main file for system identification. Within this file, an identification experiment, identification method and validation experiment can be selected to identify and validate a model of all three types. 
  * Controller\_Design  
  Contains the controllers.
    * `Hinf.m`  
    This file contains the code for the `Hinf` function for the H infinity controller. 
    * `LQRc.m`  
    This file contains the code for the `LQRc` function for the continuous time LQR controller. 
    * `LQRd.m`  
    This file contains the code for the `LQRd` function for the discrete time LQR controller. 
  * Experiments    
  In this folder, all run experiments and tests are saved as `.mat` files. Also, a few experiment and test related files live here:
    * `ShowTest.m`  
    This function makes a plot of a selected test sequence. 
    * `TestController.m`  
    This file contains the code to implement the a selected controller on the true system and run an experiment!
    * `ShowExp.m`  
    This file plots the experiments. An _experiment_ is used for system identification, a _test_ implements a controller. 
    * `ExperimentRunner.m`  
    This file runs the experiments for the identification.
    * `tclab.m`  
    The initialisation file for the tclab.  
  * System\_Identification  
  This directory contains all system identification related files along with two additional directories:
    * Functions  
    This directory contains functions that are used for model validation and plotting of identified models. 
    * Models  
    This directory contains all identified models. Additionally, this directory contains a folder 'FINAL' containing the final three models used. 
    * `Exp1_HandvsLsq.m`  
    This file is used to compare the hand calculations to the simple least squares first order model. 
    * `FDSID.m`  
    This file contains the code for the FDSID model. 
    * `GreyBox.m`  
    This file contains the code for the grey box estimation.  
    * `N4SID.m`  
    This file contains the code for the N4SID system identification
    * `odeFun.m`  
    This file is used by the `GreyBox.m` file to build a grey box model and contains the ODEs for the model. 
    
    
## Run Instructions
The running of the code is devided into two main sections, which correspond to the two main dubfields used in this project:
* Identification  
To do identification, the `Identification.m` file from the control directory is used. Within this file first a set of settings are set. These settings determine which method(s) are used for identification and if validation is also requested. Also, the file can be configured to identify a mimo, siso-1 or siso-2 model.  
After starting to run this file, it will prompt to select an identification file. Here, a recorded experiment needs to be selected. After this, the identification is done. The file will again prompt to select a validation file if validation is turned on. Here, another experiment is requested. After completion, the file will plot a few performance metrics of the validation of the identified model. 
* Controller design  
To design a controller, the `Controller_design.m` file is used. This file allows for the design of the two different types of controllers based on dfferent models. It then also simulates the models and plots the result. Again here, settings are required at the beginning of the file. 
## Dependancies
For the repository, the system identification toolbox is required. 
