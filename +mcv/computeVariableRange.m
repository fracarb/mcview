function [limits, sampledValues] = computeVariableRange( ...
        source, variableInfo, method, progressCallback)
%COMPUTEVARIABLERANGE Calcola estremi completi o campionati di una variabile.

    if nargin < 3, method = 'fast'; end
    if nargin < 4, progressCallback = []; end
    sizes = double(variableInfo.Size(:))';
    dimensionCount = numel(sizes);
    sampledValues = [];
    limits = [Inf, -Inf];

    if dimensionCount == 0
        checkProgress(progressCallback, 1, 1);
        data = mcv.readVariableData(source, variableInfo, [], []);
        data = mcv.applyDataConventions(data, variableInfo);
        [sampledValues, localLimits] = finiteSample(data);
        limits = mergeLimits(limits, localLimits);
    else
        scanDimension = chooseScanDimension(variableInfo, sizes);
        if scanDimension == 0
            checkProgress(progressCallback, 1, 1);
            data = mcv.readVariableData(source, variableInfo, [], []);
            data = mcv.applyDataConventions(data, variableInfo);
            [sampledValues, localLimits] = finiteSample(data);
            limits = mergeLimits(limits, localLimits);
        else
            frameCount = sizes(scanDimension);
            if strcmp(method, 'all')
                frameIndices = 1:frameCount;
            else
                frameIndices = unique([1, ...
                    max(1, round((frameCount + 1) / 2)), frameCount]);
            end
            start = ones(1, dimensionCount);
            count = sizes;
            count(scanDimension) = 1;
            for position = 1:numel(frameIndices)
                checkProgress(progressCallback, position, numel(frameIndices));
                frameIndex = frameIndices(position);
                start(scanDimension) = frameIndex;
                data = mcv.readVariableData(source, variableInfo, start, count);
                data = mcv.applyDataConventions(data, variableInfo);
                [sample, localLimits] = finiteSample(data);
                sampledValues = [sampledValues; sample]; %#ok<AGROW>
                limits = mergeLimits(limits, localLimits);
            end
        end
    end

    if isempty(sampledValues)
        limits = [NaN, NaN];
    end
end

function dimension = chooseScanDimension(variableInfo, sizes)
    dimension = 0;
    if isfield(variableInfo, 'ConcatDimension') && variableInfo.ConcatDimension > 0
        dimension = variableInfo.ConcatDimension;
        return;
    end
    names = {};
    if ~isempty(variableInfo.Dimensions), names = {variableInfo.Dimensions.Name}; end
    timeMatch = find(strcmpi(names, 'time') | strcmpi(names, 't'), 1);
    if ~isempty(timeMatch)
        dimension = timeMatch;
        return;
    end
    candidates = find(sizes > 1);
    if numel(candidates) > 2
        dimension = candidates(end);
    end
end

function [values, limits] = finiteSample(data)
    values = double(data(isfinite(data)));
    if isempty(values)
        limits = [Inf, -Inf];
        return;
    end
    limits = [min(values), max(values)];
    maximumValues = 2000000;
    if numel(values) > maximumValues
        step = ceil(numel(values) / maximumValues);
        values = values(1:step:end);
    end
    values = values(:);
end

function combined = mergeLimits(current, candidate)
    combined = [min(current(1), candidate(1)), max(current(2), candidate(2))];
end

function checkProgress(callback, current, total)
    if isempty(callback), return; end
    keepGoing = callback(current, total);
    if ~keepGoing
        error('mcview:Cancelled', 'Operazione annullata.');
    end
end
