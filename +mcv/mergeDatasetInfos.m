function mergedInfo = mergeDatasetInfos(filenames, infos)
%MERGEDATASETINFOS Crea un catalogo virtuale concatenando record temporali.

    mergedInfo = infos{1};
    mergedInfo.FileNames = filenames;
    mergedInfo.SourceInfos = infos;

    allPaths = {};
    for infoIndex = 1:numel(infos)
        variables = infos{infoIndex}.Variables;
        for variableIndex = 1:numel(variables)
            path = mcv.variablePath(variables(variableIndex));
            if ~any(strcmp(allPaths, path))
                allPaths{end + 1} = path; %#ok<AGROW>
            end
        end
    end

    mergedVariables = struct([]);
    for pathIndex = 1:numel(allPaths)
        path = allPaths{pathIndex};
        sourceVariables = {};
        sourceFiles = {};
        sourceInfos = {};
        for infoIndex = 1:numel(infos)
            paths = variablePaths(infos{infoIndex}.Variables);
            match = find(strcmp(paths, path), 1);
            if ~isempty(match)
                sourceVariables{end + 1} = infos{infoIndex}.Variables(match); %#ok<AGROW>
                sourceFiles{end + 1} = filenames{infoIndex}; %#ok<AGROW>
                sourceInfos{end + 1} = infos{infoIndex}; %#ok<AGROW>
            end
        end
        mergedVariable = mergeVariable( ...
            path, sourceFiles, sourceVariables, sourceInfos);
        if isempty(mergedVariables)
            mergedVariables = mergedVariable;
        else
            mergedVariables(end + 1) = mergedVariable;
        end
    end
    mergedInfo.Variables = mergedVariables;
end

function merged = mergeVariable(path, sourceFiles, sourceVariables, sourceInfos)
    merged = sourceVariables{1};
    concatDimension = findConcatDimension(sourceInfos{1}, merged);
    compatible = true(1, numel(sourceVariables));
    baseNames = dimensionNames(merged);
    baseSize = double(merged.Size(:))';

    if concatDimension == 0
        compatible(2:end) = false;
    else
        for index = 2:numel(sourceVariables)
            candidate = sourceVariables{index};
            candidateSize = double(candidate.Size(:))';
            sameDimensions = isequal(baseNames, dimensionNames(candidate));
            if numel(candidateSize) ~= numel(baseSize)
                sameOtherSizes = false;
            else
                compared = setdiff(1:numel(baseSize), concatDimension);
                sameOtherSizes = isequal(baseSize(compared), candidateSize(compared));
            end
            compatible(index) = sameDimensions && sameOtherSizes;
        end
    end

    sourceFiles = sourceFiles(compatible);
    sourceVariables = sourceVariables(compatible);
    sourcePaths = cell(1, numel(sourceVariables));
    sourceSizes = cell(1, numel(sourceVariables));
    for index = 1:numel(sourceVariables)
        sourcePaths{index} = mcv.variablePath(sourceVariables{index});
        sourceSizes{index} = double(sourceVariables{index}.Size(:))';
    end

    if concatDimension > 0 && numel(sourceVariables) > 1
        totalLength = 0;
        for index = 1:numel(sourceSizes)
            totalLength = totalLength + sourceSizes{index}(concatDimension);
        end
        merged.Size(concatDimension) = totalLength;
        if ~isempty(merged.Dimensions)
            merged.Dimensions(concatDimension).Length = totalLength;
        end
    else
        concatDimension = 0;
    end

    merged.Path = path;
    merged.SourceFiles = sourceFiles;
    merged.SourcePaths = sourcePaths;
    merged.SourceSizes = sourceSizes;
    merged.SourceVariableInfos = sourceVariables;
    merged.ConcatDimension = concatDimension;
end

function dimension = findConcatDimension(datasetInfo, variableInfo)
    dimension = 0;
    for index = 1:numel(variableInfo.Dimensions)
        if isfield(variableInfo.Dimensions, 'Unlimited') && ...
                variableInfo.Dimensions(index).Unlimited
            dimension = index;
            return;
        end
    end
    for index = 1:numel(variableInfo.Dimensions)
        name = lower(variableInfo.Dimensions(index).Name);
        if any(strcmp(name, {'time', 't', 'record'}))
            dimension = index;
            return;
        end
        coordinate = mcv.findCoordinateVariable( ...
            datasetInfo, variableInfo.Dimensions(index).Name, variableInfo);
        if ~isempty(coordinate)
            axisName = mcv.getAttribute(coordinate, 'axis', '');
            standardName = mcv.getAttribute(coordinate, 'standard_name', '');
            units = mcv.getAttribute(coordinate, 'units', '');
            if (ischar(axisName) && strcmpi(axisName, 'T')) || ...
                    (ischar(standardName) && strcmpi(standardName, 'time')) || ...
                    (ischar(units) && ~isempty(strfind(lower(units), ' since '))) %#ok<STREMP>
                dimension = index;
                return;
            end
        end
    end
end

function names = dimensionNames(variableInfo)
    if isempty(variableInfo.Dimensions)
        names = {};
    else
        names = {variableInfo.Dimensions.Name};
    end
end

function paths = variablePaths(variables)
    paths = cell(1, numel(variables));
    for index = 1:numel(variables)
        paths{index} = mcv.variablePath(variables(index));
    end
end
