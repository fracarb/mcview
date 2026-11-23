function [xDimension, yDimension, indices] = matchSliceDimensions( ...
        referenceVariable, targetVariable, referenceX, referenceY, referenceIndices)
%MATCHSLICEDIMENSIONS Allinea una variabile alle dimensioni della vista.

    referenceNames = dimensionNames(referenceVariable);
    targetNames = dimensionNames(targetVariable);
    indices = ones(1, numel(targetNames));

    for targetIndex = 1:numel(targetNames)
        referenceIndex = find(strcmp(referenceNames, targetNames{targetIndex}), 1);
        if ~isempty(referenceIndex) && referenceIndex <= numel(referenceIndices)
            indices(targetIndex) = min( ...
                referenceIndices(referenceIndex), targetVariable.Size(targetIndex));
        end
    end

    xDimension = matchingDimension(referenceNames, targetNames, referenceX);
    yDimension = matchingDimension(referenceNames, targetNames, referenceY);
    if referenceX > 0 && xDimension == 0
        error('mcview:IncompatibleComparison', ...
            'La variabile di confronto non possiede la dimensione %s.', ...
            referenceNames{referenceX});
    end
    if referenceY > 0 && yDimension == 0
        error('mcview:IncompatibleComparison', ...
            'La variabile di confronto non possiede la dimensione %s.', ...
            referenceNames{referenceY});
    end
end

function index = matchingDimension(referenceNames, targetNames, referenceIndex)
    if referenceIndex == 0
        index = 0;
        return;
    end
    index = find(strcmp(targetNames, referenceNames{referenceIndex}), 1);
    if isempty(index), index = 0; end
end

function names = dimensionNames(variableInfo)
    if isempty(variableInfo.Dimensions)
        names = {};
    else
        names = {variableInfo.Dimensions.Name};
    end
end
