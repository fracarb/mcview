function run_tests()
%RUN_TESTS Test portabili dell'infrastruttura principale di MCVIEW.

    testsFolder = fileparts(mfilename('fullpath'));
    projectFolder = fileparts(testsFolder);
    addpath(projectFolder);

    environment = mcv.setupEnvironment();
    assert(isfield(environment, 'isOctave'));
    assert(environment.isOctave == mcv.isOctave());

    testInputFileResolution();
    testWorkspaceExportHelpers();
    testDimensionSelection();
    testViewerLayout();
    testCFAxisSelection();
    testSlicePreparation();
    testCFTime();
    testRangeAndGeography();
    testNetcdfRead();
    testClassicRootVariables();
    testNetcdfGroups();
    testCurvilinearCoordinates();
    testMultiFileConcatenation();
    testMultiFile2DStack();
    testTemporalComparison();

    fprintf('MCVIEW: tutti i test sono passati su %s %s.\n', ...
        environment.name, environment.version);
end

function testWorkspaceExportHelpers()
    assert(isequal(mcv.parseIndexSelection('1:3', 8), 1:3));
    assert(isequal(mcv.parseIndexSelection('[1 5 3 5]', 8), [1, 5, 3]));
    assert(isequal(mcv.parseIndexSelection('1:2:7, 8', 8), [1, 3, 5, 7, 8]));
    assert(isequal(mcv.parseIndexSelection('all', 4), 1:4));
    assert(isequal(mcv.parseIndexSelection('4:2', 4), 4:-1:2));

    invalidSelectionRaised = false;
    try
        mcv.parseIndexSelection('1, 9', 8);
    catch exception
        invalidSelectionRaised = strcmp( ...
            exception.identifier, 'mcview:InvalidIndexSelection');
    end
    assert(invalidSelectionRaised);
    assert(strcmp(mcv.workspaceVariableName('/ocean/air-temp'), ...
        'ocean_air_temp'));
    assert(strcmp(mcv.workspaceVariableName('1temperature'), ...
        'nc_1temperature'));
    assert(strcmp(mcv.workspaceVariableName('for'), 'nc_for'));
end

function testInputFileResolution()
    temporaryFolder = tempname();
    mkdir(temporaryFolder);
    cleanup = onCleanup(@() removeFolderIfPresent(temporaryFolder)); %#ok<NASGU>

    firstFile = fullfile(temporaryFolder, 'run_001.nc');
    secondFile = fullfile(temporaryFolder, 'run_002.nc');
    otherFile = fullfile(temporaryFolder, 'notes.txt');
    createEmptyFile(firstFile);
    createEmptyFile(secondFile);
    createEmptyFile(otherFile);

    resolved = mcv.resolveInputFiles(firstFile);
    assert(numel(resolved) == 1);
    canonicalFirst = resolved{1};
    canonicalSecond = mcv.resolveInputFiles(secondFile);
    canonicalSecond = canonicalSecond{1};

    resolved = mcv.resolveInputFiles(fullfile(temporaryFolder, 'run_*.nc'));
    assert(isequal(resolved, {canonicalFirst, canonicalSecond}));

    resolved = mcv.resolveInputFiles( ...
        {secondFile, fullfile(temporaryFolder, 'run_*.nc')});
    assert(isequal(resolved, {canonicalSecond, canonicalFirst}));

    noMatchRaised = false;
    try
        mcv.resolveInputFiles(fullfile(temporaryFolder, 'missing_*.nc'));
    catch exception
        noMatchRaised = strcmp(exception.identifier, 'mcview:NoFilesMatched');
    end
    assert(noMatchRaised);
end

function testViewerLayout()
    layout = mcv.viewerLayout();
    fields = fieldnames(layout);
    for fieldIndex = 1:numel(fields)
        position = layout.(fields{fieldIndex});
        assert(numel(position) == 4);
        assert(all(position >= 0));
        assert(position(1) + position(3) <= 1);
        assert(position(2) + position(4) <= 1);
    end
    assert(layout.axes(1) == layout.detailsText(1));
    assert(layout.axes(3) == layout.detailsText(3));
    assert(layout.variableList(1) == layout.planePopup(1));
    assert(layout.variableList(3) == layout.planePopup(3));
    assert(layout.exportButton(1) + layout.exportButton(3) == ...
        layout.axes(1) + layout.axes(3));
end

function testCFAxisSelection()
    longitude = struct('Name', 'lon', 'Size', 4, ...
        'Dimensions', struct('Name', 'lon', 'Length', 4), ...
        'Attributes', struct('Name', {'standard_name', 'units'}, ...
            'Value', {'longitude', 'degrees_east'}));
    latitude = struct('Name', 'lat', 'Size', 3, ...
        'Dimensions', struct('Name', 'lat', 'Length', 3), ...
        'Attributes', struct('Name', {'standard_name', 'units'}, ...
            'Value', {'latitude', 'degrees_north'}));
    fieldDimensions = [struct('Name', 'lat', 'Length', 3), ...
        struct('Name', 'lon', 'Length', 4)];
    field = struct('Name', 'field', 'Size', [3, 4], ...
        'Dimensions', fieldDimensions, 'Attributes', struct([]));
    datasetInfo = struct('Variables', [longitude, latitude, field]);

    [xDimension, yDimension] = ...
        mcv.chooseVariablePlotDimensions(datasetInfo, field);
    assert(xDimension == 2);
    assert(yDimension == 1);
