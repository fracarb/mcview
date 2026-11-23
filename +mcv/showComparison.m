function figureHandle = showComparison(primary, secondary, operation)
%SHOWCOMPARISON Visualizza due slice oppure differenza/rapporto.

    validateCoordinates(primary, secondary);
    figureHandle = figure('Name', 'MCVIEW - Confronto', ...
        'NumberTitle', 'off', 'Color', [0.94, 0.94, 0.94], ...
        'Units', 'normalized', 'Position', [0.10, 0.12, 0.80, 0.72]);

    if strcmp(operation, 'side')
        firstAxes = subplot(1, 2, 1, 'Parent', figureHandle);
        secondAxes = subplot(1, 2, 2, 'Parent', figureHandle);
        drawSlice(firstAxes, primary);
        drawSlice(secondAxes, secondary);
        commonLimits = combinedLimits(primary.data, secondary.data);
        if ~isempty(commonLimits) && ~isvector(primary.data)
            caxis(firstAxes, commonLimits);
            caxis(secondAxes, commonLimits);
        end
    else
        if ~isequal(size(primary.data), size(secondary.data))
            error('mcview:IncompatibleComparison', ...
                'Le slice devono avere la stessa forma per differenza o rapporto.');
        end
        result = primary;
        if strcmp(operation, 'difference')
            result.data = double(primary.data) - double(secondary.data);
            result.title = sprintf('%s - %s', primary.title, secondary.title);
            result.variableName = sprintf('%s - %s', ...
                primary.variableName, secondary.variableName);
        else
            denominator = double(secondary.data);
            denominator(denominator == 0) = NaN;
            result.data = double(primary.data) ./ denominator;
            result.title = sprintf('%s / %s', primary.title, secondary.title);
            result.variableName = sprintf('%s / %s', ...
                primary.variableName, secondary.variableName);
            result.units = '1';
        end
        comparisonAxes = axes('Parent', figureHandle, 'Units', 'normalized', ...
            'Position', [0.10, 0.12, 0.82, 0.80]);
        drawSlice(comparisonAxes, result);
    end
end

function drawSlice(targetAxes, slice)
    data = double(slice.data);
    if isvector(data)
        plot(targetAxes, slice.x, data(:), 'LineWidth', 1.3);
        grid(targetAxes, 'on');
    else
        imagesc(targetAxes, slice.x, slice.y, data');
        set(targetAxes, 'YDir', 'normal');
        colorbarHandle = colorbar(targetAxes);
        mcv.setColorbarLabel(colorbarHandle, slice.variableName, slice.units);
    end
    xlabel(targetAxes, mcv.axisLabel(slice.axesInfo.x), 'Interpreter', 'none');
    if ~isempty(slice.axesInfo.y)
        ylabel(targetAxes, mcv.axisLabel(slice.axesInfo.y), 'Interpreter', 'none');
    elseif isfield(slice, 'units') && ~isempty(slice.units)
        ylabel(targetAxes, slice.units, 'Interpreter', 'none');
    end
    title(targetAxes, slice.title, 'Interpreter', 'none');
    try
        map = parula(256);
    catch
        map = jet(256);
    end
    try
        colormap(targetAxes, map);
    catch
        colormap(map);
    end
end

function validateCoordinates(primary, secondary)
    if ~sameCoordinate(primary.x, secondary.x) || ...
            ~sameCoordinate(primary.y, secondary.y)
        error('mcview:IncompatibleComparison', ...
            'Le coordinate delle due slice non coincidono.');
    end
end

function result = sameCoordinate(first, second)
    if isempty(first) && isempty(second)
        result = true;
        return;
    end
    if numel(first) ~= numel(second)
        result = false;
        return;
    end
    scale = max(1, max(abs(double(first(:)))));
    result = all(abs(double(first(:)) - double(second(:))) <= 1e-10 * scale);
end

function limits = combinedLimits(first, second)
    values = [double(first(isfinite(first))); double(second(isfinite(second)))];
    if isempty(values)
        limits = [];
        return;
    end
    limits = [min(values), max(values)];
    if limits(1) == limits(2)
        padding = max(1, abs(limits(1)) * 0.01);
        limits = limits + [-padding, padding];
    end
end
