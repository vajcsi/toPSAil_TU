function createExtMatFiles2(exampleFolder,xi)

%---------------------------------------------------------------------%
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
%---------------------------------------------------------------------%


%---------------------------------------------------------------------%
% Generate new inputs with LHS
m = size(xi,1);

for i = 1:numExFilesFolder
    exFileName = subFolder0(i);
    load(exFileName, "simInput");
    baseVals = simInput(1,:);
    testVals = simInput(2,:);

    simInput(m+1,:) = testVals;
    % Write new inputs into corresponding files
    for j = 1:m
        % Copy base case values to all instances
        simInput(j,:) = baseVals;
        % if exFileName == "3.4_extract_tank_properties.mat"
            %Extract tank pressure is desorption pressure and it is only
            %changed in cyclic simulations
            % simInput(j).presExTa = ;
        if exFileName == "4.1_cycle_organization.mat"
            % Change step durations
            simInput(j).durStep = regexprep(num2str(repmat(xi(j,1:3),1,4)),'\s+',' ');
            % Change Cv values for ProvidePurge and Purge steps based on new step
            % times. The for-loop takes care of all columns sequentially.
            nCols = simInput(j).nCols;
            for k = 1:nCols
                fieldToFind = append('sStepCol',num2str(k));
                fieldToModifyProd = append('valProdCol',num2str(k));
                fieldToModifyFeed = append('valFeedCol',num2str(k));
                stepList = split(simInput(j).(fieldToFind));
                % Find the provide purge and purge step indices
                for stpidx = 1:length(stepList)
                    if strcmp(stepList(stpidx),'DP-XXX-ATM') == 1
                        idx_ppg = stpidx;
                    elseif strcmp(stepList(stpidx),'LP-ATM-RAF') == 1
                        idx_pg = stpidx;
                    end
                end
                CvListProd = str2double(split(simInput(j).(fieldToModifyProd)));
                CvListFeed = str2double(split(simInput(j).(fieldToModifyFeed)));
                % CvListProd(idx_ppg) = (xi(j,4)); %Missing Fnc: calcCvPpg
                % CvListFeed(idx_pg) = (xi(j,5)); %Missing Fnc: calcCvPg
                simInput(j).(fieldToModifyProd) = regexprep(num2str(CvListProd'),'\s+',' ');
                simInput(j).(fieldToModifyFeed) = regexprep(num2str(CvListFeed'),'\s+',' ');
            end
        end
        save(saveLoc + exFileName,"simInput","-mat")
    end
    clear simInput
end
end