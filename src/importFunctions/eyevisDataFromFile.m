function T = eyevisDataFromFile(filepath, opts)
% Converts data from a csv file to a form that eyevis video functions can use
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
    filepath string {mustBeFile}
    opts.varX string = ["fixgazeX" "fixgazeX2"]
    opts.varY string = ["fixgazeY" "fixgazeY2"]
    opts.varTime string = "time"
    opts.varSubj string = "session"
    opts.varOtherForGrouping string = ["condition" "trial"]
    opts.framedur double = 100/3
    opts.importOpts {mustBeA(opts.importOpts,"matlab.io.text.DelimitedTextImportOptions")} = compactImportOptions(filepath)
end

T = readtable(filepath, opts.importOpts);
T = eyevisDataFromTable(T,...
        varX=opts.varX,...
        varY=opts.varY,...
        varTime=opts.varTime,...
        varSubj=opts.varSubj,...
        varOtherForGrouping=opts.varOtherForGrouping,...
        framedur=opts.framedur);



