function fileOut = videoHeatmap(T, videoFileIn, opts)
% Produces heatmap videos (eg eyetracking)
% ###
% Required input arguments:
%   T: must be a table with the following variable names:
%      session > frame, X for x-coordinates, Y for y-coordinates
%   videoFileIn: the name of the videofile
% ###
% Optional input arguments:
%   heatmap:        what heatmap to use. Default to hot.
%   resultFolder:   where to save (default current folder)
%   nameOfProject:  just a name to put on the file
%   luminAdj:       adjust the luminosity of the background frames. Default: 0.5
%   typeOfExport:   what form to export (can be png, jpg, gif, avi). Default avi
%   sigma:          variance parameter of the gaussian filter. Default 24
%   normConstant:   normalises the total mass of the heatmap distribution, essentially
%                   if we split the image in a normC x normC grid and fill one rectangle,
%                   the total mass is equal to the one of that filled rectangle. Default 9
%   verbose, timer: If and what to print during the process.
%   
arguments
    T           table
    videoFileIn string {mustBeFile}
    opts.heatmap (256,3) = hot
    opts.resultFolder string {mustBeFolder} = "."
    opts.nameOfProject string = ""
    opts.luminAdj double = 0.5;
    opts.typeOfExport string {mustBeMember(opts.typeOfExport, ["png" "avi" "gif" "jpg"])} = "avi"
    opts.sigma double = 24
    opts.normConstant double = 9
    opts.verbose logical = false
    opts.timer logical = true
end

heatmap = opts.heatmap;
nameOfProject = opts.nameOfProject;
resultFolder = opts.resultFolder;
timer = opts.timer;
sigma = opts.sigma;
normConstant = opts.normConstant;
verbose = opts.verbose;

typeOfExport = opts.typeOfExport;



[frameMin, frameMax] = bounds(T.frame);

U = varfun(@(x)length(x(~isnan(x))), T, InputVariables="X",GroupingVariables=["session" "frame"]);
U.Properties.VariableNames(end) = "W";
% maxW = max(U.W);
U.W = 1./U.W;
U.W(U.W == Inf) = 0;
U.GroupCount = [];
T = join(T,U);

mkdir(resultFolder)

% adjust luminosity of background frame (current idea is dark background and light swarms)
luminAdj = opts.luminAdj;

% read video stim

u = VideoReader(videoFileIn);
frameVideoMax = u.NumFrames;
dimsOfVideo = [u.Width, u.Height];
framerate = round(u.FrameRate);

% how to save the animation

switch typeOfExport

    case "avi"
        resultFolder = fullfile(resultFolder,"videos");
        mkdir(resultFolder);
        fileOut = sprintf("%s/heatmap_%s_%s.avi",resultFolder,nameOfProject, datestr(datetime, 'yyyymmdd_hhMM_ss'));
        v = VideoWriter(fileOut, "Motion JPEG AVI");
        v.FrameRate = framerate;
        v.open;

    case "gif"
        resultFolder = fullfile(resultFolder,"gifs");
        mkdir(resultFolder);
        fileOut = sprintf("%s/heatmap_%s_%s.gif",resultFolder,nameOfProject, datestr(datetime, 'yyyymmdd_hhMM'));

    case {"png" "jpg"}
        resultFolder = fullfile(resultFolder,"frames");
        mkdir(resultFolder);
        fileOut = fullfile(resultFolder, "heatmap_" + nameOfProject + "_" + typeOfExport + "_" + datestr(datetime, 'yyyymmdd_hhMM'));
        mkdir(fileOut);
end


if opts.verbose || opts.timer
    toDelete = 0;
    time0 = datetime;
    fprintf('Writing to %s...\n', fileOut)
end


% creating the heatmap type
heatcol = mat2cell(heatmap,size(heatmap, 1),[1 1 1]);

fprintf('writing frame ')

% video creation loop
for frameC = frameMin:frameMax
    if timer && verbose
        tic
    end

    % new frame new data points
    frameBW = rgb2gray(u.read(min(frameC, frameVideoMax)));
    frame3D = repmat(frameBW,[1 1 3])*luminAdj;
    frameInd = T.frame == frameC;
    gaze = round(T{frameInd,["X" "Y"]});        % gaze points
    weight = T.W(frameInd);                     % weight of each gaze point
    nangaze = isnan(gaze(:,1));
    gaze(nangaze, :) = [];             % remove NaNs
    weight(nangaze, :) = [];
    % set out of bounds to just on bounds for more accurate plot
    gaze(gaze(:) <= 0) = 1;
    for i = 1:2
        gaze(gaze(:,i) > dimsOfVideo(i),i) = dimsOfVideo(i);
    end
    
    % add heatmap mask
    frame3D = plotHeatmap(gaze(:,1), gaze(:,2), weight, frame3D, heatmap=heatcol, sigma=sigma, normConstant=normConstant);

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
    if  timer && verbose
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