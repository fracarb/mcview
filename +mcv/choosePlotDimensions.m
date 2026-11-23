function [xDimension, yDimension] = choosePlotDimensions(dimensionLengths)
%CHOOSEPLOTDIMENSIONS Sceglie le prime due dimensioni non singole.

    nonSingleton = find(dimensionLengths > 1);
    if isempty(nonSingleton)
        xDimension = 0;
        yDimension = 0;
    elseif numel(nonSingleton) == 1
        xDimension = nonSingleton(1);
        yDimension = 0;
    else
        xDimension = nonSingleton(1);
        yDimension = nonSingleton(2);
    end
end
