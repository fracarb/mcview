function [data, xCoordinate, yCoordinate, selection, axesInfo] = readVariableSlice( ...
        filename, datasetInfo, variableInfo, xDimension, yDimension, indices)
%READVARIABLESLICE Legge una fetta 1D o 2D di una variabile NetCDF.

    dimensionCount = numel(variableInfo.Dimensions);
    dimensionLengths = double(variableInfo.Size(:))';
    axesInfo = struct('x', [], 'y', []);
    if dimensionCount == 0
        rawData = mcv.readVariableData(filename, variableInfo, [], []);
        data = mcv.applyDataConventions(rawData, variableInfo);
        xCoordinate = [];
        yCoordinate = [];
        selection = struct('start', [], 'count', []);
        return;
    end

    if numel(indices) ~= dimensionCount
        indices = ones(1, dimensionCount);
    end
    indices = max(1, min(round(double(indices(:))'), dimensionLengths));

    start = indices;
    count = ones(1, dimensionCount);
    if xDimension > 0
        start(xDimension) = 1;
        count(xDimension) = dimensionLengths(xDimension);
    end
    if yDimension > 0
        start(yDimension) = 1;
        count(yDimension) = dimensionLengths(yDimension);
    end

    if any(dimensionLengths == 0)
        data = [];
        xCoordinate = [];
        yCoordinate = [];
        selection = struct('start', start, 'count', count);
        return;
    end

    rawData = mcv.readVariableData(filename, variableInfo, start, count);
    data = mcv.prepareSlice(rawData, count, xDimension, yDimension);
    data = mcv.applyDataConventions(data, variableInfo);

    if xDimension > 0
        xInfo = variableInfo.Dimensions(xDimension);
        [xCoordinate, axesInfo.x] = mcv.readCoordinate( ...
            filename, datasetInfo, xInfo.Name, dimensionLengths(xDimension), variableInfo);
    else
        xCoordinate = [];
    end
    if yDimension > 0
        yInfo = variableInfo.Dimensions(yDimension);
        [yCoordinate, axesInfo.y] = mcv.readCoordinate( ...
            filename, datasetInfo, yInfo.Name, dimensionLengths(yDimension), variableInfo);
    else
        yCoordinate = [];
    end

    if xDimension > 0 && yDimension > 0
        [curvilinearX, curvilinearY, curvilinearAxes, foundCurvilinear] = ...
            mcv.readCurvilinearCoordinates(filename, datasetInfo, variableInfo, ...
            xDimension, yDimension, indices);
        if foundCurvilinear
            xCoordinate = curvilinearX;
            yCoordinate = curvilinearY;
            axesInfo = curvilinearAxes;
        end
    end

    selection = struct('start', start, 'count', count);
end
