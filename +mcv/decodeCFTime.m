function [dateNumbers, isTime] = decodeCFTime(values, units, calendar)
%DECODECFTIME Converte un asse "unit since ISO-date" in datenum.
%   Sono supportati i calendari gregoriani. Per 360_day, 365_day e noleap
%   vengono mantenuti i valori numerici per non mostrare date inesatte.

    dateNumbers = values;
    isTime = false;
    if isempty(units)
        return;
    end
    if nargin < 3 || isempty(calendar)
        calendar = 'standard';
    end
    unsupportedCalendars = {'360_day', '365_day', '366_day', 'noleap', 'all_leap'};
    if any(strcmpi(strtrim(calendar), unsupportedCalendars))
        return;
    end

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
    try
        origin = datenum(parts(1), parts(2), parts(3), ...
            parts(4), parts(5), parts(6));
    catch
        return;
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
    dateNumbers = origin + double(values) .* factor;
    isTime = true;
end
