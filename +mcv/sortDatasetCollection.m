function [filenames, infos] = sortDatasetCollection(filenames, infos)
%SORTDATASETCOLLECTION Ordina i file usando la prima coordinata temporale.

    keys = NaN(1, numel(infos));
    for infoIndex = 1:numel(infos)
        variables = infos{infoIndex}.Variables;
        for variableIndex = 1:numel(variables)
            variableInfo = variables(variableIndex);
            if ~isTimeCoordinate(variableInfo)
                continue;
            end
            try
                path = mcv.netcdfReadPath(mcv.variablePath(variableInfo));
                values = ncread(filenames{infoIndex}, path);
                if isempty(values), continue; end
                units = mcv.getAttribute(variableInfo, 'units', '');
                calendar = mcv.getAttribute(variableInfo, 'calendar', 'standard');
                [converted, isTime] = mcv.decodeCFTime(double(values(1)), units, calendar);
                if isTime
                    keys(infoIndex) = converted(1);
                else
                    keys(infoIndex) = double(values(1));
                end
                break;
            catch
            end
        end
    end
    if sum(isfinite(keys)) < 2
        return;
    end
    sortableKeys = keys;
    sortableKeys(~isfinite(sortableKeys)) = Inf;
    originalOrder = 1:numel(infos);
    [~, order] = sortrows([sortableKeys(:), originalOrder(:)], [1, 2]);
    filenames = filenames(order);
    infos = infos(order);
end

function result = isTimeCoordinate(variableInfo)
    name = lower(variableInfo.Name);
    axisName = mcv.getAttribute(variableInfo, 'axis', '');
    standardName = mcv.getAttribute(variableInfo, 'standard_name', '');
    units = mcv.getAttribute(variableInfo, 'units', '');
    result = strcmp(name, 'time') || ...
        (ischar(axisName) && strcmpi(axisName, 'T')) || ...
        (ischar(standardName) && strcmpi(standardName, 'time')) || ...
        (ischar(units) && ~isempty(strfind(lower(units), ' since '))); %#ok<STREMP>
end
