function setColorbarLabel(colorbarHandle, variableName, units)
%SETCOLORBARLABEL Etichetta una colorbar in MATLAB e GNU Octave.

    label = mcv.variableUnitsLabel(variableName, units);
    try
        ylabel(colorbarHandle, label, 'Interpreter', 'none');
        return;
    catch
    end
    try
        labelHandle = get(colorbarHandle, 'Label');
        set(labelHandle, 'String', label, 'Interpreter', 'none');
    catch
        % Una colorbar priva di Label non deve impedire il rendering.
    end
end
