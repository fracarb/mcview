function mapping = findSpatialDimensions(datasetInfo, variableInfo)
%FINDSPATIALDIMENSIONS Identifica dimensioni X/Y/Z da convenzioni CF e nomi.

    mapping = struct('x', 0, 'y', 0, 'z', 0);
    unclassified = [];
    for index = 1:numel(variableInfo.Dimensions)
        if variableInfo.Size(index) <= 1
            continue;
        end
        name = lower(variableInfo.Dimensions(index).Name);
        axisAttribute = '';
        standardName = '';
        coordinateUnits = '';
        coordinateInfo = mcv.findCoordinateVariable( ...
            datasetInfo, variableInfo.Dimensions(index).Name, variableInfo);
        if ~isempty(coordinateInfo)
            axisAttribute = lower(asText(mcv.getAttribute(coordinateInfo, 'axis', '')));
            standardName = lower(asText(mcv.getAttribute( ...
                coordinateInfo, 'standard_name', '')));
            coordinateUnits = lower(asText(mcv.getAttribute( ...
                coordinateInfo, 'units', '')));
        end

        if strcmp(axisAttribute, 'x') || ismember(name, ...
                {'x', 'lon', 'longitude', 'rlon'}) || ...
                any(strcmp(standardName, {'longitude', 'projection_x_coordinate'}))
            mapping.x = index;
        elseif strcmp(axisAttribute, 'y') || ismember(name, ...
                {'y', 'lat', 'latitude', 'rlat'}) || ...
                any(strcmp(standardName, {'latitude', 'projection_y_coordinate'}))
            mapping.y = index;
        elseif strcmp(axisAttribute, 'z') || ismember(name, ...
                {'z', 'lev', 'level', 'depth', 'height', 'altitude', 'pressure'}) || ...
                any(strcmp(standardName, {'depth', 'height', 'altitude', 'air_pressure'}))
            mapping.z = index;
        elseif strcmp(axisAttribute, 't') || strcmp(name, 'time') || ...
                strcmp(standardName, 'time') || ~isempty(strfind(coordinateUnits, ' since ')) %#ok<STREMP>
            % La dimensione temporale e una dimensione di scansione, non Z.
        else
            unclassified(end + 1) = index; %#ok<AGROW>
        end
    end

    fields = {'x', 'y', 'z'};
    for fieldIndex = 1:numel(fields)
        field = fields{fieldIndex};
        if mapping.(field) == 0 && ~isempty(unclassified)
            mapping.(field) = unclassified(1);
            unclassified(1) = [];
        end
    end
end

function value = asText(value)
    if isnumeric(value), value = num2str(value); end
    if iscell(value), value = value{1}; end
    value = char(value);
end
