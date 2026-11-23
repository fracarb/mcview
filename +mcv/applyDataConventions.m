function data = applyDataConventions(data, variableInfo)
%APPLYDATACONVENTIONS Applica missing_value e intervalli validi ai dati letti.

    if ~(isnumeric(data) || islogical(data))
        return;
    end
    missingValues = mcv.getAttribute(variableInfo, 'missing_value', []);
    if isempty(missingValues) || ~isnumeric(missingValues)
        missingValues = [];
    end
    converted = double(data);
    scaleFactor = mcv.getAttribute(variableInfo, 'scale_factor', 1);
    addOffset = mcv.getAttribute(variableInfo, 'add_offset', 0);
    if ~isnumeric(scaleFactor) || ~isscalar(scaleFactor), scaleFactor = 1; end
    if ~isnumeric(addOffset) || ~isscalar(addOffset), addOffset = 0; end
    for index = 1:numel(missingValues)
        unpackedMissing = double(missingValues(index)) * double(scaleFactor) + double(addOffset);
        converted(converted == unpackedMissing) = NaN;
    end

    validRange = mcv.getAttribute(variableInfo, 'valid_range', []);
    if isnumeric(validRange) && numel(validRange) >= 2
        limits = double(validRange(1:2)) .* double(scaleFactor) + double(addOffset);
        limits = sort(limits);
        converted(converted < limits(1) | converted > limits(2)) = NaN;
    else
        validMinimum = mcv.getAttribute(variableInfo, 'valid_min', []);
        validMaximum = mcv.getAttribute(variableInfo, 'valid_max', []);
        if isnumeric(validMinimum) && isscalar(validMinimum)
            limit = double(validMinimum) * double(scaleFactor) + double(addOffset);
            if scaleFactor >= 0
                converted(converted < limit) = NaN;
            else
                converted(converted > limit) = NaN;
            end
        end
        if isnumeric(validMaximum) && isscalar(validMaximum)
            limit = double(validMaximum) * double(scaleFactor) + double(addOffset);
            if scaleFactor >= 0
                converted(converted > limit) = NaN;
            else
                converted(converted < limit) = NaN;
            end
        end
    end
    data = converted;
end
