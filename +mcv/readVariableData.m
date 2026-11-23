function data = readVariableData(defaultSource, variableInfo, start, count)
%READVARIABLEDATA Legge una variabile singola o concatenata su piu file.

    if isfield(variableInfo, 'SourceFiles') && ~isempty(variableInfo.SourceFiles)
        sourceFiles = variableInfo.SourceFiles;
        sourcePaths = variableInfo.SourcePaths;
        sourceSizes = variableInfo.SourceSizes;
        concatDimension = variableInfo.ConcatDimension;
    else
        if iscell(defaultSource)
            sourceFiles = defaultSource(1);
        else
            sourceFiles = {defaultSource};
        end
        sourcePaths = {mcv.variablePath(variableInfo)};
        sourceSizes = {double(variableInfo.Size(:))'};
        concatDimension = 0;
    end

    if nargin < 3 || isempty(start)
        if numel(sourceFiles) == 1 || concatDimension == 0
            data = ncread(sourceFiles{1}, mcv.netcdfReadPath(sourcePaths{1}));
            return;
        end
        start = ones(1, numel(variableInfo.Size));
        count = double(variableInfo.Size(:))';
    end
    start = double(start(:))';
    count = double(count(:))';

    if numel(sourceFiles) == 1 || concatDimension == 0
        data = ncread(sourceFiles{1}, ...
            mcv.netcdfReadPath(sourcePaths{1}), start, count);
        return;
    end

    firstRequested = start(concatDimension);
    lastRequested = firstRequested + count(concatDimension) - 1;
    pieces = {};
    offset = 0;
    for sourceIndex = 1:numel(sourceFiles)
        localSize = sourceSizes{sourceIndex}(concatDimension);
        sourceFirst = offset + 1;
        sourceLast = offset + localSize;
        overlapFirst = max(firstRequested, sourceFirst);
        overlapLast = min(lastRequested, sourceLast);
        if overlapFirst <= overlapLast
            localStart = start;
            localCount = count;
            localStart(concatDimension) = overlapFirst - offset;
            localCount(concatDimension) = overlapLast - overlapFirst + 1;
            piece = ncread(sourceFiles{sourceIndex}, ...
                mcv.netcdfReadPath(sourcePaths{sourceIndex}), ...
                localStart, localCount);
            piece = reshapeForCount(piece, localCount);
            pieces{end + 1} = piece; %#ok<AGROW>
        end
        offset = sourceLast;
    end
    if isempty(pieces)
        data = [];
    elseif numel(pieces) == 1
        data = pieces{1};
    else
        data = cat(concatDimension, pieces{:});
    end
end

function shaped = reshapeForCount(data, count)
    if numel(count) == 1
        shaped = reshape(data, [count(1), 1]);
    else
        shaped = reshape(data, count);
    end
end
