%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project Sponsors :
%U.S. Department of Energy
%American Institute of Chemical Engineers
%Rapid Advancement in Process Intensification Deployment (RAPID) Institute
%Center for Process Modeling (CPM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contributor(s) :
%Department of Chemical and Biomolecular Engineering,.
%Georgia Institute of Technology,
%311 Ferst Drive NW, Atlanta, GA 30332-0100.
%Scott Research Group
%https://www.jkscottresearchgroup.com/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project title :
%Dynamic Modeling and Simulation of Pressure Swing Adsroption (PSA)
%Process Systems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code by               : Taehun Kim
%Review by             : Taehun Kim
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2022/12/31/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : runPsoProcessSimulation.m
%Source     : run
%Description: a MATLAB® function file in which different MATLAB® functions
%             are called to simulate a pressure swing adsorption (PSA)
%             process, plot the simulation results, and save the results as
%             .csv files in the designated folder.
%Inputs     : folderName   - a string variable containing the folder name.
%             num          - an additional input for the function call
%                            number.
%Outputs    : n.a.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sol = runPsoProcessSimulation(folderName,params,fullParams)

%---------------------------------------------------------------------%
%Define known quantities

%Name the function ID
funcId = 'runPsoProcessSimulation.m';
%---------------------------------------------------------------------%


%---------------------------------------------------------------------%
%Clear the work space and any open windows

%Clear up the command window
% clc;

%Close all the open figures
close all;
%---------------------------------------------------------------------%



%---------------------------------------------------------------------%
%Check the function input and make sure it is a string variable
%denoting the name of the folder containing the example file

%If the input is not a scalar variable or no input is given, then
%terminate the program and post the warning.
if isstring(folderName) == 0 || isempty(folderName) == 1

    %Print the error message
    msg = 'Please provide a string variable (example folder name).';
    msg = append(funcId,': ',msg);
    error(msg);

end
%---------------------------------------------------------------------%



%---------------------------------------------------------------------%
%% Perform the simulation
parfor j = 1:length(params)
    %If we have a single step,
    if params(j).nSteps == 1

        %We are doing a breakthrough simulation
        fprintf("\n*******************************************\n");
        fprintf('Beginning a single step simulation...\n\n')      ;
        fprintf("*******************************************\n")  ;

        %If more than a single step,
    else

        %We are doing a PSA cycle simulation
        fprintf("\n*******************************************\n");
        fprintf('Beginning a PSA cycle simulation...\n')        ;
        fprintf("*******************************************\n")  ;
    end

    %Run the timer
    [initime,time] = startFuncTimer();

    %Call runPsaCycle.m function to simulate a given cycle
    sol(j) = runPsaCycle(params(j));

    %Print out the section header
    fprintf("\n*******************************************\n");
    fprintf('For the cycle simulation, \n');

    %Finish running the timer
    finishFuncTimer(initime,time);

    %Enter a line
    fprintf("*******************************************\n");

    %If we have a single step,
    if params(j).nSteps == 1

        %We are doing a breakthrough simulation
        fprintf("\n*******************************************\n");
        fprintf('The breakthrough simulation has finished! \n')   ;
        fprintf("*******************************************\n")  ;

        %If more than a single step,
    else

        %We are doing a PSA cycle simulation
        fprintf("\n*******************************************\n");
        fprintf('The PSA cycle simulation has finished! \n')      ;
        fprintf("*******************************************\n")  ;

    end
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Save the paths for saving figures and data to a data structure

    %Save the example folder location to save the simulation outputs to a
    %data structure called sol
    sol(j).path.figs = fullfile(folderName, ...
        '2_simulation_outputs', ...
        '1_figs',...
        int2str(j));
    sol(j).path.data = fullfile(folderName, ...
        '2_simulation_outputs', ...
        '2_data',...
        int2str(j));
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Save simulation results

    %Insert a preamble for the command window output
    fprintf("\n*******************************************\n");
    fprintf('Saving simulation results... \n')                ;
    fprintf("*******************************************\n")  ;

    %Save simulation outputs into excel files
    savePsaSimulationResults(fullParams,sol(j),sol(j).path.data);

    %Insert a conclusion for the command window output
    fprintf("\n*******************************************\n");
    fprintf('Check the example folder! \n')                   ;
    fprintf("*******************************************\n")  ;

    %Turn off the diary
    % diary off
    %---------------------------------------------------------------------%
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%