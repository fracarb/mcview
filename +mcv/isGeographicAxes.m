function [result, axesSwapped] = isGeographicAxes(axesInfo)
%ISGEOGRAPHICAXES Riconosce una coppia longitudine/latitudine CF.

    result = false;
    axesSwapped = false;
    if isempty(axesInfo) || isempty(axesInfo.x) || isempty(axesInfo.y)
        return;
    end
    normalOrder = isLongitude(axesInfo.x) && isLatitude(axesInfo.y);
    axesSwapped = isLatitude(axesInfo.x) && isLongitude(axesInfo.y);
    result = normalOrder || axesSwapped;
end

function result = isLongitude(info)
    result = (strcmpi(info.axis, 'X') && containsText(info.units, 'degree')) || ...
        strcmpi(info.standardName, 'longitude') || ...
        containsText(info.units, 'degrees_east') || ...
        any(strcmpi(info.name, {'lon', 'longitude'}));
end

function result = isLatitude(info)
    result = (strcmpi(info.axis, 'Y') && containsText(info.units, 'degree')) || ...
        strcmpi(info.standardName, 'latitude') || ...
        containsText(info.units, 'degrees_north') || ...
        any(strcmpi(info.name, {'lat', 'latitude'}));
end

function result = containsText(text, pattern)
    result = ischar(text) && ~isempty(strfind(lower(text), lower(pattern))); %#ok<STREMP>
end
