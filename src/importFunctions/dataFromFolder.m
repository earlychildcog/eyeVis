function T = dataFromFolder(settings)
% reads data from csv files in a folder
% path: path to folder of csv files
% listOfVariables: list of variable names to extract
arguments
    settings    {mustBeA(settings, "settingsEyeSwarm")}
end

locationOfData =  settings.locationOfData;
listOfVariables  = settings.listOfVariables;
listOfConditions = settings.listOfConditions;

filenames = arrayfun(@(x)sprintf("%s/%s",x.folder, x.name),dir(locationOfData + "/*.csv"));
nFiles = length(filenames);
S = cell(nFiles,1);

% we reduce memory size of input
opts = compactImportOptions(filenames(1));
parfor f = 1:nFiles
    S{f} = dataFromFile(filenames(f), settings, opts);
end
T = cat(1,S{:});




