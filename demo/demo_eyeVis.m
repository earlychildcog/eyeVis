%% load data from file

csvFile = "data/data.csv";
T = eyevisDataFromFile(csvFile,...
    varSubj = "session",...
    varOtherForGrouping = ["condition" "trial"]);

%% clean up the table

% choose one condition to use
thisCondition = "cond1";
T(T.condition ~= thisCondition, :) = [];

% restrict frames to IP
frameIP = [1 600];
T(T.frame < frameIP(1) & T.frame > frameIP(2), :) = [];

%% make a video heatmap

videostim = "stimuli/video.mp4";
newfilename = videoHeatmap(T, videostim,...
    resultFolder    = "results" ,...
    nameOfProject   = "demo"    ,...
    typeOfExpoty    = "avi"     ...
    );

%% open the new file!
try
    system("open " + newfilename)
catch
    fprintf("couldn't open file %s\n", newfilename)
end
