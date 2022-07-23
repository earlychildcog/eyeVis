function backimag = plotHeatmap(X, Y, W, backimag, opts)
% function that puts a HEATMAP on the picture BACKIMAG,
% based on the points with coordinates X and Y, with weights W,
% using a Gaussian filter.
% The heatmap type is determined by HEATCELL.
% ###
% arguments:
% X:        column of x-coordinates
% Y:        column of y-coordinates
% W:        column of weights, empty ([]) for ones
% backimag: background RGB image uint8 matrix
% optional:
% heatmap: the type of heatmap in the form of a 3x1 RGB cell array. Default: hot
% sigma:    variance parameter of the gaussian filter. Default 24
% normConstant:     normalises the total mass of the heatmap distribution, essentially
%                   if we split the image in a normC x normC grid and fill one rectangle,
%                   the total mass is equal to the one of that filled rectangle. Default 9
arguments
    X (:,1) double
    Y (:,1) double
    W (:,1) double
    backimag (:,:,3) uint8
    opts.heatmap (1,3) cell = mat2cell(hot,256,[1 1 1])
    opts.sigma double = 24
    opts.normConstant double = 9
end

sigma = opts.sigma;
normConstant = opts.normConstant;
heatmap = opts.heatmap;


if isempty(W)
    W = ones(size(X));
end

assert(size(X,1) == size(Y,1) && size(W,1) == size(X,1), "input arrays should have the same length")

[dimY, dimX, ~] = size(backimag);

% create heatmap mask
mask = zeros(dimY, dimX);

for k = 1:size(X,1)
    mask(Y(k), X(k)) = mask(Y(k), X(k)) + W(k);
end

mask = imgaussfilt(mask, sigma);

% normalise mass of heatmap
normMask = dimX * dimY / normConstant^2 / sum(mask , [1 2]);
mask = mask * normMask;

% colour the heatmap on the background
for rgbInd = 1:3
    thisCol = uint8(mask*255);
    thisHeat = heatmap{rgbInd}( thisCol + 1 );
    backimag(:,:,rgbInd) = (backimag(:,:,rgbInd) + uint8(thisHeat*255));
end



end