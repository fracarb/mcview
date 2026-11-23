function environment = setupEnvironment()
%SETUPENVIRONMENT Prepara le dipendenze specifiche del runtime.
%   In Octave carica il pacchetto netcdf. In MATLAB non esegue pkg load,
%   perché le funzioni NetCDF fanno parte del prodotto MATLAB.

    environment = struct();
    environment.isOctave = mcv.isOctave();

    if environment.isOctave
        environment.name = 'GNU Octave';
        environment.version = version();
        try
            pkg('load', 'netcdf');
        catch exception
            error('mcview:MissingNetcdfPackage', [ ...
                'Impossibile caricare il pacchetto Octave netcdf.\n' ...
                'Installalo con: pkg install -forge netcdf\n' ...
                'Poi riprova con: pkg load netcdf\n\n' ...
                'Dettaglio: %s'], exception.message);
        end
    else
        environment.name = 'MATLAB';
        environment.version = version();
    end

    requiredFunctions = {'ncinfo', 'ncread'};
    for index = 1:numel(requiredFunctions)
        functionName = requiredFunctions{index};
        if exist(functionName, 'file') == 0 && exist(functionName, 'builtin') == 0
            error('mcview:MissingNetcdfSupport', ...
                'La funzione NetCDF richiesta "%s" non e disponibile.', ...
                functionName);
        end
    end
end
