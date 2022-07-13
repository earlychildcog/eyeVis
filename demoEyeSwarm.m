%% settings

addpath(genpath("src"))

project = "demo";
settings = settingsEyeSwarm(project, ".");
mkdir(settings.locationOfResults)

%% get and prepare data

locationOfData = settings.locationOfData;
listOfVariables = settings.listOfVariables;
listOfConditions = settings.listOfConditions;

% read data to a table
time0 = datetime;
T = dataFromFolder(locationOfData, listOfVariables, listOfConditions);
fprintf("data from %s loaded in %.2f seconds\n", locationOfData, seconds(datetime - time0))

%%      

listOfConditions = settings.listOfConditions;
nameVideo = swarm(T, settings);






