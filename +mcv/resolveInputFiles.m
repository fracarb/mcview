function filenames = resolveInputFiles(inputSpec)
%RESOLVEINPUTFILES Espande file e pattern wildcard passati a MCVIEW.
%   FILES = RESOLVEINPUTFILES(SPEC) restituisce una cella di nomi di file.
%   SPEC puo essere un percorso, un pattern con * o ?, una cella di
%   percorsi/pattern oppure un array di stringhe MATLAB.

    hasIsString = exist('isstring', 'builtin') ~= 0 || ...
        exist('isstring', 'file') ~= 0;

    if iscell(inputSpec)
        filenames = {};
        for inputIndex = 1:numel(inputSpec)
            matched = mcv.resolveInputFiles(inputSpec{inputIndex});
            filenames = appendUnique(filenames, matched);
        end
        if isempty(filenames)
            error('mcview:InvalidFilename', ...
                'Selezionare almeno un file NetCDF.');
        end
        return;
    end

    if hasIsString && isstring(inputSpec)
        if ~isscalar(inputSpec)
            filenames = mcv.resolveInputFiles(cellstr(inputSpec));
            return;
        end
        inputSpec = char(inputSpec);
    end

    if ~ischar(inputSpec) || size(inputSpec, 1) ~= 1
        error('mcview:InvalidFilename', ...
            'Il file deve essere indicato con testo o con una cella di testi.');
    end
    if isempty(inputSpec)
        filenames = {};
        return;
    end

    if ~hasWildcard(inputSpec)
        filenames = {normalizeExistingFile(inputSpec)};
        return;
    end

    entries = dir(inputSpec);
    if ~isempty(entries)
        entries = entries(~[entries.isdir]);
    end
    if isempty(entries)
        error('mcview:NoFilesMatched', ...
            'Nessun file corrisponde al pattern: %s', inputSpec);
    end

    filenames = cell(1, numel(entries));
    patternFolder = fileparts(inputSpec);
    for entryIndex = 1:numel(entries)
        if isfield(entries, 'folder') && ~isempty(entries(entryIndex).folder)
            filename = fullfile( ...
                entries(entryIndex).folder, entries(entryIndex).name);
        elseif isempty(patternFolder)
            filename = entries(entryIndex).name;
        else
            filename = fullfile( ...
                patternFolder, entries(entryIndex).name);
        end
        filenames{entryIndex} = normalizeExistingFile(filename);
    end
    filenames = sort(filenames);
    filenames = appendUnique({}, filenames);
end

function filename = normalizeExistingFile(filename)
    if exist(filename, 'file') ~= 2
        return;
    end
    try
        [success, attributes] = fileattrib(filename);
        if success && isfield(attributes, 'Name')
            filename = attributes.Name;
        end
    catch
        % Il percorso originale resta valido anche se non e normalizzabile.
    end
end

function result = hasWildcard(value)
    result = ~isempty(strfind(value, '*')) || ... %#ok<STREMP>
        ~isempty(strfind(value, '?')); %#ok<STREMP>
end

function destination = appendUnique(destination, source)
    for sourceIndex = 1:numel(source)
        if ~any(strcmp(destination, source{sourceIndex}))
            destination{end + 1} = source{sourceIndex}; %#ok<AGROW>
        end
    end
end