end

function testClassicRootVariables()
    filename = [tempname(), '.nc'];
    cleanup = onCleanup(@() deleteIfPresent(filename)); %#ok<NASGU>
    if mcv.isOctave()
        ncid = netcdf_create(filename, 'CLOBBER');
        xId = netcdf_defDim(ncid, 'x', 3);
        yId = netcdf_defDim(ncid, 'y', 2);
        variableId = netcdf_defVar(ncid, 'mask', 'NC_DOUBLE', [xId, yId]);
        netcdf_endDef(ncid);
        netcdf_putVar(ncid, variableId, reshape(1:6, [3, 2]));
        netcdf_close(ncid);
    else
        ncid = netcdf.create(filename, 'CLOBBER');
        xId = netcdf.defDim(ncid, 'x', 3);
        yId = netcdf.defDim(ncid, 'y', 2);
        variableId = netcdf.defVar(ncid, 'mask', 'NC_DOUBLE', [xId, yId]);
        netcdf.endDef(ncid);
        netcdf.putVar(ncid, variableId, reshape(1:6, [3, 2]));
        netcdf.close(ncid);
    end

    info = mcv.readDatasetInfo(filename);
    variableInfo = info.Variables(strcmp({info.Variables.Name}, 'mask'));
    data = mcv.readVariableData(filename, variableInfo, [], []);
    assert(isequal(sort(double(data(:))), (1:6)'));
    assert(strcmp(mcv.netcdfReadPath('/mask'), 'mask'));
    assert(strcmp(mcv.netcdfReadPath('/group/mask'), '/group/mask'));
end

function testCurvilinearCoordinates()
    filename = [tempname(), '.nc'];
    cleanup = onCleanup(@() deleteIfPresent(filename)); %#ok<NASGU>
    longitude = [350, 351; 0, 1; 10, 11];
    latitude = [40, 41; 40.5, 41.5; 41, 42];
    field = reshape(1:6, [3, 2]);
    nccreate(filename, 'lon', 'Dimensions', {'x', 3, 'y', 2});
    ncwrite(filename, 'lon', longitude);
    ncwriteatt(filename, 'lon', 'standard_name', 'longitude');
    ncwriteatt(filename, 'lon', 'units', 'degrees_east');
    nccreate(filename, 'lat', 'Dimensions', {'x', 3, 'y', 2});
    ncwrite(filename, 'lat', latitude);
    ncwriteatt(filename, 'lat', 'standard_name', 'latitude');
    ncwriteatt(filename, 'lat', 'units', 'degrees_north');
    nccreate(filename, 'field', 'Dimensions', {'x', 3, 'y', 2});
    ncwrite(filename, 'field', field);
    ncwriteatt(filename, 'field', 'coordinates', 'lon lat');

    info = mcv.readDatasetInfo(filename);
    paths = variablePaths(info.Variables);
    variableInfo = info.Variables(strcmp(paths, '/field'));
    [data, xGrid, yGrid, ~, axesInfo] = mcv.readVariableSlice( ...
        filename, info, variableInfo, 1, 2, [1, 1]);
    assert(isequal(data, field));
    assert(isequal(xGrid, longitude));
    assert(isequal(yGrid, latitude));
    assert(mcv.isGeographicAxes(axesInfo));
    options = struct('wrapLongitude', true, ...
        'projection', 'equirectangular', 'showCoast', false);
    [wrappedData, wrappedGrid] = mcv.prepareGeographicSlice( ...
        data, xGrid, yGrid, axesInfo, options);
    assert(isequal(wrappedData, field));
    assert(isequal(wrappedGrid, [-10, -9; 0, 1; 10, 11]));
end

function testRangeAndGeography()
    assert(abs(mcv.percentile([1, 2, 3, 4], 25) - 1.75) < 1e-12);
    assert(abs(mcv.percentile([1, 2, 3, 4], 98) - 3.94) < 1e-12);
    assert(strcmp(mcv.variableUnitsLabel('temperature', 'K'), 'temperature [K]'));
    assert(strcmp(mcv.variableUnitsLabel('mask', ''), 'mask'));
    assert(isequal(mcv.coastlineColor('Nero'), [0, 0, 0]));
    assert(isequal(mcv.coastlineColor('Bianco'), [1, 1, 1]));
    assert(isequal(mcv.coastlineColor('Rosso'), [0.90, 0.10, 0.10]));
    map = mcv.divergingMap(5);
    assert(isequal(size(map), [5, 3]));
    assert(all(abs(map(3, :) - 1) < 1e-12));

    longitude = [0, 90, 180, 270];
    latitude = [-45, 45];
    data = reshape(1:8, [4, 2]);
    axesInfo.x = syntheticAxis('lon', 'Longitude', 'degrees_east', ...
        'longitude', 'X', longitude);
    axesInfo.y = syntheticAxis('lat', 'Latitude', 'degrees_north', ...
        'latitude', 'Y', latitude);
    options = struct('wrapLongitude', true, ...
        'projection', 'equirectangular', 'showCoast', true);
    [wrappedData, wrappedLongitude, projectedLatitude, ~, geoInfo] = ...
        mcv.prepareGeographicSlice(data, longitude, latitude, axesInfo, options);
    assert(geoInfo.isGeographic);
    assert(isequal(wrappedLongitude, [-180, -90, 0, 90]));
    assert(isequal(wrappedData, data([3, 4, 1, 2], :)));
    assert(isequal(projectedLatitude, latitude));

    swappedAxes.x = axesInfo.y;
    swappedAxes.y = axesInfo.x;
    swappedData = data';
    [swappedData, swappedLatitude, swappedLongitude, ~, swappedGeo] = ...
        mcv.prepareGeographicSlice(swappedData, latitude, longitude, ...
        swappedAxes, options);
    assert(swappedGeo.isGeographic && swappedGeo.axesSwapped);
    assert(isequal(swappedLatitude, latitude));
    assert(isequal(swappedLongitude, [-180, -90, 0, 90]));
    assert(isequal(swappedData, data([3, 4, 1, 2], :)'));
    assert(isequal(swappedGeo.xOrder, 1:2));
    assert(isequal(swappedGeo.yOrder, [3, 4, 1, 2]));

    [coastX, coastY] = mcv.prepareCoastline( ...
        [10; 20], [30; 40], swappedGeo, swappedLongitude, true);
    assert(isequal(coastX, [30; 40]));
    assert(isequal(coastY, [10; 20]));

    options.projection = 'mercator';
    [~, ~, mercatorLatitude, ~, geoInfo] = ...
        mcv.prepareGeographicSlice(data, longitude, latitude, axesInfo, options);
    assert(strcmp(geoInfo.projection, 'mercator'));
    assert(abs(mercatorLatitude(1) + mercatorLatitude(2)) < 1e-10);
    [~, swappedMercatorLatitude, ~, ~, swappedMercatorGeo] = ...
        mcv.prepareGeographicSlice(data', latitude, longitude, ...
        swappedAxes, options);
    assert(swappedMercatorGeo.axesSwapped);
    assert(abs(swappedMercatorLatitude(1) + swappedMercatorLatitude(2)) < 1e-10);
    [coastLongitude, coastLatitude] = mcv.coastlineData('mercator');
    assert(numel(coastLongitude) == numel(coastLatitude));
    assert(numel(coastLongitude) > 400000);
    assert(any(isnan(coastLongitude)));
    assert(all(isfinite(coastLatitude(~isnan(coastLatitude)))));
    [wrappedLine, wrappedLatitude] = mcv.wrapLineLongitude( ...
        [-2; 2; NaN; 170; -170], [1; 1; NaN; 2; 2], '360');
    assert(any(isnan(wrappedLine(1:3))));
    finiteJumps = abs(diff(wrappedLine));
    finiteJumps = finiteJumps(isfinite(finiteJumps));
    assert(all(finiteJumps <= 180));
    assert(numel(wrappedLine) == numel(wrappedLatitude));

    largeData = reshape(1:10000, [100, 100]);
    [reduced, reducedX, reducedY, sampling] = mcv.downsampleSlice( ...
        largeData, 1:100, 1:100, 1000);
    assert(sampling.wasDownsampled);
    assert(numel(reduced) <= 1200);
    assert(reducedX(1) == 1 && reducedX(end) == 100);
    assert(reducedY(1) == 1 && reducedY(end) == 100);
    assert(reduced(1, 1) == largeData(1, 1));
    assert(reduced(end, end) == largeData(end, end));
    assert(mcv.estimateBytes(reduced) > 0);
end

function info = syntheticAxis(name, longName, units, standardName, axisName, values)
    info = struct('name', name, 'longName', longName, 'units', units, ...
        'standardName', standardName, 'axis', axisName, ...
        'calendar', 'standard', 'values', values, 'plotValues', values, ...
        'isCoordinate', true, 'isTime', false);
end

function testNetcdfGroups()
    filename = [tempname(), '.nc'];
    cleanup = onCleanup(@() deleteIfPresent(filename)); %#ok<NASGU>
    createGroupedDataset(filename);

    info = mcv.readDatasetInfo(filename);
    paths = variablePaths(info.Variables);
    assert(any(strcmp(paths, '/ocean/x')));
    assert(any(strcmp(paths, '/ocean/nested/salt')));
    temperatureIndex = find(strcmp(paths, '/ocean/temperature'), 1);
    assert(~isempty(temperatureIndex));
    variableInfo = info.Variables(temperatureIndex);
    [data, coordinate, ~, selection, axesInfo] = mcv.readVariableSlice( ...
        filename, info, variableInfo, 1, 0, 1);
    assert(isequal(data(:), [4; 5; 6]));
    assert(isequal(coordinate, [10, 20, 30]));
    assert(strcmp(axesInfo.x.units, 'km'));
    assert(isequal(selection.count, 3));

    sampleInfo = info.Variables(strcmp(paths, '/ocean/sample'));
    [sampleData, auxiliaryCoordinate, ~, ~, sampleAxes] = ...
        mcv.readVariableSlice(filename, info, sampleInfo, 1, 0, 1);
    assert(isequal(sampleData(:), [7; 8; 9]));
    assert(isequal(auxiliaryCoordinate, [42, 43, 44]));
    assert(strcmp(sampleAxes.x.units, 'degrees_east'));

    [treeLabels, treeVariables, treeGroups, expandedGroups] = ...
        mcv.variableTreeRows(info);
    oceanRow = find(strcmp(treeGroups, '/ocean'), 1);
    nestedRow = find(strcmp(treeGroups, '/ocean/nested'), 1);
    saltIndex = find(strcmp(paths, '/ocean/nested/salt'), 1);
    assert(~isempty(oceanRow) && ~isempty(nestedRow));
    assert(~isempty(strfind(treeLabels{oceanRow}, '[-] ocean'))); %#ok<STREMP>
    assert(~isempty(strfind(treeLabels{nestedRow}, '[-] nested'))); %#ok<STREMP>
    assert(any(treeVariables == saltIndex));

    collapsedGroups = expandedGroups( ...
        ~strcmp(expandedGroups, '/ocean/nested'));
    [collapsedLabels, collapsedVariables, collapsedPaths] = ...
        mcv.variableTreeRows(info, collapsedGroups);
    nestedRow = find(strcmp(collapsedPaths, '/ocean/nested'), 1);
    assert(~isempty(strfind(collapsedLabels{nestedRow}, '[+] nested'))); %#ok<STREMP>
    assert(~any(collapsedVariables == saltIndex));
end

function testMultiFileConcatenation()
    firstFile = [tempname(), '.nc'];
    secondFile = [tempname(), '.nc'];
    cleanupFirst = onCleanup(@() deleteIfPresent(firstFile)); %#ok<NASGU>
    cleanupSecond = onCleanup(@() deleteIfPresent(secondFile)); %#ok<NASGU>
    createTimeDataset(firstFile, [0, 1], reshape(1:4, [2, 2]));
    createTimeDataset(secondFile, [2, 3], reshape(5:8, [2, 2]));

    % L'ordine inverso verifica il riordinamento dalla coordinata temporale.
    info = mcv.readDatasetInfo({secondFile, firstFile});
    paths = variablePaths(info.Variables);
    variableInfo = info.Variables(strcmp(paths, '/temperature'));
    assert(isequal(double(variableInfo.Size(:))', [2, 4]));
    assert(variableInfo.ConcatDimension == 2);

    [data, xCoordinate, timeCoordinate, selection, axesInfo] = ...
        mcv.readVariableSlice({secondFile, firstFile}, info, ...
        variableInfo, 1, 2, [1, 1]);
    assert(isequal(data, reshape(1:8, [2, 4])));
    assert(isequal(xCoordinate, [10, 20]));
    assert(isequal(timeCoordinate, ...
        datenum(2000, 1, 1) + [0, 1, 2, 3]));
    assert(axesInfo.y.isTime);
    assert(isequal(selection.count, [2, 4]));

    [lastFrame, ~, ~, lastSelection] = mcv.readVariableSlice( ...
        {secondFile, firstFile}, info, variableInfo, 1, 0, [1, 4]);
    assert(isequal(lastFrame(:), [7; 8]));
    assert(isequal(lastSelection.start, [1, 4]));

    [fastLimits, fastValues] = mcv.computeVariableRange( ...
        {secondFile, firstFile}, variableInfo, 'fast');
    [allLimits, allValues] = mcv.computeVariableRange( ...
        {secondFile, firstFile}, variableInfo, 'all');
    assert(isequal(fastLimits, [1, 8]));
    assert(isequal(allLimits, [1, 8]));
    assert(numel(fastValues) < numel(allValues));

    cancelled = false;
    try
        mcv.computeVariableRange({secondFile, firstFile}, variableInfo, ...
            'all', @(position, ~) position < 2);
    catch exception
        cancelled = strcmp(exception.identifier, 'mcview:Cancelled');
    end
    assert(cancelled);
end

function testMultiFile2DStack()
    files = cell(1, 3);
    cleanups = cell(1, 3);
    for fileIndex = 1:3
        files{fileIndex} = [tempname(), '.nc'];
        cleanups{fileIndex} = onCleanup( ...
            @() deleteIfPresent(files{fileIndex})); %#ok<NASGU>
        values = reshape(1:6, [2, 3]) + (fileIndex - 1) * 10;
        create2DFieldDataset(files{fileIndex}, values);
    end

    info = mcv.readDatasetInfo(files);
    paths = variablePaths(info.Variables);
    variableInfo = info.Variables(strcmp(paths, '/temperature'));
    assert(isequal(double(variableInfo.Size(:))', [2, 3, 3]));
    assert(variableInfo.ConcatDimension == 3);
    assert(variableInfo.SyntheticConcatDimension);
    assert(strcmp(variableInfo.Dimensions(3).Name, 'file_index'));

    xInfo = info.Variables(strcmp(paths, '/x'));
    yInfo = info.Variables(strcmp(paths, '/y'));
    assert(isequal(double(xInfo.Size(:))', 2));
    assert(isequal(double(yInfo.Size(:))', 3));
    assert(xInfo.ConcatDimension == 0 && yInfo.ConcatDimension == 0);

    [secondField, xCoordinate, yCoordinate, selection] = ...
        mcv.readVariableSlice(files, info, variableInfo, 1, 2, [1, 1, 2]);
    assert(isequal(secondField, reshape(11:16, [2, 3])));
    assert(isequal(xCoordinate, [10, 20]));
    assert(isequal(yCoordinate, [40, 50, 60]));
    assert(isequal(selection.start, [1, 1, 2]));

    [xzSlice, ~, fileCoordinate] = mcv.readVariableSlice( ...
        files, info, variableInfo, 1, 3, [1, 2, 1]);
    expected = [3, 13, 23; 4, 14, 24];
    assert(isequal(xzSlice, expected));
    assert(isequal(fileCoordinate, 1:3));

    fullData = mcv.readVariableData(files, variableInfo, [], []);
    assert(isequal(size(fullData), [2, 3, 3]));
    assert(isequal(fullData(:, :, 3), reshape(21:26, [2, 3])));

    secondaryInfo = info.Variables(strcmp(paths, '/humidity'));
    [primaryComparison, secondaryComparison] = ...
        mcv.readComparisonSlices(files, info, variableInfo, secondaryInfo, ...
        1, 2, [1, 1, 3]);
    assert(primaryComparison.selection.start(3) == 3);
    assert(secondaryComparison.selection.start(3) == 3);
    assert(isequal(primaryComparison.data, reshape(21:26, [2, 3])));
    assert(isequal(secondaryComparison.data, reshape(121:126, [2, 3])));
end

function testTemporalComparison()
    filename = [tempname(), '.nc'];
    cleanup = onCleanup(@() deleteIfPresent(filename)); %#ok<NASGU>
    createTemporalComparisonDataset(filename);

    info = mcv.readDatasetInfo(filename);
    names = {info.Variables.Name};
    primaryInfo = info.Variables(strcmp(names, 'primary'));
    secondaryInfo = info.Variables(strcmp(names, 'secondary'));
    [primary, secondary] = mcv.readComparisonSlices( ...
        filename, info, primaryInfo, secondaryInfo, 1, 2, [1, 1, 2]);

    assert(primary.selection.start(3) == 2);
    assert(secondary.selection.start(3) == 3);
    assert(isequal(primary.data, reshape(5:8, [2, 2])));
    assert(isequal(secondary.data, reshape(109:112, [2, 2])));
end

function testCFTime()
    [dates, isTime, labels, isNonGregorian] = mcv.decodeCFTime( ...
        [0, 1.5], 'days since 2000-01-01 00:00:00', 'standard');
    assert(isTime);
    assert(~isNonGregorian);
    assert(abs(dates(1) - datenum(2000, 1, 1)) < 1e-10);
    assert(abs((dates(2) - dates(1)) - 1.5) < 1e-10);
    assert(strcmp(labels{2}, '2000-01-02 12:00:00'));

    [calendar360, isTime, labels360, isNonGregorian] = mcv.decodeCFTime( ...
        [0, 1, 2, 31, 360], 'days since 2000-01-30', '360_day');
    assert(isTime && isNonGregorian);
    assert(isequal(diff(calendar360), [1, 1, 29, 329]));
    assert(strcmp(labels360{1}, '2000-01-30 00:00:00'));
    assert(strcmp(labels360{2}, '2000-02-01 00:00:00'));
    assert(strcmp(labels360{4}, '2000-03-01 00:00:00'));
    assert(strcmp(labels360{5}, '2001-01-30 00:00:00'));

    [~, isTime, noLeapLabels, isNonGregorian] = mcv.decodeCFTime( ...
        [0, 1, 2, 365], 'days since 2000-02-28', 'noleap');
    assert(isTime && isNonGregorian);
    assert(strcmp(noLeapLabels{2}, '2000-03-01 00:00:00'));
    assert(strcmp(noLeapLabels{4}, '2001-02-28 00:00:00'));

    [~, isTime, allLeapLabels, isNonGregorian] = mcv.decodeCFTime( ...
        [0, 1, 2, 366], 'days since 2001-02-28', 'all_leap');
    assert(isTime && isNonGregorian);
    assert(strcmp(allLeapLabels{2}, '2001-02-29 00:00:00'));
    assert(strcmp(allLeapLabels{3}, '2001-03-01 00:00:00'));
    assert(strcmp(allLeapLabels{4}, '2002-02-28 00:00:00'));

    [~, invalidTime] = mcv.decodeCFTime( ...
        0, 'days since 2000-01-31', '360_day');
    assert(~invalidTime);
end

function testDimensionSelection()
    [nearestIndex, actualValue] = mcv.nearestCoordinateIndex( ...
        [-10, 0, 10, 20], 7);
    assert(nearestIndex == 3 && actualValue == 10);

    mapping = struct('x', 1, 'y', 2, 'z', 3);
    [dimensions, cutDimension, planeName] = mcv.planeDimensions(mapping, 2);
    assert(isequal(dimensions, [1, 2]) && cutDimension == 3 && strcmp(planeName, 'XY'));
    [dimensions, cutDimension] = mcv.planeDimensions(mapping, 3);
    assert(isequal(dimensions, [1, 3]) && cutDimension == 2);
    fixedDimensions = setdiff(1:4, dimensions, 'stable');
    scanDimensions = setdiff(fixedDimensions, cutDimension, 'stable');
    assert(isequal(fixedDimensions, [2, 4]));
    assert(isequal(scanDimensions, 4));
    [dimensions, cutDimension] = mcv.planeDimensions(mapping, 4);
    assert(isequal(dimensions, [2, 3]) && cutDimension == 1);

    [x, y] = mcv.choosePlotDimensions([1, 4, 5]);
    assert(x == 2);
    assert(y == 3);

    [x, y] = mcv.choosePlotDimensions([1, 7, 1]);
    assert(x == 2);
    assert(y == 0);

    [x, y] = mcv.choosePlotDimensions([1, 1]);
    assert(x == 0);
    assert(y == 0);

    reference = comparisonVariable( ...
        {'x', 'y', 'time'}, [2, 3, 5], 3);
    target = comparisonVariable( ...
        {'y', 'x', 'record'}, [3, 2, 5], 3);
    [comparisonX, comparisonY, comparisonIndices] = ...
        mcv.matchSliceDimensions(reference, target, 1, 2, [1, 1, 4]);
    assert(comparisonX == 2 && comparisonY == 1);
    assert(isequal(comparisonIndices, [1, 1, 4]));
end

function testSlicePreparation()
    raw = reshape(1:8, [2, 1, 4]);
    data = mcv.prepareSlice(raw, [2, 1, 4], 3, 1);
    assert(isequal(size(data), [4, 2]));
    assert(isequal(data, [1, 2; 3, 4; 5, 6; 7, 8]));

    vector = mcv.prepareSlice((1:5)', 5, 1, 0);
    assert(isequal(vector, (1:5)'));
end

function testNetcdfRead()
    filename = [tempname(), '.nc'];
    cleanup = onCleanup(@() deleteIfPresent(filename)); %#ok<NASGU>

    nccreate(filename, 'longitude', 'Dimensions', {'longitude', 4});
    ncwrite(filename, 'longitude', [10; 20; 30; 40]);
    ncwriteatt(filename, 'longitude', 'units', 'degrees_east');
    ncwriteatt(filename, 'longitude', 'long_name', 'Longitude');
    ncwriteatt(filename, 'longitude', 'axis', 'X');

    nccreate(filename, 'latitude', 'Dimensions', {'latitude', 3});
    ncwrite(filename, 'latitude', [-1; 0; 1]);
    ncwriteatt(filename, 'latitude', 'units', 'degrees_north');
    ncwriteatt(filename, 'latitude', 'axis', 'Y');

    nccreate(filename, 'time', 'Dimensions', {'time', 2});
    ncwrite(filename, 'time', [0; 1]);
    ncwriteatt(filename, 'time', 'units', 'days since 2000-01-01 00:00:00');
    ncwriteatt(filename, 'time', 'standard_name', 'time');
    ncwriteatt(filename, 'time', 'axis', 'T');

    nccreate(filename, 'model_time', 'Dimensions', {'model_time', 3});
    ncwrite(filename, 'model_time', [0; 1; 31]);
    ncwriteatt(filename, 'model_time', 'units', 'days since 2000-01-30');
    ncwriteatt(filename, 'model_time', 'calendar', '360_day');
    ncwriteatt(filename, 'model_time', 'axis', 'T');

    nccreate(filename, 'depth', 'Dimensions', {'depth', 2});
    ncwrite(filename, 'depth', [0; 100]);
    ncwriteatt(filename, 'depth', 'units', 'm');
    ncwriteatt(filename, 'depth', 'positive', 'down');
    ncwriteatt(filename, 'depth', 'axis', 'Z');

    nccreate(filename, 'temperature', ...
        'Dimensions', {'longitude', 4, 'latitude', 3, 'time', 2});
    expected = reshape(1:24, [4, 3, 2]);
    ncwrite(filename, 'temperature', expected);
    ncwriteatt(filename, 'temperature', 'long_name', 'Air temperature');
    ncwriteatt(filename, 'temperature', 'units', 'K');
    ncwriteatt(filename, 'temperature', 'missing_value', 24);

    nccreate(filename, 'volume', ...
        'Dimensions', {'longitude', 4, 'latitude', 3, 'depth', 2});
    volumeExpected = reshape(1:24, [4, 3, 2]);
    ncwrite(filename, 'volume', volumeExpected);

    nccreate(filename, 'volume4d', ...
        'Dimensions', {'longitude', 4, 'latitude', 3, 'depth', 2, 'time', 2});
    volume4dExpected = reshape(1:48, [4, 3, 2, 2]);
    ncwrite(filename, 'volume4d', volume4dExpected);

    info = mcv.readDatasetInfo(filename);
    names = {info.Variables.Name};
    variableInfo = info.Variables(strcmp(names, 'temperature'));
    [data, xCoordinate, yCoordinate, selection, axesInfo] = mcv.readVariableSlice( ...
        filename, info, variableInfo, 1, 2, [1, 1, 2]);

    expectedSlice = expected(:, :, 2);
    expectedSlice(end) = NaN;
    assert(isequaln(data, expectedSlice));
    assert(isequal(xCoordinate, [10, 20, 30, 40]));
    assert(isequal(yCoordinate, [-1, 0, 1]));
    assert(isequal(selection.start, [1, 1, 2]));
    assert(isequal(selection.count, [4, 3, 1]));
    assert(strcmp(mcv.getAttribute(variableInfo, 'units', ''), 'K'));
    assert(strcmp(axesInfo.x.units, 'degrees_east'));
    assert(strcmp(mcv.axisLabel(axesInfo.y), 'latitude [degrees_north]'));
    assert(strcmp(mcv.formatAttributeValue([1, 2, 3]), '[1 2 3]'));

    temperatureMapping = mcv.findSpatialDimensions(info, variableInfo);
    assert(temperatureMapping.x == 1);
    assert(temperatureMapping.y == 2);
    assert(temperatureMapping.z == 0);

    timeInfo = info.Variables(strcmp(names, 'time'));
    decodedTime = mcv.readAxis(filename, info, timeInfo.Dimensions(1), 2);
    assert(decodedTime.isTime);
    assert(abs(diff(decodedTime.plotValues) - 1) < 1e-10);

    modelTimeInfo = info.Variables(strcmp(names, 'model_time'));
    modelTime = mcv.readAxis( ...
        filename, info, modelTimeInfo.Dimensions(1), 3, modelTimeInfo);
    assert(modelTime.isTime && modelTime.isNonGregorianTime);
    assert(strcmp(modelTime.timeLabels{2}, '2000-02-01 00:00:00'));
    assert(strcmp(modelTime.timeLabels{3}, '2000-03-01 00:00:00'));
    assert(strcmp(mcv.formatAxisValue(modelTime, 3), ...
        '2000-03-01 00:00:00'));

    volumeInfo = info.Variables(strcmp(names, 'volume'));
    mapping = mcv.findSpatialDimensions(info, volumeInfo);
    assert(mapping.x == 1);
    assert(mapping.y == 2);
    assert(mapping.z == 3);

    [xzSlice, xzX, xzZ, xzSelection] = mcv.readVariableSlice( ...
        filename, info, volumeInfo, mapping.x, mapping.z, [1, 2, 1]);
    assert(isequal(xzSlice, reshape(volumeExpected(:, 2, :), [4, 2])));
    assert(isequal(xzX, [10, 20, 30, 40]));
    assert(isequal(xzZ, [0, 100]));
    assert(isequal(xzSelection.count, [4, 1, 2]));

    volume4dInfo = info.Variables(strcmp(names, 'volume4d'));
    volume4dMapping = mcv.findSpatialDimensions(info, volume4dInfo);
    [xzAtY2T2, ~, ~, selection4d] = mcv.readVariableSlice( ...
        filename, info, volume4dInfo, volume4dMapping.x, volume4dMapping.z, ...
        [1, 2, 1, 2]);
    assert(isequal(xzAtY2T2, ...
        reshape(volume4dExpected(:, 2, :, 2), [4, 2])));
    assert(isequal(selection4d.start, [1, 2, 1, 2]));
    assert(isequal(selection4d.count, [4, 1, 2, 1]));

    [snapshots, snapshotSelection] = mcv.readVariableSnapshots( ...
        filename, volume4dInfo, 4, [2, 1]);
    assert(isequal(snapshots, volume4dExpected(:, :, :, [2, 1])));
    assert(snapshotSelection.snapshotDimension == 4);
    assert(isequal(snapshotSelection.snapshotIndices, [2, 1]));
    assert(isequal(snapshotSelection.exportedSize, [4, 3, 2, 2]));

    [comparisonX, comparisonY, comparisonIndices] = mcv.matchSliceDimensions( ...
        volumeInfo, variableInfo, 1, 2, [1, 2, 1]);
    assert(comparisonX == 1);
    assert(comparisonY == 2);
    assert(isequal(comparisonIndices, [1, 2, 1]));
end

function deleteIfPresent(filename)
    if exist(filename, 'file') == 2
        delete(filename);
    end
end

function createEmptyFile(filename)
    fileId = fopen(filename, 'w');
    assert(fileId >= 0);
    fclose(fileId);
end

function removeFolderIfPresent(folder)
    if exist(folder, 'dir') == 7
        rmdir(folder, 's');
    end
end

function paths = variablePaths(variables)
    paths = cell(1, numel(variables));
    for index = 1:numel(variables)
        paths{index} = mcv.variablePath(variables(index));
    end
end

function createGroupedDataset(filename)
    if mcv.isOctave()
        ncid = netcdf_create(filename, 'NETCDF4');
        groupId = netcdf_defGrp(ncid, 'ocean');
        dimensionId = netcdf_defDim(groupId, 'x', 3);
        coordinateId = netcdf_defVar(groupId, 'x', 'NC_DOUBLE', dimensionId);
        temperatureId = netcdf_defVar( ...
            groupId, 'temperature', 'NC_DOUBLE', dimensionId);
        auxiliaryDimensionId = netcdf_defDim(groupId, 'i', 3);
        longitudeId = netcdf_defVar( ...
            groupId, 'longitude', 'NC_DOUBLE', auxiliaryDimensionId);
        sampleId = netcdf_defVar( ...
            groupId, 'sample', 'NC_DOUBLE', auxiliaryDimensionId);
        nestedGroupId = netcdf_defGrp(groupId, 'nested');
        nestedDimensionId = netcdf_defDim(nestedGroupId, 'z', 2);
        saltId = netcdf_defVar( ...
            nestedGroupId, 'salt', 'NC_DOUBLE', nestedDimensionId);
        netcdf_putAtt(groupId, coordinateId, 'units', 'km');
        netcdf_putAtt(groupId, coordinateId, 'axis', 'X');
        netcdf_putAtt(groupId, longitudeId, 'units', 'degrees_east');
        netcdf_putAtt(groupId, longitudeId, 'standard_name', 'longitude');
        netcdf_putAtt(groupId, sampleId, 'coordinates', 'longitude');
        netcdf_endDef(ncid);
        netcdf_putVar(groupId, coordinateId, [10, 20, 30]);
        netcdf_putVar(groupId, temperatureId, [4, 5, 6]);
        netcdf_putVar(groupId, longitudeId, [42, 43, 44]);
        netcdf_putVar(groupId, sampleId, [7, 8, 9]);
        netcdf_putVar(nestedGroupId, saltId, [30, 31]);
        netcdf_close(ncid);
    else
        nccreate(filename, '/ocean/x', 'Dimensions', {'x', 3});
        ncwrite(filename, '/ocean/x', [10; 20; 30]);
        ncwriteatt(filename, '/ocean/x', 'units', 'km');
        ncwriteatt(filename, '/ocean/x', 'axis', 'X');
        nccreate(filename, '/ocean/temperature', 'Dimensions', {'x', 3});
        ncwrite(filename, '/ocean/temperature', [4; 5; 6]);
        nccreate(filename, '/ocean/longitude', 'Dimensions', {'i', 3});
        ncwrite(filename, '/ocean/longitude', [42; 43; 44]);
        ncwriteatt(filename, '/ocean/longitude', 'units', 'degrees_east');
        ncwriteatt(filename, '/ocean/longitude', 'standard_name', 'longitude');
        nccreate(filename, '/ocean/sample', 'Dimensions', {'i', 3});
        ncwrite(filename, '/ocean/sample', [7; 8; 9]);
        ncwriteatt(filename, '/ocean/sample', 'coordinates', 'longitude');
        nccreate(filename, '/ocean/nested/salt', 'Dimensions', {'z', 2});
        ncwrite(filename, '/ocean/nested/salt', [30; 31]);
    end
end

function createTimeDataset(filename, timeValues, temperatureValues)
    nccreate(filename, 'x', 'Dimensions', {'x', 2});
    ncwrite(filename, 'x', [10; 20]);
    ncwriteatt(filename, 'x', 'axis', 'X');
    nccreate(filename, 'time', 'Dimensions', {'time', 2});
    ncwrite(filename, 'time', timeValues(:));
    ncwriteatt(filename, 'time', 'axis', 'T');
    ncwriteatt(filename, 'time', 'standard_name', 'time');
    ncwriteatt(filename, 'time', 'units', 'days since 2000-01-01');
    nccreate(filename, 'temperature', 'Dimensions', {'x', 2, 'time', 2});
    ncwrite(filename, 'temperature', temperatureValues);
    ncwriteatt(filename, 'temperature', 'units', 'K');
end

function create2DFieldDataset(filename, temperatureValues)
    nccreate(filename, 'x', 'Dimensions', {'x', 2});
    ncwrite(filename, 'x', [10; 20]);
    ncwriteatt(filename, 'x', 'axis', 'X');
    nccreate(filename, 'y', 'Dimensions', {'y', 3});
    ncwrite(filename, 'y', [40; 50; 60]);
    ncwriteatt(filename, 'y', 'axis', 'Y');
    nccreate(filename, 'temperature', ...
        'Dimensions', {'x', 2, 'y', 3});
    ncwrite(filename, 'temperature', temperatureValues);
    ncwriteatt(filename, 'temperature', 'units', 'K');
    nccreate(filename, 'humidity', ...
        'Dimensions', {'x', 2, 'y', 3});
    ncwrite(filename, 'humidity', temperatureValues + 100);
    ncwriteatt(filename, 'humidity', 'units', 'kg kg-1');
end

function variableInfo = comparisonVariable(names, sizes, concatDimension)
    dimensions = repmat( ...
        struct('Name', '', 'Length', 0, 'Unlimited', false), ...
        1, numel(names));
    for dimensionIndex = 1:numel(names)
        dimensions(dimensionIndex).Name = names{dimensionIndex};
        dimensions(dimensionIndex).Length = sizes(dimensionIndex);
    end
    variableInfo = struct( ...
        'Dimensions', dimensions, ...
        'Size', sizes, ...
        'ConcatDimension', concatDimension);
end

function createTemporalComparisonDataset(filename)
    nccreate(filename, 'x', 'Dimensions', {'x', 2});
    ncwrite(filename, 'x', [1; 2]);
    ncwriteatt(filename, 'x', 'axis', 'X');
    nccreate(filename, 'y', 'Dimensions', {'y', 2});
    ncwrite(filename, 'y', [1; 2]);
    ncwriteatt(filename, 'y', 'axis', 'Y');

    nccreate(filename, 'time_primary', 'Dimensions', {'time_primary', 3});
    ncwrite(filename, 'time_primary', [0; 1; 2]);
    ncwriteatt(filename, 'time_primary', 'axis', 'T');
    ncwriteatt(filename, 'time_primary', 'units', 'days since 2000-01-01');
    nccreate(filename, 'time_secondary', 'Dimensions', {'time_secondary', 3});
    ncwrite(filename, 'time_secondary', [2; 0; 1]);
    ncwriteatt(filename, 'time_secondary', 'axis', 'T');
    ncwriteatt(filename, 'time_secondary', 'units', 'days since 2000-01-01');

    nccreate(filename, 'primary', ...
        'Dimensions', {'x', 2, 'y', 2, 'time_primary', 3});
    ncwrite(filename, 'primary', reshape(1:12, [2, 2, 3]));
    nccreate(filename, 'secondary', ...
        'Dimensions', {'x', 2, 'y', 2, 'time_secondary', 3});
    ncwrite(filename, 'secondary', reshape(101:112, [2, 2, 3]));
end
