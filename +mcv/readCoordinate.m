function [coordinate, axisInfo] = readCoordinate( ...
        filename, datasetInfo, dimensionName, lengthExpected, contextVariable)
%READCOORDINATE Legge una variabile coordinata oppure usa indici 1:N.

    dimensionInfo = struct('Name', dimensionName);
    if nargin < 5
        contextVariable = struct([]);
    end
    axisInfo = mcv.readAxis( ...
        filename, datasetInfo, dimensionInfo, lengthExpected, contextVariable);
    coordinate = axisInfo.plotValues;
end
