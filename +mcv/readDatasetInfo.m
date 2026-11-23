function info = readDatasetInfo(filename)
%READDATASETINFO Legge e valida i metadati di un dataset NetCDF.

    if iscell(filename)
        filenames = filename;
    elseif exist('isstring', 'builtin') ~= 0 && isstring(filename) && ~isscalar(filename)
        filenames = cellstr(filename);
    else
        filenames = {char(filename)};
    end
    if isempty(filenames)
        error('mcview:InvalidFilename', 'Selezionare almeno un file NetCDF.');
    end

    infos = cell(1, numel(filenames));
    for fileIndex = 1:numel(filenames)
        infos{fileIndex} = readSingleDatasetInfo(filenames{fileIndex});
    end
    if numel(infos) > 1
        [filenames, infos] = mcv.sortDatasetCollection(filenames, infos);
    end
    if numel(infos) == 1
        info = infos{1};
        info.FileNames = filenames;
        info.SourceInfos = infos;
    else
        info = mcv.mergeDatasetInfos(filenames, infos);
    end
end

function info = readSingleDatasetInfo(filename)
    hasIsString = exist('isstring', 'builtin') ~= 0 || exist('isstring', 'file') ~= 0;
    if ~(ischar(filename) || (hasIsString && isstring(filename)))
        error('mcview:InvalidFilename', 'Il nome del file deve essere testo.');
    end
    filename = char(filename);
    if exist(filename, 'file') ~= 2
        error('mcview:FileNotFound', 'File non trovato: %s', filename);
    end

    try
        info = ncinfo(filename);
    catch exception
        error('mcview:InvalidDataset', ...
            'Impossibile leggere "%s": %s', filename, exception.message);
    end

    if ~isfield(info, 'Variables')
        info.Variables = struct([]);
    end
    info.RootVariables = info.Variables;
    info.Variables = mcv.flattenDatasetInfo(info);
end
