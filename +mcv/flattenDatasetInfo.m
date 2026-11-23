function variables = flattenDatasetInfo(datasetInfo)
%FLATTENDATASETINFO Appiattisce ricorsivamente le variabili dei gruppi.

    variables = visitGroup(datasetInfo, '');
end

function variables = visitGroup(groupInfo, parentPath)
    variables = struct([]);
    if isempty(parentPath)
        groupPath = '';
    else
        groupPath = parentPath;
    end

    localVariables = groupInfo.Variables;
    for index = 1:numel(localVariables)
        variableInfo = localVariables(index);
        variableInfo.GroupPath = groupPath;
        variableInfo.Path = joinPath(groupPath, variableInfo.Name);
        if isempty(groupPath)
            variableInfo.DisplayName = variableInfo.Name;
        else
            variableInfo.DisplayName = variableInfo.Path;
        end
        variables = appendVariable(variables, variableInfo);
    end

    if ~isfield(groupInfo, 'Groups') || isempty(groupInfo.Groups)
        return;
    end
    for groupIndex = 1:numel(groupInfo.Groups)
        child = groupInfo.Groups(groupIndex);
        childPath = joinPath(groupPath, child.Name);
        childVariables = visitGroup(child, childPath);
        for variableIndex = 1:numel(childVariables)
            variables = appendVariable(variables, childVariables(variableIndex));
        end
    end
end

function variables = appendVariable(variables, variableInfo)
    if isempty(variables)
        variables = variableInfo;
    else
        variables(end + 1) = variableInfo;
    end
end

function path = joinPath(groupPath, name)
    name = char(name);
    while ~isempty(name) && name(1) == '/'
        name(1) = [];
    end
    if isempty(groupPath)
        path = ['/', name];
    else
        path = [groupPath, '/', name];
    end
end
