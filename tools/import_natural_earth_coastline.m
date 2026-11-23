function import_natural_earth_coastline(outputFile, varargin)
%IMPORT_NATURAL_EARTH_COASTLINE Converte shapefile lineari in un MAT portabile.
%   import_natural_earth_coastline(OUTPUT, MAIN_SHP, MINOR_ISLANDS_SHP)
%   legge direttamente il formato ESRI PolyLine senza richiedere Mapping
%   Toolbox o il pacchetto mapping di Octave.

    if nargin < 2
        error('mcview:MissingCoastlineSource', ...
            'Specificare almeno uno shapefile Natural Earth.');
    end

    longitudeParts = cell(1, numel(varargin));
    latitudeParts = cell(1, numel(varargin));
    for sourceIndex = 1:numel(varargin)
        [longitudeParts{sourceIndex}, latitudeParts{sourceIndex}] = ...
            readPolylineShapefile(varargin{sourceIndex});
    end
    longitude = single(vertcat(longitudeParts{:}));
    latitude = single(vertcat(latitudeParts{:}));
    sourceNames = cell(size(varargin));
    sourceVersions = cell(size(varargin));
    for sourceIndex = 1:numel(varargin)
        [folder, name, extension] = fileparts(varargin{sourceIndex});
        sourceNames{sourceIndex} = [name, extension];
        versionFile = fullfile(folder, [name, '.VERSION.txt']);
        if exist(versionFile, 'file') == 2
            sourceVersions{sourceIndex} = strtrim(fileread(versionFile));
        else
            sourceVersions{sourceIndex} = 'unknown';
        end
    end
    metadata = struct( ...
        'name', 'Natural Earth 1:10m Coastline', ...
        'source', 'https://www.naturalearthdata.com/', ...
        'license', 'Public domain', ...
        'sourceFiles', {sourceNames}, ...
        'sourceVersions', {sourceVersions});

    outputFolder = fileparts(outputFile);
    if ~isempty(outputFolder) && exist(outputFolder, 'dir') ~= 7
        mkdir(outputFolder);
    end
    if exist('OCTAVE_VERSION', 'builtin') ~= 0
        save('-mat7-binary', outputFile, 'longitude', 'latitude', 'metadata');
    else
        save(outputFile, 'longitude', 'latitude', 'metadata', '-v7');
    end
    fprintf('Salvati %d vertici Natural Earth in %s\n', ...
        numel(longitude), outputFile);
end

function [longitude, latitude] = readPolylineShapefile(filename)
    fileId = fopen(filename, 'rb');
    if fileId < 0
        error('mcview:CoastlineOpenFailed', ...
            'Impossibile aprire lo shapefile: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>

    fileCode = fread(fileId, 1, 'int32', 0, 'ieee-be');
    if isempty(fileCode) || fileCode ~= 9994
        error('mcview:InvalidShapefile', ...
            'Header shapefile non valido: %s', filename);
    end
    fseek(fileId, 100, 'bof');
    longitudeParts = {};
    latitudeParts = {};
    while true
        recordNumber = fread(fileId, 1, 'int32', 0, 'ieee-be'); %#ok<NASGU>
        if isempty(recordNumber), break; end
        contentWords = fread(fileId, 1, 'int32', 0, 'ieee-be');
        if isempty(contentWords), break; end
        recordEnd = ftell(fileId) + double(contentWords) * 2;
        shapeType = fread(fileId, 1, 'int32', 0, 'ieee-le');
        if isempty(shapeType), break; end
        if shapeType == 0
            fseek(fileId, recordEnd, 'bof');
            continue;
        end
        if shapeType ~= 3 && shapeType ~= 5
            error('mcview:UnsupportedShapefile', ...
                'Tipo geometrico %d non supportato in %s.', shapeType, filename);
        end

        fread(fileId, 4, 'double', 0, 'ieee-le'); % bounding box
        partCount = fread(fileId, 1, 'int32', 0, 'ieee-le');
        pointCount = fread(fileId, 1, 'int32', 0, 'ieee-le');
        partStarts = double(fread(fileId, double(partCount), ...
            'int32', 0, 'ieee-le')) + 1;
        points = fread(fileId, [2, double(pointCount)], ...
            'double', 0, 'ieee-le')';
        partStops = [partStarts(2:end) - 1; double(pointCount)];
        for partIndex = 1:numel(partStarts)
            selected = partStarts(partIndex):partStops(partIndex);
            longitudeParts{end + 1, 1} = [points(selected, 1); NaN]; %#ok<AGROW>
            latitudeParts{end + 1, 1} = [points(selected, 2); NaN]; %#ok<AGROW>
        end
        fseek(fileId, recordEnd, 'bof');
    end
    longitude = vertcat(longitudeParts{:});
    latitude = vertcat(latitudeParts{:});
end
