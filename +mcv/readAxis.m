function axisInfo = readAxis( ...
        filename, datasetInfo, dimensionInfo, lengthExpected, contextVariable)
%READAXIS Legge valori e metadati CF di una dimensione.

    if nargin < 5
        contextVariable = struct([]);
    end

    axisInfo = struct( ...
        'name', dimensionInfo.Name, ...
        'longName', dimensionInfo.Name, ...
        'units', '', ...
        'standardName', '', ...
        'axis', '', ...
        'calendar', 'standard', ...
        'values', 1:lengthExpected, ...
        'plotValues', 1:lengthExpected, ...
        'isCoordinate', false, ...
        'isTime', false);

    if isempty(datasetInfo.Variables)
        return;
    end

    coordinateInfo = mcv.findCoordinateVariable( ...
        datasetInfo, dimensionInfo.Name, contextVariable);
    if isempty(coordinateInfo)
        return;
    end
    if prod(double(coordinateInfo.Size)) ~= lengthExpected
        return;
    end

    try
        candidate = mcv.readVariableData(filename, coordinateInfo, [], []);
    catch
        return;
    end
    if ~isnumeric(candidate) || numel(candidate) ~= lengthExpected
        return;
    end

    axisInfo.values = double(candidate(:))';
    axisInfo.plotValues = axisInfo.values;
    axisInfo.isCoordinate = true;
    axisInfo.longName = asText(mcv.getAttribute( ...
        coordinateInfo, 'long_name', dimensionInfo.Name));
    axisInfo.units = asText(mcv.getAttribute(coordinateInfo, 'units', ''));
    axisInfo.standardName = asText(mcv.getAttribute( ...
        coordinateInfo, 'standard_name', ''));
    axisInfo.axis = asText(mcv.getAttribute(coordinateInfo, 'axis', ''));
    axisInfo.calendar = asText(mcv.getAttribute( ...
        coordinateInfo, 'calendar', 'standard'));
    [converted, isTime] = mcv.decodeCFTime( ...
        axisInfo.values, axisInfo.units, axisInfo.calendar);
    if isTime
        axisInfo.plotValues = converted;
        axisInfo.isTime = true;
    end
end

function value = asText(value)
    if isnumeric(value)
        value = num2str(value);
    elseif iscell(value)
        value = value{1};
    end
    value = char(value);
end
