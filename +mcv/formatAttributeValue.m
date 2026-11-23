function text = formatAttributeValue(value)
%FORMATATTRIBUTEVALUE Converte un valore attributo in testo leggibile.

    if ischar(value)
        text = value;
    elseif isnumeric(value) || islogical(value)
        if isempty(value)
            text = '[]';
        elseif isscalar(value)
            text = num2str(value, 12);
        else
            flat = value(:)';
            shown = flat(1:min(numel(flat), 20));
            formatted = sprintf('%.8g ', shown);
            text = ['[', strtrim(formatted), ']'];
            if numel(flat) > numel(shown)
                text = [text, sprintf(' ... (%d valori)', numel(flat))];
            end
        end
    elseif iscell(value)
        parts = cellfun(@mcv.formatAttributeValue, value, 'UniformOutput', false);
        text = strjoin(parts, ', ');
    else
        try
            text = char(value);
        catch
            text = sprintf('<%s>', class(value));
        end
    end
    text = strrep(text, sprintf('\n'), ' ');
end
