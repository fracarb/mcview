function indices = parseIndexSelection(expression, maximum)
%PARSEINDEXSELECTION Analizza liste e intervalli di indici senza usare EVAL.
%   Supporta "all", ":", "1:10", "1:2:9" e liste come "[1 5 20]".

    if ~(isnumeric(maximum) && isscalar(maximum) && isfinite(maximum) && ...
            maximum >= 1 && maximum == floor(maximum))
        error('mcview:InvalidIndexLimit', ...
            'La lunghezza della dimensione deve essere un intero positivo.');
    end
    if iscell(expression), expression = expression{1}; end
    if exist('isstring', 'builtin') ~= 0 && isstring(expression)
        expression = char(expression);
    end
    if ~ischar(expression)
        error('mcview:InvalidIndexSelection', ...
            'Gli indici devono essere specificati come testo.');
    end
    expression = strtrim(expression);
    if strcmpi(expression, 'all') || strcmp(expression, ':')
        indices = 1:maximum;
        return;
    end
    if numel(expression) >= 2 && expression(1) == '[' && expression(end) == ']'
        expression = strtrim(expression(2:end - 1));
    end
    if isempty(expression)
        error('mcview:InvalidIndexSelection', ...
            'Specificare almeno un indice.');
    end

    tokens = regexp(expression, '[,;\s]+', 'split');
    indices = [];
    for tokenIndex = 1:numel(tokens)
        token = strtrim(tokens{tokenIndex});
        if isempty(token), continue; end
        parts = regexp(token, ':', 'split');
        if numel(parts) == 1
            values = parseInteger(parts{1});
        elseif numel(parts) == 2
            first = parseInteger(parts{1});
            last = parseInteger(parts{2});
            if first <= last
                values = first:last;
            else
                values = first:-1:last;
            end
        elseif numel(parts) == 3
            first = parseInteger(parts{1});
            step = parseInteger(parts{2});
            last = parseInteger(parts{3});
            if step == 0
                error('mcview:InvalidIndexSelection', ...
                    'Il passo di un intervallo non puo essere zero.');
            end
            values = first:step:last;
            if isempty(values)
                error('mcview:InvalidIndexSelection', ...
                    'L''intervallo %s non produce indici.', token);
            end
        else
            error('mcview:InvalidIndexSelection', ...
                'Espressione di indici non valida: %s', token);
        end
        indices = [indices, values]; %#ok<AGROW>
    end
    if isempty(indices) || any(indices < 1 | indices > maximum)
        error('mcview:InvalidIndexSelection', ...
            'Gli indici devono essere compresi tra 1 e %d.', maximum);
    end
    indices = uniqueStable(indices);
end

function value = parseInteger(text)
    value = str2double(strtrim(text));
    if ~(isscalar(value) && isfinite(value) && value == floor(value))
        error('mcview:InvalidIndexSelection', ...
            'Indice non valido: %s', text);
    end
end

function values = uniqueStable(values)
    result = [];
    for valueIndex = 1:numel(values)
        if ~any(result == values(valueIndex))
            result(end + 1) = values(valueIndex); %#ok<AGROW>
        end
    end
    values = result;
end
