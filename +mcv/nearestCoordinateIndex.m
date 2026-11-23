function [index, actualValue] = nearestCoordinateIndex(values, requestedValue)
%NEARESTCOORDINATEINDEX Trova l'indice della coordinata finita piu vicina.

    values = double(values(:));
    finiteIndices = find(isfinite(values));
    if isempty(finiteIndices) || ~isfinite(requestedValue)
        index = [];
        actualValue = [];
        return;
    end
    [~, localIndex] = min(abs(values(finiteIndices) - requestedValue));
    index = finiteIndices(localIndex);
    actualValue = values(index);
end
