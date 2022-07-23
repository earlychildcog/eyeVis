function fileOut = videoSwarm(T, videoFileIn, opts)
% Produces "swarm" gaze videos (mainly for eyetracking)
% ###
% Required input arguments:
%   T: must be a table with the following variable names:
%      session > trial > frame, X for x-coordinates, Y for y-coordinates
%   videoFileIn: the name of the videofile to play
% ###
% Optional input arguments:
%   resultFolder:   where to save (default current folder)
%   nameOfProject:  just an optional name to put on the file
%   luminAdj:       adjust the luminosity of the background frames. Default: 0.5
%   dotSize:        How big the dots to be. Default: 1.5
%   typeOfExport:   what form to export (can be png, jpg, gif, avi). Default avi
%   verbose, timer: If and what to print during the process.
%   
arguments
    T           {mustBeA(T, 'table')}
    videoFileIn string {mustBeFile}
    opts.colour (1,3) uint8 = uint8([0, 255, 0])
    opts.resultFolder string {mustBeFolder} = "."
    opts.nameOfProject string = ""
    opts.luminAdj double = 0.5;
    opts.dotSize double = 1.5;
    opts.typeOfExport string {mustBeMember(opts.typeOfExport, ["png" "avi" "gif" "jpg"])} = "avi"
    opts.verbose logical = false
    opts.timer logical = true
end

nameOfProject = opts.nameOfProject;
resultFolder = opts.resultFolder;

colour = opts.colour;
luminAdj = opts.luminAdj;
dotSize = opts.dotSize;


timer = opts.timer;
verbose = opts.verbose;
typeOfExport = opts.typeOfExport;

[frameMin, frameMax] = bounds(T.frame);




u = VideoReader(videoFileIn);
frameVideoMax = u.NumFrames;
dimsOfVideo = [u.Width, u.Height];
framerate = round(u.FrameRate);


% how to save the animation

switch typeOfExport

    case "avi"
        resultFolder = fullfile(resultFolder,"videos");
        mkdir(resultFolder);
        fileOut = sprintf("%s/swarm_%s_%s.avi",resultFolder,nameOfProject, datestr(datetime, 'yyyymmdd_hhMM_ss'));
        v = VideoWriter(fileOut, "Motion JPEG AVI");
        v.FrameRate = framerate;
        v.open;

    case "gif"
        resultFolder = fullfile(resultFolder,"gifs");
        mkdir(resultFolder);
        fileOut = sprintf("%s/swarm_%s_%s.git",resultFolder,nameOfProject, datestr(datetime, 'yyyymmdd_hhMM'));

    case {"png" "jpg"}
        resultFolder = fullfile(resultFolder,"frames");
        mkdir(resultFolder);
        fileOut = fullfile(resultFolder, "swarm_" + nameOfProject + "_" + typeOfExport + "_" + datestr(datetime, 'yyyymmdd_hhMM'));
        mkdir(fileOut);
end


if verbose || timer
    toDelete = 0;
    time0 = datetime;
    fprintf('Writing to %s...\n', fileOut)
end


fprintf('writing frame ')


ballRad = dotSize;

% video creation loop
for frameC = frameMin:frameMax
    if timer && verbose
        tic
    end

    % new frame
    frameBW = rgb2gray(u.read(min(frameC, frameVideoMax)));
    frame3D = repmat(frameBW,[1 1 3])*luminAdj;
    frameInd = T.frame == frameC;
    gaze = round(T{frameInd,["X" "Y"]});
    gaze(isnan(gaze(:,1)), :) = [];
    outgaze = gaze(:,1) <= 0 | gaze(:,1) > dimsOfVideo(1) |...
        gaze(:,2) <= 0 | gaze(:,2) > dimsOfVideo(2);
    gaze(outgaze,:) = [];
    for k = 1:size(gaze,1)
        y = gaze(k,2) + floor([-ballRad ballRad]);
        x = gaze(k,1) + floor([-ballRad ballRad]);
        x = [max(x(1), 1) min(x(2), dimsOfVideo(1))];
        y = [max(y(1), 1) min(y(2), dimsOfVideo(2))];
        for rgbInd = 1:3
            frame3D( y(1):y(2), x(1):x(2) ,rgbInd) = colour(rgbInd);
        end
    end

    
    % export the frame
    switch typeOfExport

        case "avi"
            v.writeVideo(frame3D);

        case "gif"

            [A,map] = rgb2ind(frame3D,256);
            if frameC == frameMin
                imwrite(A,map,fileOut,"gif",LoopCount=Inf,DelayTime=1/framerate);
            else
                imwrite(A,map,fileOut,"gif",WriteMode="append",DelayTime=1/framerate);
            end

        case {"png" "jpg"}
            imwrite(frame3D, fullfile(fileOut, sprintf("%.4d.%s", frameC, typeOfExport)));

    end

    % print messages to command line to show progress if requested
    if timer && verbose
        toc
    end

    if verbose && ~timer
        fprintf(repmat('\b', 1, toDelete));
        message = sprintf('%d', frameC);
        toDelete = length(message);
        fprintf(message);
    end
end



if typeOfExport == "avi"
    v.close;
end
if verbose || timer
    wholeduration = seconds(datetime - time0);
    fprintf('\nvideo created and saved in %.2f seconds (%f fps)\n', wholeduration,frameMax/wholeduration)
end