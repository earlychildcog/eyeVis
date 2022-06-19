function T = dataFromFile(path, listOfVariables, listOfConditions, opts)
% reads data from a csv file
% path: path to the csv file
% listOfVariables: list of variable names to extract
arguments
    path  {mustBeFile}
    listOfVariables  string = string([])
    listOfConditions  string = string([])
    opts {mustBeA(opts,"matlab.io.text.DelimitedTextImportOptions")} = compactImportOptions(path)
end

framedur = 33.3333;
tMin = 0;

T = readtable(path, opts);
if ~isempty(listOfVariables)
    T = T(:, listOfVariables);
end
if ~isempty(listOfConditions)
    T = T(ismember(T.condition, listOfConditions), :);
end
T = T(T.time >= tMin, :);

T.frame = floor(T.time/framedur) + 1;

InputVariables = ["fixgazeX" , "fixgazeY"];
GroupingVariables = [listOfVariables(~ismember(listOfVariables, ["time" InputVariables])) "frame"];

T = varfun(@(x)single(nanmedian(x)), T, 'GroupingVariables',GroupingVariables, 'InputVariables',InputVariables); %#ok<NANMEDIAN> 
T.GroupCount = [];
T.Properties.VariableNames(end-1:end) = {'X' 'Y'};


