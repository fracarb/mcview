function value = getAttribute(variableInfo, attributeName, defaultValue)
%GETATTRIBUTE Legge un attributo ncinfo senza dipendere dal runtime.

    value = defaultValue;
    if ~isfield(variableInfo, 'Attributes') || isempty(variableInfo.Attributes)
        return;
    end

    names = {variableInfo.Attributes.Name};
    match = find(strcmp(names, attributeName), 1);
    if ~isempty(match)
        value = variableInfo.Attributes(match).Value;
    end
end
