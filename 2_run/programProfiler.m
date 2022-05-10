%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project Sponsors :
%U.S. Department of Energy 
%American Institute of Chemical Engineers
%Rapid Advancement in Process Intensification Deployment (RAPID) Institute
%Center for Process Modeling (CPM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contributor(s) :
%Department of Chemical and Biomolecular Engineering,
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
%Code created on       : 2011/2/4/Thursday
%Code last modified on : 2022/2/17/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : programProfiler.m
%Source     : common
%Description: this is a function that calls runPsaProcessSimulation.m so
%             that MATLAB's profiler can be used to optimize the program.
%                            folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function programProfiler()        
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'programProfiler.m';
    %---------------------------------------------------------------------%    
    

    
    %---------------------------------------------------------------------%
    %Profile the main function
    
    %Define the first folder name
    %name = "test_2_cols_isothermal_no_pres_drop_o2_n2_zeolite_5a_time_and_event";
    %name = "test_1_col_isothermal_no_pres_drop_o2_n2_zeolite_5a_time_and_event";
    name = "testNonIsothermal";
    %name = "testIsothermal";
    %name = "testIsothermalMomentumErgun";
    %name = "testIsothermalMomentumKozenyCarman";
    %name = "testNonIsothermalMomentumKozenyCarman";    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the final folder name
    
    %Append the name
    name = append(name);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Profile the code
    
    %Run the PSA process simulator
    runPsaProcessSimulation(name);
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%