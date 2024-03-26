function [varName, saveLoc] = createMatFiles(exampleFolder)

funcId = "createMatFiles.m";

subFolder1 = "\1_simulation_inputs";

subFolder0 = ["0.1_simulation_configurations", ...
    "0.2_numerical_methods", ...
    "0.3_simulation_outputs", ...
    "1.1_natural_constants", ...
    "1.2_adsorbate_properties", ...
    "1.3_adsorbent_properties", ...
    "2.1_feed_stream_properties", ...
    "2.2_raffinate_stream_properties", ...
    "2.3_extract_stream_properties", ...
    "3.1_adsorber_properties", ...
    "3.2_feed_tank_properties", ...
    "3.3_raffinate_tank_properties", ...
    "3.4_extract_tank_properties", ...
    "3.5_feed_compressor_properties", ...
    "3.6_extract_compressor_properties", ...
    "3.7_vacuum_pump_properties", ...
    "4.1_cycle_organization"];

numExFilesFolder = length(subFolder0);

% Define save location for mat-files
saveLoc = exampleFolder + subFolder1 + "\matFiles\";
% Create separate folder for mat-files if it doesn't exist
if exist(saveLoc,"dir") ~= 7
    mkdir(exampleFolder + subFolder1,"\matFiles\");
end

% Preallocation of memory and start line counter
% simInput = struct([]);
k = 0;

% paramDict = configureDictionary("string","string");
% for j = 1:numExFilesFolder
%     exFileName = subFolder0(j);
%     readIn(1,:) = table2struct(readtable(exFileName + '.xlsm', 'sheet', 'Data(Transposed)'));
%     readIn(2,:) = table2struct(readtable(exFileName + '.xlsm', 'sheet', 'Data(Test)'));
%     fields = fieldnames(readIn);
%     for k = 1:length(fields)
%         fname = fields{k};
%         paramDict(fname) = num2str(horzcat(readIn.(fname)));
%         % paramDict = dictionary(fname,num2str(horzcat(readIn.(fname))));
%     end
%     clear readIn
% end



for j = 1 : numExFilesFolder
    exFileName = subFolder0(j);
    readIn(1,:) = table2struct(readtable(exFileName + ".xlsm","Sheet","Data(Transposed)"));
    readIn(2,:) = table2struct(readtable(exFileName + ".xlsm","Sheet","Data(Test)"));
    % field = fieldnames(readIn);
    % for k = 1:length(field)
    %     fname = field{k};
    %     if ischar(readIn(1).(fname)) ~= ischar(readIn(2).(fname))
    %         num2str(readIn(2).(fname));
    %     end
    %     inParams.(fname) = vertcat(readIn.(fname));
    % end
    simInput = readIn;
    save(saveLoc + exFileName + ".mat","simInput","-mat")
    clear readIn
end
varName = "simInput";

end