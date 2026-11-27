function name = workspaceVariableName(value)
%WORKSPACEVARIABLENAME Crea un identificatore MATLAB/Octave portabile.

    if iscell(value), value = value{1}; end
    if exist('isstring', 'builtin') ~= 0 && isstring(value)
        value = char(value);
    end
    if ~ischar(value), value = 'netcdf_variable'; end
    value = strtrim(value);
    value = regexprep(value, '^/+', '');
    name = regexprep(value, '[^A-Za-z0-9_]', '_');
    name = regexprep(name, '_+', '_');
    if isempty(name)
        name = 'netcdf_variable';
    end
    if isempty(regexp(name(1), '[A-Za-z]', 'once'))
        name = ['nc_', name];
    end
    maximumLength = namelengthmax();
    if numel(name) > maximumLength
        name = name(1:maximumLength);
    end
    try
        if iskeyword(name)
            name = ['nc_', name];
            if numel(name) > maximumLength
                name = name(1:maximumLength);
            end
        end
    catch
    end
end
