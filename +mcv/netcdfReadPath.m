function path = netcdfReadPath(path)
%NETCDFREADPATH Adatta un percorso variabile alle API NetCDF MATLAB/Octave.
%   Octave interpreta "/variabile" come accesso a un gruppo e lo rifiuta
%   per i file NetCDF classic. I percorsi con gruppi, per esempio
%   "/ocean/temperature", devono invece conservare lo slash iniziale.

    path = char(path);
    if numel(path) >= 2 && path(1) == '/' && isempty(strfind(path(2:end), '/')) %#ok<STREMP>
        path = path(2:end);
    end
end
