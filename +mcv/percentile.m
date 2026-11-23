function value = percentile(values, percentage)
%PERCENTILE Percentile lineare senza dipendenze da toolbox.

    values = sort(double(values(isfinite(values))));
    if isempty(values)
        value = NaN;
        return;
    end
    percentage = max(0, min(100, double(percentage)));
    position = 1 + (numel(values) - 1) * percentage / 100;
    lower = floor(position);
    upper = ceil(position);
    if lower == upper
        value = values(lower);
    else
        weight = position - lower;
        value = values(lower) * (1 - weight) + values(upper) * weight;
    end
end
