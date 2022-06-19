function videoFileOut = swarm(T, settings)
arguments
    T           {mustBeA(T, 'table')}
    settings    {mustBeA(settings, "settingsEyeSwarm")}
end

project = settings.project;
resultFolder = settings.locationOfResults;
condN = length(settings.listOfConditions);
videoFolder = settings.locationOfStimuli;
videos = settings.listOfVideonames;
listOfConditions = settings.listOfConditions;
durFrame = settings.durationOfFrame;
IP = settings.IP;

frameMin = floor(IP(1)/durFrame) + 1;
frameMax = min([floor(IP(2)/durFrame)  max(T.frame)]);

T = T(T.frame >= IP(1)/durFrame & T.frame <= frameMax, :);

% which colours to use (per group, if any)
colours = {[1 0.5 0.5] [0 1 1]};
colours = {[0 1 1] [0 1 1]};
colours = {[0 1 0]};

% dimensions of video stimuli (used in data processing, to invert based on lateralisation)
dimsOfScreen = settings.dimsOfScreen;

mkdir(resultFolder)

% adjust luminosity of background frame (current idea is dark background and light swarms)
luminAdj = 0.5;

% how big the dots to be
dotSize = 40;

% should the pupils leave traces back?
traceN = 1;

videoFileOut = sprintf("%s/swarm_%s_%s.avi",resultFolder,project, datestr(datetime, 'yyyymmdd_hhMM'));
v = VideoWriter(videoFileOut, "Motion JPEG AVI");
v.FrameRate = double(round(1000/durFrame));
v.open;
frameC = 0;
toDelete = 0;
time0 = datetime;
fprintf('Writing to %s...\n', videoFileOut)


for c = 1:condN             
    videoFileIn = videoFolder + "/" + videos(c);
    u{c} = VideoReader(videoFileIn);
    condition = listOfConditions(c);
    S{c} = T(T.condition == condition, :);
end


f = figure('WindowState','fullscreen','Visible','on');
pause(1)            % give some time for window to maximise before hiding it
f.Visible = 'off';
hold on

fprintf('writing frame ')
oldgaze = repmat({repmat({[]}, 1, traceN)},1 , 3);
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

        imshow(frameFull/2);
        hold on
        condition = listOfConditions{c};
        frameInd = S{c}.frame == frameC;
        gaze = S{c}{frameInd,end-1:end};
        scatter(gaze(:,1), gaze(:,2),dotSize, '.', 'MarkerEdgeAlpha', 0.5, 'MarkerEdgeColor', 'g');
        title(sprintf('%s %.0fms',condition, frameC*durFrame), 'FontName','FixedWirdth')
    end
    newFrame = getframe(f);
    v.writeVideo(newFrame);

    % print message to command line to show progress
    fprintf(repmat('\b', 1, toDelete));
    message = sprintf('%d', frameC);
    toDelete = length(message);
    fprintf(message);
end




time1 = datetime;
v.close;
fprintf('\nvideo created and saved in %.2f seconds\n', seconds(time1 - time0))