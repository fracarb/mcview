function [dateNumbers, isTime, dateLabels, isNonGregorian] = ...
        decodeCFTime(values, units, calendar)
%DECODECFTIME Converte un asse "unit since ISO-date" in un asse temporale.
%   I calendari 360_day, noleap/365_day e all_leap/366_day usano un asse
%   seriale proprio e restituiscono etichette coerenti col calendario CF.

    dateNumbers = values;
    isTime = false;
    dateLabels = {};
    isNonGregorian = false;
    if isempty(units)
        return;
    end
    if nargin < 3 || isempty(calendar)
        calendar = 'standard';
    end
    units = asText(units);
    calendar = lower(strtrim(asText(calendar)));

    tokens = regexp(strtrim(units), ...
        '^\s*(seconds?|minutes?|hours?|days?)\s+since\s+(.+?)\s*$', ...
        'tokens', 'once', 'ignorecase');
    if isempty(tokens)
        return;
    end

    baseTokens = regexp(tokens{2}, ...
        '^(\d{4})-(\d{1,2})-(\d{1,2})(?:[T\s]+(\d{1,2})(?::(\d{1,2}))?(?::([\d.]+))?)?', ...
        'tokens', 'once');
    if isempty(baseTokens)
        return;
    end
    parts = zeros(1, 6);
    for index = 1:numel(baseTokens)
        if ~isempty(baseTokens{index})
            parts(index) = str2double(baseTokens{index});
        end
    end
    unitName = lower(tokens{1});
    if strncmp(unitName, 'second', 6)
        factor = 1 / 86400;
    elseif strncmp(unitName, 'minute', 6)
        factor = 1 / 1440;
    elseif strncmp(unitName, 'hour', 4)
        factor = 1 / 24;
    else
        factor = 1;
    end
    [monthLengths, isFixedCalendar] = fixedCalendarMonths(calendar);
    if isFixedCalendar
        [origin, validOrigin] = fixedCalendarSerial(parts, monthLengths);
        if ~validOrigin
            return;
        end
        dateNumbers = origin + double(values) .* factor;
        dateLabels = fixedCalendarLabels(dateNumbers, monthLengths);
        isNonGregorian = true;
    else
        try
            origin = datenum(parts(1), parts(2), parts(3), ...
                parts(4), parts(5), parts(6));
        catch
            return;
        end
        dateNumbers = origin + double(values) .* factor;
        dateLabels = standardLabels(dateNumbers);
    end
    isTime = true;
end

function [monthLengths, result] = fixedCalendarMonths(calendar)
    result = true;
    switch calendar
        case '360_day'
            monthLengths = repmat(30, 1, 12);
        case {'noleap', '365_day'}
            monthLengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        case {'all_leap', '366_day'}
            monthLengths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        otherwise
            monthLengths = [];
            result = false;
    end
end

function [serial, valid] = fixedCalendarSerial(parts, monthLengths)
    year = parts(1);
    month = parts(2);
    day = parts(3);
    valid = isfinite(year) && isfinite(month) && isfinite(day) && ...
        month >= 1 && month <= 12 && month == floor(month) && ...
        day >= 1 && day == floor(day);
    if ~valid || day > monthLengths(month)
        serial = NaN;
        valid = false;
        return;
    end
    seconds = parts(4) * 3600 + parts(5) * 60 + parts(6);
    if seconds < 0 || seconds >= 86400
        serial = NaN;
        valid = false;
        return;
    end
    serial = year * sum(monthLengths) + ...
        sum(monthLengths(1:month - 1)) + day - 1 + seconds / 86400;
end

function labels = fixedCalendarLabels(serialValues, monthLengths)
    labels = cell(size(serialValues));
    daysPerYear = sum(monthLengths);
    for valueIndex = 1:numel(serialValues)
        value = serialValues(valueIndex);
        if ~isfinite(value)
            labels{valueIndex} = 'NaN';
            continue;
        end
        wholeDay = floor(value);
        seconds = round((value - wholeDay) * 86400);
        if seconds >= 86400
            wholeDay = wholeDay + 1;
            seconds = seconds - 86400;
        end
        year = floor(wholeDay / daysPerYear);
        dayOfYear = wholeDay - year * daysPerYear;
        month = 1;
        while month < 12 && dayOfYear >= monthLengths(month)
            dayOfYear = dayOfYear - monthLengths(month);
            month = month + 1;
        end
        day = dayOfYear + 1;
        hour = floor(seconds / 3600);
        minute = floor((seconds - hour * 3600) / 60);
        second = seconds - hour * 3600 - minute * 60;
        labels{valueIndex} = sprintf( ...
            '%04d-%02d-%02d %02d:%02d:%02d', ...
            year, month, day, hour, minute, second);
    end
end

function labels = standardLabels(dateNumbers)
    labels = cell(size(dateNumbers));
    for valueIndex = 1:numel(dateNumbers)
        if isfinite(dateNumbers(valueIndex))
            labels{valueIndex} = datestr( ...
                dateNumbers(valueIndex), 'yyyy-mm-dd HH:MM:SS');
        else
            labels{valueIndex} = 'NaN';
        end
    end
end

function value = asText(value)
    if isnumeric(value)
        value = num2str(value);
    elseif iscell(value)
        value = value{1};
    end
    value = char(value);
end
