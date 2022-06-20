classdef settingsEyeSwarm
    % settings class for swarm videos
properties
    project                 string

    % paths
    locationOfProject       string
    locationOfData          string
    locationOfStimuli       string
    locationOfResults       string

    % plot settings
    colours
    ifColourGroups          logical = false                     

    % data settings

    listOfVariables         string
    varCondition            string = "condition"
    varGroup                string = "group"

    listOfConditions        string
    listOfVideonames        string                 % order must correspond to listOfConditions order
    listOfGroups            string

    durationOfFrame         single = 33.333333
    dimsOfScreen            single = [1280 1024]
    IP                      single = [0 Inf]
end
methods
    function obj = settingsEyeSwarm(project, locationOfProject)
        arguments
            project string
            locationOfProject string = ".";
        end
        obj.project = project;
        obj.locationOfProject = locationOfProject;
        obj.locationOfData = locationOfProject + "/data/csv";
        obj.locationOfStimuli = locationOfProject + "/stimuli/videos";
        obj.locationOfResults = locationOfProject + "/results/videos";
        try
            listOfExtensions = ["mp4" "avi" "mpeg" "mov"]';
            searchLocation = obj.locationOfStimuli + "/*." + listOfExtensions;
            videos = cell2mat(arrayfun(@dir, searchLocation, 'UniformOutput', false));
            obj.listOfVideonames = string(arrayfun(@(x)x.name,videos,'UniformOutput',false))';
        catch er
        end
    end
end
end







