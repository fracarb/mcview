function [data, selection] = readVariableSnapshots( ...
        source, variableInfo, snapshotDimension, snapshotIndices)
%READVARIABLESNAPSHOTS Legge snapshot arbitrari preservando l'ordine nativo.

    dimensionLengths = double(variableInfo.Size(:))';
    dimensionCount = numel(dimensionLengths);
    if snapshotDimension < 1 || snapshotDimension > dimensionCount || ...
            snapshotDimension ~= floor(snapshotDimension)
        error('mcview:InvalidSnapshotDimension', ...
            'Dimensione degli snapshot non valida.');
    end
    snapshotIndices = double(snapshotIndices(:))';
    if isempty(snapshotIndices) || any(~isfinite(snapshotIndices)) || ...
            any(snapshotIndices ~= floor(snapshotIndices)) || ...
            any(snapshotIndices < 1) || ...
            any(snapshotIndices > dimensionLengths(snapshotDimension))
        error('mcview:InvalidSnapshotIndices', ...
            'Gli indici degli snapshot non sono validi.');
    end

    requestedSize = dimensionLengths;
    requestedSize(snapshotDimension) = 1;
    pieces = cell(1, numel(snapshotIndices));
    for snapshotIndex = 1:numel(snapshotIndices)
        start = ones(1, dimensionCount);
        start(snapshotDimension) = snapshotIndices(snapshotIndex);
        raw = mcv.readVariableData(source, variableInfo, start, requestedSize);
        pieces{snapshotIndex} = reshapeSelection(raw, requestedSize);
    end
    if numel(pieces) == 1
        rawData = pieces{1};
    else
        rawData = cat(snapshotDimension, pieces{:});
    end
    data = mcv.applyDataConventions(rawData, variableInfo);

    exportedSize = dimensionLengths;
    exportedSize(snapshotDimension) = numel(snapshotIndices);
    selection = struct( ...
        'mode', 'snapshots', ...
        'snapshotDimension', snapshotDimension, ...
        'snapshotIndices', snapshotIndices, ...
        'originalSize', dimensionLengths, ...
        'exportedSize', exportedSize);
end

function data = reshapeSelection(data, requestedSize)
    if numel(requestedSize) == 1
        data = reshape(data, [requestedSize(1), 1]);
    else
        data = reshape(data, requestedSize);
    end
end
