function T = dataFromFolder(path, listOfVariables, listOfConditions)
% reads data from csv files in a folder
% path: path to folder of csv files
% listOfVariables: list of variable names to extract
arguments
    path  {mustBeFolder}
    listOfVariables  string = string([])
    listOfConditions  string = string([])
end


filenames = arrayfun(@(x)sprintf("%s/%s",x.folder, x.name),dir(path + "/*.csv"));
nFiles = length(filenames);
S = cell(nFiles,1);

% we reduce memory size of input
opts = compactImportOptions(filenames(1));
parfor f = 1:nFiles
    S{f} = dataFromFile(filenames(f), listOfVariables, listOfConditions, opts);
end
T = cat(1,S{:});




