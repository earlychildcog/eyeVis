function T = eyevisDataFromTable(T, opts)
% Converts data from a table to a form that eyevis video functions can use
% Input:
% T: table with the data
% optional:
% varX      : name of X gaze variable(s) in T
% varY      : name of Y gaze variable(s) in T
% varTime   : name of time variable in T
% varSubj   : name of subject variable in T. Default "session". If it does not exist or is empty, it is ignored.
% varGrouping: name(s) of variables to keep and group with
% framedur  : duration of each frame in time units.
arguments
    T  table
    opts.varX       string          = ["fixgazeX" "fixgazeX2"]
    opts.varY       string          = ["fixgazeY" "fixgazeY2"]
    opts.varTime    (1,1) string    = "time"
    opts.varSubj    (1,1) string    = "session"
    opts.varOtherForGrouping string = ["condition" "trial"]
    opts.framedur   (1,1) double    = 100/3
end

varX = opts.varX;
varY = opts.varY;
varTime = opts.varTime;
varGrouping = opts.varOtherForGrouping;
varSubj = opts.varSubj;

framedur = opts.framedur;

varList = [varSubj varGrouping varTime varX varY];
varInT = string(T.Properties.VariableNames);

varCommon = intersect(varList, varInT);
T = T(:, varCommon);

assert(ismember(varTime, varCommon), "Time variable missing")

% rename subject variable, if applicable
if any(varSubj == varCommon)
    newVarSubj = "session";
    if varSubj ~= newVarSubj
        T.Properties.VariableNames(varSubj == varCommon) = newVarSubj;
        varCommon(varCommon == varSubj) = newVarSubj;
        varSubj = newVarSubj;
    end
    varCommon = [varSubj varCommon(varCommon ~= varSubj)]; % rearrange for aesthetics
end

% in case we have more than one variable for gaze (eg one for each eye)
varX = intersect(varX, varCommon);
varY = intersect(varY, varCommon);
assert(~isempty(varX), "X gaze variable missing")
assert(~isempty(varY), "Y gaze variable missing")
if length(varX) > 1
    T.(varX(1)) = mean(T{:,varX}, 2, "omitnan");
    T(:, varX(2:end)) = [];
    varX = varX(1);
end
if length(varY) > 1
    T.(varY(1)) = mean(T{:,varY}, 2, "omitnan");
    T(:, varY(2:end)) = [];
    varY = varY(1);
end


GroupingVariables = varCommon(~ismember(varCommon, [varX varY varTime]));


T = T(:, varCommon);
T.frame = floor(T.time/framedur) + 1;

InputVariables = [varX varY];
GroupingVariables = [GroupingVariables "frame"];

T = varfun(@(x)single(median(x, "omitnan")), T, 'GroupingVariables',GroupingVariables, 'InputVariables',InputVariables); 
T.GroupCount = [];
T.Properties.VariableNames = [GroupingVariables "X" "Y"];



