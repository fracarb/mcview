function data = prepareSlice(rawData, count, xDimension, yDimension)
%PREPARESLICE Riordina una lettura ncread per il rendering 1D/2D.
%   Le dimensioni X e Y vengono portate davanti. Tutte le altre devono
%   essere state lette con count uguale a 1.

    count = double(count(:))';
    dimensionCount = numel(count);

    if dimensionCount == 0
        data = rawData;
        return;
    elseif dimensionCount == 1
        shaped = reshape(rawData, [count(1), 1]);
    else
        shaped = reshape(rawData, count);
    end

    plotDimensions = [xDimension, yDimension];
    plotDimensions = plotDimensions(plotDimensions > 0);
    remaining = setdiff(1:dimensionCount, plotDimensions, 'stable');
    if any(count(remaining) ~= 1)
        error('mcview:SliceNotReduced', ...
            'Le dimensioni non visualizzate devono avere count uguale a 1.');
    end
    order = [plotDimensions, remaining];
    if ~isempty(order) && numel(order) > 1
        shaped = permute(shaped, order);
    end

    if xDimension == 0
        data = shaped(1);
    elseif yDimension == 0
        data = reshape(shaped, [count(xDimension), 1]);
    else
        data = reshape(shaped, [count(xDimension), count(yDimension)]);
    end
end
