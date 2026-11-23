function textValue = formatAxisValue(axisInfo, index, secondIndex, precision)
%FORMATAXISVALUE Formatta una coordinata numerica o temporale CF.

    if nargin < 3
        secondIndex = [];
    end
    if nargin < 4
        precision = 10;
    end

    if ~isempty(secondIndex) && ~isvector(axisInfo.values)
        linearIndex = sub2ind(size(axisInfo.values), index, secondIndex);
    else
        linearIndex = index;
    end

    if axisInfo.isTime
        if isfield(axisInfo, 'timeLabels') && ...
                numel(axisInfo.timeLabels) >= linearIndex && ...
                ~isempty(axisInfo.timeLabels{linearIndex})
            textValue = axisInfo.timeLabels{linearIndex};
        else
            textValue = datestr( ...
                axisInfo.plotValues(linearIndex), 'yyyy-mm-dd HH:MM:SS');
        end
    else
        textValue = num2str(axisInfo.values(linearIndex), precision);
    end
end
