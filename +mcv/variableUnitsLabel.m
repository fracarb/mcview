function label = variableUnitsLabel(variableName, units)
%VARIABLEUNITSLABEL Compone nome variabile e unita di misura.

    if isnumeric(units), units = num2str(units); end
    if iscell(units), units = units{1}; end
    units = char(units);
    if isempty(units)
        label = char(variableName);
    else
        label = sprintf('%s [%s]', char(variableName), units);
    end
end
