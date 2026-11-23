function [xGrid, yGrid, axesInfo, found] = readCurvilinearCoordinates( ...
        source, datasetInfo, variableInfo, xDimension, yDimension, indices)
%READCURVILINEARCOORDINATES Legge lon/lat ausiliarie 2D secondo CF.

    xGrid = [];
    yGrid = [];
    axesInfo = struct('x', [], 'y', []);
    found = false;
    if xDimension == 0 || yDimension == 0, return; end
    coordinatesAttribute = mcv.getAttribute(variableInfo, 'coordinates', '');
    if ~ischar(coordinatesAttribute) || isempty(strtrim(coordinatesAttribute))
        return;
    end
    tokens = regexp(strtrim(coordinatesAttribute), '\s+', 'split');
    longitudeInfo = struct([]);
    latitudeInfo = struct([]);
    for tokenIndex = 1:numel(tokens)
        candidate = mcv.findNamedVariable( ...
            datasetInfo, tokens{tokenIndex}, variableInfo);
        if isempty(candidate), continue; end
        if isLongitude(candidate)
            longitudeInfo = candidate;
        elseif isLatitude(candidate)
            latitudeInfo = candidate;
        end
    end
    if isempty(longitudeInfo) || isempty(latitudeInfo), return; end

    xName = variableInfo.Dimensions(xDimension).Name;
    yName = variableInfo.Dimensions(yDimension).Name;
    [xGrid, validX] = readGrid(source, longitudeInfo, ...
        variableInfo, xName, yName, indices);
    [yGrid, validY] = readGrid(source, latitudeInfo, ...
        variableInfo, xName, yName, indices);
    if ~validX || ~validY || ~isequal(size(xGrid), size(yGrid))
        xGrid = [];
        yGrid = [];
        return;
    end
    axesInfo.x = coordinateAxisInfo(longitudeInfo, xGrid, 'longitude');
    axesInfo.y = coordinateAxisInfo(latitudeInfo, yGrid, 'latitude');
    found = true;
end

function [grid, valid] = readGrid(source, coordinateInfo, ...
        dataVariable, xName, yName, dataIndices)
    coordinateNames = {coordinateInfo.Dimensions.Name};
    xPosition = find(strcmp(coordinateNames, xName), 1);
    yPosition = find(strcmp(coordinateNames, yName), 1);
    valid = ~isempty(xPosition) && ~isempty(yPosition);
    grid = [];
    if ~valid, return; end

    sizes = double(coordinateInfo.Size(:))';
    start = ones(1, numel(sizes));
    count = sizes;
    dataNames = {dataVariable.Dimensions.Name};
    for dimension = 1:numel(sizes)
        if dimension == xPosition || dimension == yPosition, continue; end
        dataDimension = find(strcmp(dataNames, coordinateNames{dimension}), 1);
        count(dimension) = 1;
        if ~isempty(dataDimension) && dataDimension <= numel(dataIndices)
            start(dimension) = min(dataIndices(dataDimension), sizes(dimension));
        end
    end
    raw = mcv.readVariableData(source, coordinateInfo, start, count);
    grid = mcv.prepareSlice(raw, count, xPosition, yPosition);
    grid = double(grid);
end

function info = coordinateAxisInfo(variableInfo, values, defaultName)
    info = struct();
    info.name = variableInfo.Name;
    info.longName = asText(mcv.getAttribute(variableInfo, 'long_name', defaultName));
    info.units = asText(mcv.getAttribute(variableInfo, 'units', ''));
    info.standardName = asText(mcv.getAttribute( ...
        variableInfo, 'standard_name', defaultName));
    info.axis = asText(mcv.getAttribute(variableInfo, 'axis', ''));
    info.calendar = 'standard';
    info.values = values;
    info.plotValues = values;
    info.isCoordinate = true;
    info.isTime = false;
end

function result = isLongitude(info)
    standardName = asText(mcv.getAttribute(info, 'standard_name', ''));
    units = asText(mcv.getAttribute(info, 'units', ''));
    result = strcmpi(standardName, 'longitude') || ...
        ~isempty(strfind(lower(units), 'degrees_east')) || ... %#ok<STREMP>
        any(strcmpi(info.Name, {'lon', 'longitude'}));
end

function result = isLatitude(info)
    standardName = asText(mcv.getAttribute(info, 'standard_name', ''));
    units = asText(mcv.getAttribute(info, 'units', ''));
    result = strcmpi(standardName, 'latitude') || ...
        ~isempty(strfind(lower(units), 'degrees_north')) || ... %#ok<STREMP>
        any(strcmpi(info.Name, {'lat', 'latitude'}));
end

function value = asText(value)
    if isnumeric(value), value = num2str(value); end
    if iscell(value), value = value{1}; end
    value = char(value);
end
