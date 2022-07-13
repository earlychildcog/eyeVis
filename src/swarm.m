function videoFileOut = swarm(T, settings, opts)
% Produces "swarm" gaze videos.
arguments
    T           {mustBeA(T, 'table')}
    settings    {mustBeA(settings, "settingsEyeSwarm")}
    opts.verbose logical = true
    opts.dotSize = 40;
    opts.luminAdj = 0.5;
end

project = settings.project;
resultFolder = settings.locationOfResults;
condN = length(settings.listOfConditions);
videoFolder = settings.locationOfStimuli;
videos = settings.listOfVideonames;
listOfConditions = settings.listOfConditions;
durFrame = settings.durationOfFrame;
IP = settings.IP;

% in case we plot groups of kids with different colours in same plot
doGroups = settings.ifColourGroups;
if doGroups
    varGroup = settings.varGroup;
    indexGroup = T.(varGroup);
    listOfGroups = unique(indexGroup);
    nGroup = length(listOfGroups);
end

frameMin = floor(IP(1)/durFrame) + 1;
frameMax = min([floor(IP(2)/durFrame)  max(T.frame)]);

T = T(T.frame >= IP(1)/durFrame & T.frame <= frameMax, :);

% which colours to use (per group, if any)
if ~doGroups
    colours = {[0 1 0]};
elseif nGroup == 2
    colours = {[1 0.5 0.5] [0 1 1]};
else
    colours = {'r' 'g' 'b' 'k' 'y'};
end


mkdir(resultFolder)

% adjust luminosity of background frame (current idea is dark background and light swarms)
luminAdj = opts.luminAdj;

% how big the dots to be
dotSize = opts.dotSize;

% should the pupils leave traces back?
% traceN = 1;

videoFileOut = sprintf("%s/swarm_%s_%s.avi",resultFolder,project, datestr(datetime, 'yyyymmdd_hhMM'));
v = VideoWriter(videoFileOut, "Motion JPEG AVI");
v.FrameRate = double(round(1000/durFrame));
v.open;




if opts.verbose
    toDelete = 0;
    time0 = datetime;
    fprintf('Writing to %s...\n', videoFileOut)
end

u = cell(condN,1);
S = cell(condN,1);
if doGroups, indexGroupCondition = cell(condN,1); end
for c = 1:condN             
    videoFileIn = fullfile(videoFolder, videos(c));
    u{c} = VideoReader(videoFileIn); %#ok<TNMLP> 
    condition = listOfConditions(c);
    S{c} = T(T.condition == condition, :);
    if doGroups
        indexGroupCondition{c} = indexGroup(T.condition == condition);
    end
end

% dimensions of screen and those of the video (X Y) --- Assumes all videos have the same dimensions
dimsOfScreen = settings.dimsOfScreen;
dimsOfVideo = [u{1}.Width, u{1}.Height];

if dimsOfVideo(1) ~= dimsOfScreen(1)
    T.X = T.X * dimsOfScreen(1) / dimsOfVideo(1);
end

if dimsOfVideo(2) ~= dimsOfScreen(2)
    T.Y = T.Y * dimsOfScreen(2) / dimsOfVideo(2);
end

f = figure('WindowState','fullscreen','Visible','on');
pause(1)            % give some time for window to maximise before hiding it
f.Visible = 'off';
hold on

fprintf('writing frame ')
% oldgaze = repmat({repmat({[]}, 1, traceN)},1 , 3);
frameBW = cell(condN, 1);
% video creation loop
for frameC = frameMin:frameMax
    

    % new frame
    tiledlayout(1,condN, 'TileSpacing','none');
    % gather gaze data for this frame number
    for c = 1:condN             
        nexttile(c);
        if u{c}.hasFrame
            frameBW{c} = rgb2gray(u{c}.readFrame);
        end
        frameFull = repmat(frameBW{c},[1 1 3]);

        imshow(frameFull*luminAdj);
        hold on
        condition = listOfConditions{c};
        frameInd = S{c}.frame == frameC;
        gaze = S{c}{frameInd,["X" "Y"]};
        if doGroups
            for g = 1:nGroup
                thisGroup = indexGroupCondition{c}(frameInd) == listOfGroups(g);
                scatter(gaze(thisGroup,1), gaze(thisGroup,2),dotSize, '.', 'MarkerEdgeAlpha', 0.5, 'MarkerEdgeColor', colours{g});
            end
        else
            scatter(gaze(:,1), gaze(:,2),dotSize, '.', 'MarkerEdgeAlpha', 0.5, 'MarkerEdgeColor', colours{1});
        end
        title(sprintf('%s %.0fms',condition, frameC*durFrame), 'FontName','FixedWirdth')
    end
    newFrame = getframe(f);
    v.writeVideo(newFrame);

    % print message to command line to show progress
    if opts.verbose
        fprintf(repmat('\b', 1, toDelete));
        message = sprintf('%d', frameC);
        toDelete = length(message);
        fprintf(message);
    end
end




v.close;
if opts.verbose
    time1 = datetime;
    fprintf('\nvideo created and saved in %.2f seconds\n', seconds(time1 - time0))
end