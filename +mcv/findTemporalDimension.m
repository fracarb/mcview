function index = findTemporalDimension(datasetInfo, variableInfo)
%FINDTEMPORALDIMENSION Trova l'asse temporale o di sequenza di una variabile.

    index = 0;
    if isfield(variableInfo, 'ConcatDimension') && ...
            ~isempty(variableInfo.ConcatDimension) && ...
            variableInfo.ConcatDimension > 0
        index = variableInfo.ConcatDimension;
        return;
    end

    if isempty(variableInfo.Dimensions)
        return;
    end
    names = {variableInfo.Dimensions.Name};
    for dimensionIndex = 1:numel(names)
        name = lower(names{dimensionIndex});
        if any(strcmp(name, {'time', 't', 'record', 'frame', 'snapshot', ...
                'file_index'})) || strncmp(name, 'file_index_', 11) || ...
                ~isempty(strfind(name, 'time')) %#ok<STREMP>
            index = dimensionIndex;
            return;
        end

        if ~isempty(datasetInfo)
            coordinate = mcv.findCoordinateVariable( ...
                datasetInfo, names{dimensionIndex}, variableInfo);
            if isTimeCoordinate(coordinate)
                index = dimensionIndex;
                return;
            end
        end
        if isfield(variableInfo.Dimensions, 'Unlimited') && ...
                variableInfo.Dimensions(dimensionIndex).Unlimited
            index = dimensionIndex;
            return;
        end
    end
end

function result = isTimeCoordinate(variableInfo)
    result = false;
    if isempty(variableInfo)
        return;
    end
    axisName = mcv.getAttribute(variableInfo, 'axis', '');
    standardName = mcv.getAttribute(variableInfo, 'standard_name', '');
    units = mcv.getAttribute(variableInfo, 'units', '');
    result = (ischar(axisName) && strcmpi(axisName, 'T')) || ...
        (ischar(standardName) && strcmpi(standardName, 'time')) || ...
        (ischar(units) && ~isempty(strfind(lower(units), ' since '))); %#ok<STREMP>
end
