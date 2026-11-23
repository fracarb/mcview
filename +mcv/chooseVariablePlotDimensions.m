function [xDimension, yDimension] = chooseVariablePlotDimensions( ...
        datasetInfo, variableInfo)
%CHOOSEVARIABLEPLOTDIMENSIONS Sceglie gli assi usando prima i metadati CF.
%   L'ordine delle dimensioni nel file non implica che la prima sia X:
%   molti dataset dichiarano i campi come (lat, lon). Quando entrambi gli
%   assi spaziali sono riconoscibili, X deve essere longitudine e Y
%   latitudine indipendentemente dall'ordine NetCDF.

    lengths = double(variableInfo.Size(:))';
    [xDimension, yDimension] = mcv.choosePlotDimensions(lengths);
    mapping = mcv.findSpatialDimensions(datasetInfo, variableInfo);
    if mapping.x > 0 && mapping.y > 0 && mapping.x ~= mapping.y
        xDimension = mapping.x;
        yDimension = mapping.y;
    end
end
