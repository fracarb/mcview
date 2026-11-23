function variableInfo = findNamedVariable(datasetInfo, name, contextVariable)
%FINDNAMEDVARIABLE Trova una variabile per percorso assoluto o relativo al gruppo.

    variableInfo = struct([]);
    if isempty(name) || isempty(datasetInfo.Variables), return; end
    paths = cell(1, numel(datasetInfo.Variables));
    for index = 1:numel(datasetInfo.Variables)
        paths{index} = mcv.variablePath(datasetInfo.Variables(index));
    end
    if name(1) == '/'
        candidates = {name};
    else
        groupPath = '';
        if nargin >= 3 && ~isempty(contextVariable) && ...
                isfield(contextVariable, 'GroupPath')
            groupPath = contextVariable.GroupPath;
        end
        candidates = {['/', name]};
        if ~isempty(groupPath)
            candidates = [{[groupPath, '/', name]}, candidates];
        end
    end
    for candidateIndex = 1:numel(candidates)
        match = find(strcmp(paths, candidates{candidateIndex}), 1);
        if ~isempty(match)
            variableInfo = datasetInfo.Variables(match);
            return;
        end
    end
end
