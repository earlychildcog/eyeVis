function T = dataFromFile(filepath, settings, opts)
% reads data from a csv file
% path: path to the csv file
% listOfVariables: list of variable names to extract
arguments
    filepath  {mustBeFile}
    settings    {mustBeA(settings, "settingsEyeSwarm")}
    opts {mustBeA(opts,"matlab.io.text.DelimitedTextImportOptions")} = compactImportOptions(filepath)
end

listOfVariables = settings.listOfVariables;
listOfConditions = settings.listOfConditions;
framedur = settings.durationOfFrame;
tMin = settings.IP(1);
tMax = settings.IP(2);

T = readtable(filepath, opts);
if ~isempty(listOfVariables)
    T = T(:, listOfVariables);
end
if ~isempty(listOfConditions)
    T = T(ismember(T.condition, listOfConditions), :);
end
T = T(T.time >= tMin & T.time <= tMax, :);

T.frame = floor(T.time/framedur) + 1;

InputVariables = ["fixgazeX" , "fixgazeY"];
GroupingVariables = [listOfVariables(~ismember(listOfVariables, ["time" InputVariables])) "frame"];

T = varfun(@(x)single(nanmedian(x)), T, 'GroupingVariables',GroupingVariables, 'InputVariables',InputVariables); %#ok<NANMEDIAN> 
T.GroupCount = [];
T.Properties.VariableNames(end-1:end) = {'X' 'Y'};


