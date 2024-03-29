% Clear command window
clc;

% Define the name of the subfolder within the current working directory
subfolderName = 'publishedResults';

% Construct the full path to the subfolder
outputFolderPath = fullfile(pwd, subfolderName);

% Create the subfolder if it does not exist, or clear its contents if it does
if ~exist(outputFolderPath, 'dir')
    mkdir(outputFolderPath);
else
    % Get a list of all files in the folder
    oldFiles = dir(fullfile(outputFolderPath, '*'));
    % Loop through each file and delete it
    for i = 1:length(oldFiles)
        % Skip "." and ".." directories
        if ~strcmp(oldFiles(i).name, '.') && ~strcmp(oldFiles(i).name, '..')
            delete(fullfile(outputFolderPath, oldFiles(i).name));
        end
    end
end

% List of files for which code should be executed
filesToExecute = {'p3'}; % Base names without '.m'

% Name of this script file to exclude it from publishing
currentScript = mfilename;

% List all .m files in the current directory
files = dir(fullfile(pwd, '*.m'));

% Loop through each file and publish
for i = 1:length(files)
    fileName = files(i).name; % Initialize fileName at the start of the loop
    
    % Skip the current script file
    if strcmp(fileName, [currentScript '.m'])
        continue;
    end

    fullFilePath = fullfile(files(i).folder, fileName);
    
    % Define common publishing options with evalCode defaulting to false
    commonOptions = struct;
    commonOptions.format = 'pdf';
    commonOptions.outputDir = outputFolderPath;
    commonOptions.showCode = true;
    commonOptions.evalCode = false; % Default to not executing code
    
    % Adjust options for specific files
    [~, nameOnly, ~] = fileparts(fileName);
    if ismember(nameOnly, filesToExecute)
        commonOptions.evalCode = true; % Execute code for specified files
    end
    
    % Publish the file with adjusted options
    fprintf('Publishing PDF for: %s\n', fileName);
    publish(fullFilePath, commonOptions);

    subfolderName = 'publishedResults';
    outputFolderPath = fullfile(pwd, subfolderName);
    filesToExecute = {'p4_i', 'p4_ii', 'p4_iii'};
    currentScript = mfilename;
    files = dir(fullfile(pwd, '*.m'));
end

fprintf('Publishing process completed.\n');

% Close all open figures
close all;
