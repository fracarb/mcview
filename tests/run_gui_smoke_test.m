function run_gui_smoke_test()
%RUN_GUI_SMOKE_TEST Verifica creazione e rendering base della GUI.

    testsFolder = fileparts(mfilename('fullpath'));
    projectFolder = fileparts(testsFolder);
    addpath(projectFolder);
    mcv.setupEnvironment();

    previousVisibility = get(0, 'DefaultFigureVisible');
    visibilityCleanup = onCleanup( ...
        @() set(0, 'DefaultFigureVisible', previousVisibility)); %#ok<NASGU>
    set(0, 'DefaultFigureVisible', 'off');

    filename = [tempname(), '.nc'];
    fileCleanup = onCleanup(@() deleteIfPresent(filename)); %#ok<NASGU>
    nccreate(filename, 'lon', 'Dimensions', {'lon', 4});
    ncwrite(filename, 'lon', [0; 90; 180; 270]);
    ncwriteatt(filename, 'lon', 'units', 'degrees_east');
    ncwriteatt(filename, 'lon', 'axis', 'X');
    nccreate(filename, 'lat', 'Dimensions', {'lat', 3});
    ncwrite(filename, 'lat', [-45; 0; 45]);
    ncwriteatt(filename, 'lat', 'units', 'degrees_north');
    ncwriteatt(filename, 'lat', 'axis', 'Y');
    nccreate(filename, 'field', 'Dimensions', {'lon', 4, 'lat', 3, 'time', 2});
    ncwrite(filename, 'field', reshape(1:24, [4, 3, 2]));

    viewer = mcview(filename);
    viewerCleanup = onCleanup(@() closeIfPresent(viewer)); %#ok<NASGU>
    assert(ishandle(viewer));
    drawnow();
    viewerAxes = findobj(viewer, 'Type', 'axes');
    assert(~isempty(viewerAxes));
    assert(isempty(get(viewerAxes(1), 'Children')));
    viewerState = guidata(viewer);
    assert(viewerState.variableIndex == 0);

    coastCheckbox = findobj(viewer, 'Tag', 'mcviewShowCoast');
    assert(isscalar(coastCheckbox));
    assert(get(coastCheckbox, 'Value') == 1);
    set(coastCheckbox, 'Value', 0);
    coastCallback = get(coastCheckbox, 'Callback');
    feval(coastCallback, coastCheckbox, []);
    viewerState = guidata(viewer);
    assert(~viewerState.geoOptions.showCoast);
    coastColorPopup = findobj(viewer, 'Tag', 'mcviewCoastColor');
    assert(isscalar(coastColorPopup));
    set(coastColorPopup, 'Value', 3);
    coastColorCallback = get(coastColorPopup, 'Callback');
    feval(coastColorCallback, coastColorPopup, []);
    viewerState = guidata(viewer);
    assert(isequal(viewerState.geoOptions.coastColor, [0.90, 0.10, 0.10]));

    variableList = findobj(viewer, 'Style', 'listbox');
    set(variableList, 'Value', 2);
    callback = get(variableList, 'Callback');
    feval(callback, variableList, []);
    drawnow();
    viewerState = guidata(viewer);
    assert(viewerState.variableIndex == 1);
    assert(~isempty(get(viewerAxes(1), 'Children')));
    assert(strcmp(get(viewerAxes(1), 'YDir'), 'normal'));
    assert(isempty(get(get(viewerAxes(1), 'Title'), 'String')));
    assert(~viewerState.geoOptions.showCoast);
    detailsText = findobj(viewer, 'Tag', 'mcviewDetails');
    detailLines = get(detailsText, 'String');
    assert(iscell(detailLines));
    assert(numel(detailLines) >= 3);
    slicePosition = findobj(viewer, 'Tag', 'mcviewSlicePosition');
    assert(isscalar(slicePosition));
    cutModePopup = findobj(viewer, 'Tag', 'mcviewCutMode');
    assert(isscalar(cutModePopup));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewCutAxis')));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewCutValue')));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewApplyCut')));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewCutPrevious')));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewCutNext')));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewScanDimension')));
    assert(isscalar(findobj(viewer, 'Tag', 'mcviewScanSlider')));
    exportButton = findobj(viewer, 'Tag', 'mcviewExport');
    assert(isscalar(exportButton));
    assert(strcmp(get(exportButton, 'String'), 'Esporta...'));
    close(viewer);
    fprintf('MCVIEW: smoke test grafico completato.\n');
end

function closeIfPresent(handle)
    if ~isempty(handle) && ishandle(handle)
        close(handle);
    end
end

function deleteIfPresent(filename)
    if exist(filename, 'file') == 2
        delete(filename);
    end
end
