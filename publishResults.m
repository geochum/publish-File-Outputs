clc;  % Clear command window

% Define the output folder path
outputFolderPath = 'PublishedResults';

% Ensure the output directory exists and is clear of old files
if ~exist(outputFolderPath, 'dir')
    mkdir(outputFolderPath);
    disp(['Output directory "' outputFolderPath '" created.']);
else
    % Folder exists; now check for any files and delete them
    disp(['Output directory "' outputFolderPath '" already exists. Clearing old files...']);
    oldFiles = dir(fullfile(outputFolderPath, '*'));
    for k = 1:length(oldFiles)
        if ~oldFiles(k).isdir  % Ensures directories are not deleted
            filePath = fullfile(outputFolderPath, oldFiles(k).name);
            delete(filePath);
            if exist(filePath, 'file')
                error('Failed to delete "%s". Please close any open files in "%s" and try again.', oldFiles(k).name, outputFolderPath);
            end
        end
    end
    disp('Old files deleted.');
end

% Get the name of the current running script
currentScript = strcat(mfilename, '.m');

% List all .m files in the current directory
files = dir(fullfile(pwd, '*.m'));

% User input handling for files that require code execution
filesToExecute = {};  % Initialize empty cell array
while true
    userInput = input('Enter file names without ".m" that need their code executed, separated by commas, or type "exit" to quit: ', 's');
    if strcmpi(userInput, 'exit')
        fprintf('Exiting script as requested.\n');
        return;  % Exit the function early as requested by user
    end
    tempFiles = strsplit(strtrim(userInput), ',');
    tempFiles = strtrim(tempFiles);  % Remove any leading/trailing spaces from names
    tempFiles = strcat(tempFiles, '.m');  % Append .m extension to each file name
    filesToExecute = [filesToExecute, tempFiles];  % Append new files to the list

    % Ask user if all files have been entered
    doneInput = input('Are you sure you are done entering files? Enter "yes" or "no": ', 's');
    if strcmpi(doneInput, 'yes')
        break;  % Exit loop if user confirms
    end
end

% Loop through each file and publish
for i = 1:length(files)
    fileName = files(i).name;

    % Skip the current script file
    if strcmp(nameOnly, currentScript)
        continue;
    end

    % Full file path
    fullFilePath = fullfile(files(i).folder, fileName);

    % Define common publishing options with default settings
    commonOptions = struct('format', 'pdf', 'outputDir', outputFolderPath, 'showCode', true, 'evalCode', false);

    % Adjust options for files specified by the user
    if ismember(fileName, filesToExecute)
        commonOptions.evalCode = true;
    end

    % Publish the file with the adjusted options
    fprintf('Publishing PDF for: %s\n', fileName);
    try
        publish(fullFilePath, commonOptions);
        fprintf('Published %s successfully.\n', fileName);
    catch ME
        fprintf('Failed to publish %s due to an error: %s\n', fileName, ME.message);
        if contains(ME.message, 'Permission denied')
            error('Error: Permission denied or file is open. Check if any file in the output folder is open and try again.');
        else
            fprintf('Please check the script "%s" for errors or input requirements before publishing. This script might require input arguments or has other issues preventing its execution.\n', fileName);
        end
    end
end

fprintf('Publishing process completed.\n');

% Close all open figures
close all;
