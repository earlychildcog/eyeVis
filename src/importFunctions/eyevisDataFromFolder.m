function T = eyevisDataFromFolder(locationOfData, opts)
% Converts data from a folder of csv files to a form that eyevis video functions can use
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
    locationOfData string {mustBeFolder}
    opts.varX string = ["fixgazeX" "fixgazeX2"]
    opts.varY string = ["fixgazeY" "fixgazeY2"]
    opts.varTime string = "time"
    opts.varSubj string = "session"
    opts.varOtherForGrouping string = ["condition" "trial"]
    opts.framedur double = 100/3
end


varX = opts.varX;
varY = opts.varY;
varTime = opts.varTime;
varOtherForGrouping = opts.varOtherForGrouping;
varSubj = opts.varSubj;
framedur=opts.framedur;

filenames = arrayfun(@(x)string(fullfile(x.folder, x.name)),dir(locationOfData + "/*.csv"));
nFiles = length(filenames);
S = cell(nFiles,1);

% we reduce memory size of input
importOpts = compactImportOptions(filenames(1));
parfor f = 1:nFiles
    S{f} = eyevisDataFromFile(filenames(f),...
        importOpts = importOpts,...
        varX=varX,...
        varY=varY,...
        varTime=varTime,...
        varSubj=varSubj,...
        varOtherForGrouping=varOtherForGrouping,...
        framedur=framedur);
end
T = cat(1,S{:});




