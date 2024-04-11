function [numCases] = createExtMatFiles(exampleFolder,xi)
%Define the sub-folder name containing mat-files
subFolderName = "\1_simulation_inputs\matFiles\";

%Define the mat-file names for each sub-folder
subFolder0 = ["0.1_simulation_configurations.mat", ...
    "0.2_numerical_methods.mat", ...
    "0.3_simulation_outputs.mat", ...
    "1.1_natural_constants.mat", ...
    "1.2_adsorbate_properties.mat", ...
    "1.3_adsorbent_properties.mat", ...
    "2.1_feed_stream_properties.mat", ...
    "2.2_raffinate_stream_properties.mat", ...
    "2.3_extract_stream_properties.mat", ...
    "3.1_adsorber_properties.mat", ...
    "3.2_feed_tank_properties.mat", ...
    "3.3_raffinate_tank_properties.mat", ...
    "3.4_extract_tank_properties.mat", ...
    "3.5_feed_compressor_properties.mat", ...
    "3.6_extract_compressor_properties.mat", ...
    "3.7_vacuum_pump_properties.mat", ...
    "4.1_cycle_organization.mat"];

numExFilesFolder = length(subFolder0);

saveLoc = exampleFolder + subFolderName;

% Generate new inputs with LHS
% xi = lhsSample(numParams,m,uBound,lBounds);
m = length(xi);

for i = 1:numExFilesFolder
    exFileName = subFolder0(i);
    load(exFileName);
    baseVals = simInput(1,:);
    testVals = simInput(2,:);
    
    simInput(m+1,:) = testVals;
    % Write new inputs into corresponding files
    for j = 2:m
        % Copy base case values to all instances
        simInput(j,:) = baseVals;
        if exFileName == "2.1_feed_stream_properties.mat"
            simInput(j).tempFeed = xi(j,3);
            simInput(j).yFeC1 = xi(j,4);
            simInput(j).yFeC2 = 1-xi(j,4);
        elseif exFileName == "3.1_adsorber_properties.mat"
            % simInput(j).heightCol = xi(j,5);
            simInput(j).presColHigh = xi(j,1);
            simInput(j).tempCol = xi(j,3);
        elseif exFileName == "3.2_feed_tank_properties.mat"
            simInput(j).tempFeTa = xi(j,3);
            simInput(j).presFeTa = xi(j,1) + 0.01;
        elseif exFileName == "3.3_raffinate_tank_properties.mat"
            simInput(j).tempRaTa = xi(j,3);
            simInput(j).presRaTa = xi(j,1) - 0.01;
        elseif exFileName == "3.4_extract_tank_properties.mat"
            simInput(j).tempExTa = xi(j,3);
            %Extract tank pressure is desorption pressure and it is only
            %changed in cyclic simulations
            % simInput(j).presExTa = ;
        elseif exFileName == "4.1_cycle_organization.mat"
            %Step durations are only changed in cyclic simulations
            % simInput(j).durStep = ;
            oldVals = str2double(split(simInput(j).valFeedCol1,' '));
            newVals = oldVals;
            newVals(2) = xi(j,2);
            simInput(j).valFeedCol1 = regexprep(num2str(newVals'),'\s+',' ');
            % simInput(j).valFeedCol1 = newValFeed(simInput(j).valFeedCol1,xi);
        end
        save(saveLoc + exFileName,"simInput","-mat")
    end
    clear simInput
end

numCases = m;
end