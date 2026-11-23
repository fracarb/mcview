function [labels, variableIndices, groupPaths, expandedGroups] = ...
        variableTreeRows(datasetInfo, expandedGroups)
%VARIABLETREEROWS Costruisce un albero portabile per il listbox della GUI.
%   Le righe di gruppo hanno indice variabile zero e un GroupPath non vuoto.
%   Senza EXPANDEDGROUPS tutti i gruppi vengono inizialmente espansi.

    variables = datasetInfo.Variables;
    allGroupPaths = collectGroupPaths(variables);
    if nargin < 2
        expandedGroups = allGroupPaths;
    else
        expandedGroups = asCellText(expandedGroups);
    end

    labels = {'(nessuna variabile)'};
    variableIndices = 0;
    groupPaths = {''};
    visitGroup('', 0);

    function visitGroup(parentPath, depth)
        for variableIndex = 1:numel(variables)
            if strcmp(variableGroupPath(variables(variableIndex)), parentPath)
                indentation = repmat('  ', 1, depth + 1);
                labels{end + 1} = [indentation, variables(variableIndex).Name]; %#ok<AGROW>
                variableIndices(end + 1) = variableIndex; %#ok<AGROW>
                groupPaths{end + 1} = ''; %#ok<AGROW>
            end
        end

        children = directChildren(allGroupPaths, parentPath);
        for childIndex = 1:numel(children)
            childPath = children{childIndex};
            isExpanded = any(strcmp(expandedGroups, childPath));
            if isExpanded
                marker = '[-] ';
            else
                marker = '[+] ';
            end
            indentation = repmat('  ', 1, depth);
            labels{end + 1} = [indentation, marker, localName(childPath)]; %#ok<AGROW>
            variableIndices(end + 1) = 0; %#ok<AGROW>
            groupPaths{end + 1} = childPath; %#ok<AGROW>
            if isExpanded
                visitGroup(childPath, depth + 1);
            end
        end
    end
end

function paths = collectGroupPaths(variables)
    paths = {};
    for variableIndex = 1:numel(variables)
        groupPath = variableGroupPath(variables(variableIndex));
        ancestors = {};
        while ~isempty(groupPath)
            ancestors = [{groupPath}, ancestors]; %#ok<AGROW>
            groupPath = parentPath(groupPath);
        end
        for ancestorIndex = 1:numel(ancestors)
            if ~any(strcmp(paths, ancestors{ancestorIndex}))
                paths{end + 1} = ancestors{ancestorIndex}; %#ok<AGROW>
            end
        end
    end
end

function children = directChildren(paths, parent)
    children = {};
    for pathIndex = 1:numel(paths)
        if strcmp(parentPath(paths{pathIndex}), parent)
            children{end + 1} = paths{pathIndex}; %#ok<AGROW>
        end
    end
end

function path = variableGroupPath(variableInfo)
    if isfield(variableInfo, 'GroupPath') && ~isempty(variableInfo.GroupPath)
        path = char(variableInfo.GroupPath);
        return;
    end
    path = mcv.variablePath(variableInfo);
    path = parentPath(path);
end

function parent = parentPath(path)
    separators = find(path == '/');
    if isempty(separators) || separators(end) == 1
        parent = '';
    else
        parent = path(1:separators(end) - 1);
    end
end

function name = localName(path)
    separators = find(path == '/');
    if isempty(separators)
        name = path;
    else
        name = path(separators(end) + 1:end);
    end
end

function values = asCellText(values)
    if ischar(values)
        values = {values};
    elseif exist('isstring', 'builtin') ~= 0 && isstring(values)
        values = cellstr(values);
    end
end
