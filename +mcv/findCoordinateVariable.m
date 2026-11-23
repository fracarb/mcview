function coordinateInfo = findCoordinateVariable( ...
        datasetInfo, dimensionName, contextVariable)
%FINDCOORDINATEVARIABLE Trova coordinate dimensionali o ausiliarie CF.

    coordinateInfo = struct([]);
    if isempty(datasetInfo.Variables)
        return;
    end
    if nargin < 3
        contextVariable = struct();
    end

    tokens = {dimensionName};
    if ~isempty(contextVariable) && isfield(contextVariable, 'Attributes')
        coordinates = mcv.getAttribute(contextVariable, 'coordinates', '');
        if ischar(coordinates)
            auxiliary = regexp(strtrim(coordinates), '\s+', 'split');
            if ~(numel(auxiliary) == 1 && isempty(auxiliary{1}))
                tokens = [tokens, auxiliary]; %#ok<AGROW>
            end
        end
    end

    contextPath = '';
    if ~isempty(contextVariable) && isfield(contextVariable, 'GroupPath')
        contextPath = contextVariable.GroupPath;
    end
    paths = cellfun(@mcv.variablePath, num2cell(datasetInfo.Variables), ...
        'UniformOutput', false);

    candidates = {};
    for tokenIndex = 1:numel(tokens)
        token = tokens{tokenIndex};
        if isempty(token), continue; end
        if token(1) == '/'
            candidates{end + 1} = token; %#ok<AGROW>
        else
            if ~isempty(contextPath)
                candidates{end + 1} = [contextPath, '/', token]; %#ok<AGROW>
            end
            candidates{end + 1} = ['/', token]; %#ok<AGROW>
        end
    end

    for candidateIndex = 1:numel(candidates)
        match = find(strcmp(paths, candidates{candidateIndex}), 1);
        if ~isempty(match)
            candidate = datasetInfo.Variables(match);
            if coordinateMatchesDimension(candidate, dimensionName)
                coordinateInfo = candidate;
                return;
            end
        end
    end

    names = {datasetInfo.Variables.Name};
    matches = find(strcmp(names, dimensionName));
    if numel(matches) == 1
        coordinateInfo = datasetInfo.Variables(matches);
    end
end

function matches = coordinateMatchesDimension(variableInfo, dimensionName)
    matches = strcmp(variableInfo.Name, dimensionName);
    if matches
        return;
    end
    if isfield(variableInfo, 'Dimensions') && numel(variableInfo.Dimensions) == 1
        matches = strcmp(variableInfo.Dimensions(1).Name, dimensionName);
    end
end
