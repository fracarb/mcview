function figureHandle = showAttributes(datasetInfo, variableInfo)
%SHOWATTRIBUTES Mostra attributi globali, variabile e coordinate.

    if nargin < 2, variableInfo = struct([]); end
    scopes = {'Globali'};
    attributeSets = {datasetInfo.Attributes};
    if ~isempty(variableInfo)
        scopes{end + 1} = sprintf('Variabile: %s', variableInfo.Name);
        attributeSets{end + 1} = variableInfo.Attributes;
    end
    if ~isempty(variableInfo) && isfield(variableInfo, 'Dimensions')
        for index = 1:numel(variableInfo.Dimensions)
            dimensionName = variableInfo.Dimensions(index).Name;
            coordinateInfo = mcv.findCoordinateVariable( ...
                datasetInfo, dimensionName, variableInfo);
            if ~isempty(coordinateInfo)
                scopes{end + 1} = sprintf('Coordinata: %s', dimensionName); %#ok<AGROW>
                attributeSets{end + 1} = coordinateInfo.Attributes; %#ok<AGROW>
            end
        end
    end

    figureHandle = figure('Name', 'MCVIEW - Attributi NetCDF', ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'Color', [0.94, 0.94, 0.94], 'Units', 'normalized', ...
        'Position', [0.20, 0.18, 0.60, 0.60]);
    popup = uicontrol(figureHandle, 'Style', 'popupmenu', 'String', scopes, ...
        'Units', 'normalized', 'Position', [0.025, 0.925, 0.45, 0.05], ...
        'BackgroundColor', [1, 1, 1], 'Callback', @updateTable);
    tableHandle = uitable('Parent', figureHandle, 'Units', 'normalized', ...
        'Position', [0.025, 0.055, 0.95, 0.84], ...
        'ColumnName', {'Nome', 'Valore', 'Tipo'}, ...
        'ColumnWidth', {170, 430, 100}, 'RowName', []);
    updateTable(popup, []);

    function updateTable(source, ~)
        attributes = attributeSets{get(source, 'Value')};
        if isempty(attributes)
            rows = {'(nessun attributo)', '', ''};
        else
            rows = cell(numel(attributes), 3);
            for attributeIndex = 1:numel(attributes)
                rows{attributeIndex, 1} = attributes(attributeIndex).Name;
                rows{attributeIndex, 2} = mcv.formatAttributeValue( ...
                    attributes(attributeIndex).Value);
                rows{attributeIndex, 3} = class(attributes(attributeIndex).Value);
            end
        end
        set(tableHandle, 'Data', rows);
    end
end
