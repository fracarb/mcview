function path = variablePath(variableInfo)
%VARIABLEPATH Restituisce il percorso NetCDF completo di una variabile.

    if isfield(variableInfo, 'Path') && ~isempty(variableInfo.Path)
        path = variableInfo.Path;
    else
        path = variableInfo.Name;
    end
end
