function [data, xCoordinate, yCoordinate, sampling] = downsampleSlice( ...
        data, xCoordinate, yCoordinate, maximumPixels)
%DOWNSAMPLESLICE Riduce una slice mantenendo primo e ultimo indice.

    sampling = struct('xIndices', 1:size(data, 1), ...
        'yIndices', 1:max(1, size(data, 2)), 'wasDownsampled', false);
    if nargin < 4 || isempty(maximumPixels) || maximumPixels <= 0 || ...
            numel(data) <= maximumPixels
        return;
    end

    scale = sqrt(numel(data) / maximumPixels);
    xStep = max(1, ceil(scale));
    yStep = max(1, ceil(scale));
    xIndices = unique([1:xStep:size(data, 1), size(data, 1)]);
    if isvector(data)
        yIndices = 1;
        data = data(xIndices);
    else
        yIndices = unique([1:yStep:size(data, 2), size(data, 2)]);
        data = data(xIndices, yIndices);
    end
    xCoordinate = subsetCoordinate(xCoordinate, xIndices, yIndices, true);
    yCoordinate = subsetCoordinate(yCoordinate, xIndices, yIndices, false);
    sampling.xIndices = xIndices;
    sampling.yIndices = yIndices;
    sampling.wasDownsampled = true;
end

function coordinate = subsetCoordinate(coordinate, xIndices, yIndices, isX)
    if isempty(coordinate), return; end
    if isvector(coordinate)
        if isX
            coordinate = coordinate(xIndices);
        else
            coordinate = coordinate(yIndices);
        end
    else
        coordinate = coordinate(xIndices, yIndices);
    end
end
