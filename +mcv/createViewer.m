function figureHandle = createViewer(environment, initialFilename)
%CREATEVIEWER Costruisce la GUI portabile basata su figure/uicontrol.

    background = [0.94, 0.94, 0.94];
    accent = [0.12, 0.36, 0.58];
    errorColor = [0.72, 0.12, 0.12];
    layout = mcv.viewerLayout();

    figureHandle = figure( ...
        'Name', sprintf('MCVIEW - %s', environment.name), ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'figure', ...
        'Color', background, ...
        'Units', 'normalized', ...
        'Position', [0.06, 0.08, 0.88, 0.82], ...
        'CloseRequestFcn', @onClose);

    handles.animationMenu = uimenu(figureHandle, 'Label', 'Animazione');
    handles.speedItems = cell(1, 4);
    handles.speedItems{1} = uimenu(handles.animationMenu, 'Label', 'Velocita 0.5x', ...
        'Callback', @(source, ~) onAnimationSpeed(source, 0.16));
    handles.speedItems{2} = uimenu(handles.animationMenu, 'Label', 'Velocita 1x', ...
        'Checked', 'on', 'Callback', @(source, ~) onAnimationSpeed(source, 0.08));
    handles.speedItems{3} = uimenu(handles.animationMenu, 'Label', 'Velocita 2x', ...
        'Callback', @(source, ~) onAnimationSpeed(source, 0.04));
    handles.speedItems{4} = uimenu(handles.animationMenu, 'Label', 'Velocita 5x', ...
        'Callback', @(source, ~) onAnimationSpeed(source, 0.016));
    handles.reverseItem = uimenu(handles.animationMenu, 'Label', 'Direzione inversa', ...
        'Separator', 'on', 'Checked', 'off', 'Callback', @onAnimationDirection);
    handles.loopItem = uimenu(handles.animationMenu, 'Label', 'Ripeti in ciclo', ...
        'Checked', 'on', 'Callback', @onToggleLoop);
    handles.followItem = uimenu(handles.animationMenu, 'Label', 'Segui file in crescita', ...
        'Checked', 'off', 'Callback', @onToggleFollow);
    uimenu(handles.animationMenu, 'Label', 'Rileggi dataset ora', ...
        'Separator', 'on', 'Callback', @(~, ~) refreshDataset(false));

    handles.rangeMenu = uimenu(figureHandle, 'Label', 'Intervallo');
    handles.rangeItems = cell(1, 5);
    handles.rangeItems{1} = uimenu(handles.rangeMenu, 'Label', 'Slice corrente', ...
        'Checked', 'on', 'Callback', @(source, ~) onRangeMode(source, 'slice'));
    handles.rangeItems{2} = uimenu(handles.rangeMenu, 'Label', 'Globale rapido', ...
        'Callback', @(source, ~) onRangeMode(source, 'global-fast'));
    handles.rangeItems{3} = uimenu(handles.rangeMenu, 'Label', 'Globale completo', ...
        'Callback', @(source, ~) onRangeMode(source, 'global-all'));
    handles.rangeItems{4} = uimenu(handles.rangeMenu, 'Label', 'Percentile 2-98', ...
        'Callback', @(source, ~) onRangeMode(source, 'percentile'));
    handles.rangeItems{5} = uimenu(handles.rangeMenu, 'Label', 'Simmetrico intorno a zero', ...
        'Callback', @(source, ~) onRangeMode(source, 'symmetric'));
    uimenu(handles.rangeMenu, 'Label', 'Istogramma slice', ...
        'Separator', 'on', 'Callback', @onHistogram);

    handles.mapMenu = uimenu(figureHandle, 'Label', 'Mappa');
    handles.coastItem = uimenu(handles.mapMenu, 'Label', 'Mostra coste', ...
        'Checked', 'on', 'Callback', @onToggleCoast);
    handles.wrapItem = uimenu(handles.mapMenu, 'Label', 'Longitudine -180..180', ...
        'Checked', 'on', 'Callback', @onToggleLongitudeWrap);
    handles.equirectangularItem = uimenu(handles.mapMenu, ...
        'Label', 'Proiezione lon/lat', 'Separator', 'on', 'Checked', 'on', ...
        'Callback', @(source, ~) onProjection(source, 'equirectangular'));
    handles.mercatorItem = uimenu(handles.mapMenu, 'Label', 'Proiezione Mercatore', ...
        'Checked', 'off', 'Callback', @(source, ~) onProjection(source, 'mercator'));

    handles.performanceMenu = uimenu(figureHandle, 'Label', 'Prestazioni');
    handles.pixelItems = cell(1, 4);
    handles.pixelItems{1} = uimenu(handles.performanceMenu, 'Label', 'Display 250k pixel', ...
        'Callback', @(source, ~) onPixelLimit(source, 250000));
    handles.pixelItems{2} = uimenu(handles.performanceMenu, 'Label', 'Display 750k pixel', ...
        'Checked', 'on', 'Callback', @(source, ~) onPixelLimit(source, 750000));
    handles.pixelItems{3} = uimenu(handles.performanceMenu, 'Label', 'Display 2M pixel', ...
        'Callback', @(source, ~) onPixelLimit(source, 2000000));
    handles.pixelItems{4} = uimenu(handles.performanceMenu, 'Label', 'Display completo', ...
        'Callback', @(source, ~) onPixelLimit(source, Inf));
    handles.cacheItems = cell(1, 3);
    handles.cacheItems{1} = uimenu(handles.performanceMenu, 'Label', 'Cache 64 MB', ...
        'Separator', 'on', 'Callback', @(source, ~) onCacheLimit(source, 64));
    handles.cacheItems{2} = uimenu(handles.performanceMenu, 'Label', 'Cache 256 MB', ...
        'Checked', 'on', 'Callback', @(source, ~) onCacheLimit(source, 256));
    handles.cacheItems{3} = uimenu(handles.performanceMenu, 'Label', 'Cache 512 MB', ...
        'Callback', @(source, ~) onCacheLimit(source, 512));
    uimenu(handles.performanceMenu, 'Label', 'Svuota cache', ...
        'Separator', 'on', 'Callback', @onClearCache);
    uimenu(handles.performanceMenu, 'Label', 'Annulla calcolo corrente', ...
        'Callback', @onCancelOperation);

    handles.openButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Apri NetCDF...', ...
        'Units', 'normalized', 'Position', layout.openButton, ...
        'FontWeight', 'bold', 'Callback', @onOpenFile);
    handles.attributesButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Attributi...', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.attributesButton, ...
        'Callback', @onShowAttributes);
    handles.fileText = uicontrol(figureHandle, ...
        'Style', 'text', 'String', 'Nessun file aperto', ...
        'Units', 'normalized', 'Position', layout.fileText, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);

    uicontrol(figureHandle, 'Style', 'text', 'String', 'Variabili / gruppi', ...
        'Units', 'normalized', 'Position', layout.variablesLabel, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
        'ForegroundColor', accent, 'BackgroundColor', background);
    handles.variableList = uicontrol(figureHandle, ...
        'Style', 'listbox', 'String', {'(apri un file)'}, ...
        'Units', 'normalized', 'Position', layout.variableList, ...
        'TooltipString', 'Seleziona una variabile o espandi un gruppo [+]', ...
        'Callback', @onVariableChanged, 'BackgroundColor', [1, 1, 1]);

    uicontrol(figureHandle, 'Style', 'text', 'String', 'Asse X', ...
        'Units', 'normalized', 'Position', layout.xLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.xPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'(nessuna)'}, ...
        'Units', 'normalized', 'Position', layout.xPopup, ...
        'Callback', @onAxesChanged, 'BackgroundColor', [1, 1, 1]);
    uicontrol(figureHandle, 'Style', 'text', 'String', 'Asse Y', ...
        'Units', 'normalized', 'Position', layout.yLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.yPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'(nessuna)'}, ...
        'Units', 'normalized', 'Position', layout.yPopup, ...
        'Callback', @onAxesChanged, 'BackgroundColor', [1, 1, 1]);

    handles.planePopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'Piano manuale', 'Piano XY', 'Piano XZ', 'Piano YZ'}, ...
        'Units', 'normalized', 'Position', layout.planePopup, ...
        'TooltipString', 'Seleziona rapidamente il piano di taglio', ...
        'Callback', @onPlaneChanged, 'BackgroundColor', [1, 1, 1]);

    handles.fixedLabel = uicontrol(figureHandle, ...
        'Style', 'text', 'String', 'Asse di taglio', ...
        'Units', 'normalized', 'Position', layout.fixedLabel, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
        'ForegroundColor', accent, 'BackgroundColor', background);
    handles.fixedPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'(nessuna)'}, 'Tag', 'mcviewCutAxis', ...
        'Units', 'normalized', 'Position', layout.fixedPopup, ...
        'Callback', @onFixedDimensionChanged, 'BackgroundColor', [1, 1, 1]);
    handles.cutValueLabel = uicontrol(figureHandle, ...
        'Style', 'text', 'String', 'Valore', ...
        'Units', 'normalized', 'Position', layout.cutValueLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.cutModePopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'Indice', 'Coordinata'}, ...
        'Value', 1, 'Tag', 'mcviewCutMode', ...
        'Units', 'normalized', 'Position', layout.cutModePopup, ...
        'TooltipString', 'Interpreta il valore come indice o coordinata fisica', ...
        'Callback', @onCutModeChanged, 'BackgroundColor', [1, 1, 1]);
    handles.fixedEdit = uicontrol(figureHandle, ...
        'Style', 'edit', 'String', '1', 'Tag', 'mcviewCutValue', ...
        'Units', 'normalized', 'Position', layout.fixedEdit, ...
        'Callback', @onIndexEdited, 'BackgroundColor', [1, 1, 1]);
    handles.applyCutButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Vai', 'Enable', 'off', ...
        'Tag', 'mcviewApplyCut', ...
        'Units', 'normalized', 'Position', layout.applyCutButton, ...
        'TooltipString', 'Applica il valore del taglio', ...
        'Callback', @onApplyCut);
    handles.cutPreviousButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', '<', 'Enable', 'off', ...
        'Tag', 'mcviewCutPrevious', ...
        'Units', 'normalized', 'Position', layout.cutPreviousButton, ...
        'TooltipString', 'Taglio precedente lungo l''asse ortogonale', ...
        'Callback', @(~, ~) stepCut(-1));
    handles.fixedSlider = uicontrol(figureHandle, ...
        'Style', 'slider', 'Min', 1, 'Max', 2, 'Value', 1, ...
        'SliderStep', [1, 1], 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.fixedSlider, ...
        'Callback', @onIndexSlid);
    handles.cutNextButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', '>', 'Enable', 'off', ...
        'Tag', 'mcviewCutNext', ...
        'Units', 'normalized', 'Position', layout.cutNextButton, ...
        'TooltipString', 'Taglio successivo lungo l''asse ortogonale', ...
        'Callback', @(~, ~) stepCut(1));
    handles.fixedValueText = uicontrol(figureHandle, ...
        'Style', 'text', 'String', '', 'Tag', 'mcviewSlicePosition', ...
        'Units', 'normalized', 'Position', layout.fixedValueText, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background, ...
        'ForegroundColor', [0.25, 0.25, 0.25]);

    handles.scanLabel = uicontrol(figureHandle, ...
        'Style', 'text', 'String', 'Dimensione da scorrere', ...
        'Units', 'normalized', 'Position', layout.scanLabel, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
        'ForegroundColor', accent, 'BackgroundColor', background);
    handles.scanPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'(nessuna)'}, ...
        'Tag', 'mcviewScanDimension', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.scanPopup, ...
        'Callback', @onScanDimensionChanged, 'BackgroundColor', [1, 1, 1]);
    handles.scanSlider = uicontrol(figureHandle, ...
        'Style', 'slider', 'Min', 1, 'Max', 2, 'Value', 1, ...
        'SliderStep', [1, 1], 'Enable', 'off', ...
        'Tag', 'mcviewScanSlider', ...
        'Units', 'normalized', 'Position', layout.scanSlider, ...
        'Callback', @onScanSlid);

    handles.firstButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', '|<', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.firstButton, ...
        'TooltipString', 'Prima slice', 'Callback', @(~, ~) stepFrame('first'));
    handles.previousButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', '<', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.previousButton, ...
        'TooltipString', 'Slice precedente', 'Callback', @(~, ~) stepFrame(-1));
    handles.playButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Play', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.playButton, ...
        'TooltipString', 'Avvia o ferma animazione', 'Callback', @onPlay);
    handles.nextButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', '>', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.nextButton, ...
        'TooltipString', 'Slice successiva', 'Callback', @(~, ~) stepFrame(1));
    handles.lastButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', '>|', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.lastButton, ...
        'TooltipString', 'Ultima slice', 'Callback', @(~, ~) stepFrame('last'));

    uicontrol(figureHandle, 'Style', 'text', 'String', 'Mappa colori', ...
        'Units', 'normalized', 'Position', layout.colormapLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.colormapPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', ...
        'String', {'parula', 'divergente', 'jet', 'hot', 'cool', 'gray'}, ...
        'Units', 'normalized', 'Position', layout.colormapPopup, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', [1, 1, 1]);
    handles.autoLimits = uicontrol(figureHandle, ...
        'Style', 'checkbox', 'String', 'Limiti colore automatici', 'Value', 1, ...
        'Units', 'normalized', 'Position', layout.autoLimits, ...
        'Callback', @onLimitsModeChanged, 'BackgroundColor', background);
    uicontrol(figureHandle, 'Style', 'text', 'String', 'min', ...
        'Units', 'normalized', 'Position', layout.minLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.minEdit = uicontrol(figureHandle, ...
        'Style', 'edit', 'String', '', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.minEdit, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', [1, 1, 1]);
    uicontrol(figureHandle, 'Style', 'text', 'String', 'max', ...
        'Units', 'normalized', 'Position', layout.maxLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.maxEdit = uicontrol(figureHandle, ...
        'Style', 'edit', 'String', '', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.maxEdit, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', [1, 1, 1]);
    handles.statusText = uicontrol(figureHandle, ...
        'Style', 'text', 'String', 'Apri un dataset NetCDF per iniziare.', ...
        'Units', 'normalized', 'Position', layout.statusText, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background, ...
        'ForegroundColor', [0.25, 0.25, 0.25]);

    uicontrol(figureHandle, 'Style', 'text', 'String', 'Trasformazione', ...
        'Units', 'normalized', 'Position', layout.transformLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.transformPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', ...
        'String', {'Lineare', 'Enfasi bassi', 'Enfasi alti', 'Log10'}, ...
        'Units', 'normalized', 'Position', layout.transformPopup, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', [1, 1, 1]);
    handles.interpolationPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', 'String', {'Pixel', 'Bilineare'}, ...
        'Units', 'normalized', 'Position', layout.interpolationPopup, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', [1, 1, 1]);
    handles.invertColors = uicontrol(figureHandle, ...
        'Style', 'checkbox', 'String', 'Inverti colori', ...
        'Units', 'normalized', 'Position', layout.invertColors, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', background);
    handles.flipVertical = uicontrol(figureHandle, ...
        'Style', 'checkbox', 'String', 'Inverti Y', 'Value', 0, ...
        'Units', 'normalized', 'Position', layout.flipVertical, ...
        'Callback', @onDisplayChanged, 'BackgroundColor', background);
    handles.profileButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Profilo 1D', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.profileButton, ...
        'TooltipString', 'Grafico lungo la dimensione di scansione', ...
        'Callback', @onProfile);
    handles.compareButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Confronta', 'Enable', 'off', ...
        'Units', 'normalized', 'Position', layout.compareButton, ...
        'TooltipString', 'Affianca, sottrai o dividi una seconda variabile', ...
        'Callback', @onCompare);
    handles.exportButton = uicontrol(figureHandle, ...
        'Style', 'pushbutton', 'String', 'Esporta...', 'Tag', 'mcviewExport', ...
        'Units', 'normalized', 'Position', layout.exportButton, ...
        'TooltipString', 'Esporta la vista o la variabile selezionata', ...
        'Callback', @onExportMenu);

    uicontrol(figureHandle, 'Style', 'text', 'String', 'Mappa', ...
        'Units', 'normalized', 'Position', layout.mapLabel, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
        'ForegroundColor', accent, 'BackgroundColor', background);
    handles.showCoast = uicontrol(figureHandle, ...
        'Style', 'checkbox', 'String', 'Mostra coste', 'Value', 1, ...
        'Tag', 'mcviewShowCoast', ...
        'Units', 'normalized', 'Position', layout.showCoast, ...
        'TooltipString', 'Mostra o nasconde le coste Natural Earth', ...
        'Callback', @onCoastCheckbox, 'BackgroundColor', background);
    uicontrol(figureHandle, 'Style', 'text', 'String', 'Colore coste', ...
        'Units', 'normalized', 'Position', layout.coastColorLabel, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', background);
    handles.coastColorPopup = uicontrol(figureHandle, ...
        'Style', 'popupmenu', ...
        'String', {'Nero', 'Bianco', 'Rosso', 'Grigio', 'Blu', ...
            'Verde', 'Giallo', 'Magenta', 'Ciano'}, ...
        'Value', 1, 'Tag', 'mcviewCoastColor', ...
        'Units', 'normalized', 'Position', layout.coastColorPopup, ...
        'TooltipString', 'Colore delle linee di costa Natural Earth', ...
        'Callback', @onCoastColorChanged, 'BackgroundColor', [1, 1, 1]);

    handles.axes = axes('Parent', figureHandle, 'Units', 'normalized', ...
        'Position', layout.axes, 'Box', 'on');
    handles.detailsText = uicontrol(figureHandle, ...
        'Style', 'text', 'String', '', 'Tag', 'mcviewDetails', ...
        'Units', 'normalized', 'Position', layout.detailsText, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [1, 1, 1], ...
        'ForegroundColor', [0.25, 0.25, 0.25]);

    state = struct();
    state.environment = environment;
    state.handles = handles;
    state.filename = '';
    state.info = [];
    state.variableIndex = 0;
    state.variableTreeExpanded = {};
    state.variableTreeVariableIndices = 0;
    state.variableTreeGroupPaths = {''};
    state.xDimension = 0;
    state.yDimension = 0;
    state.cutDimension = 0;
    state.activePlane = '';
    state.indices = [];
    state.fixedDimensions = [];
    state.scanDimensions = [];
    state.scanDimension = 0;
    state.isPlaying = false;
    state.renderedData = [];
    state.xCoordinate = [];
    state.yCoordinate = [];
    state.axesInfo = struct('x', [], 'y', []);
    state.clickedPoint = [];
    state.clickedPointLabel = '';
    state.profileFigure = [];
    state.profileAxes = [];
    state.profiles = {};
    state.profileAxisName = '';
    state.animationDelay = 0.08;
    state.animationDirection = 1;
    state.animationLoop = true;
    state.followGrowingFile = false;
    state.sliceCacheKeys = {};
    state.sliceCacheValues = {};
    state.sliceCacheBytes = [];
    state.sliceCacheLimit = 24;
    state.sliceCacheMaxBytes = 256 * 1024 * 1024;
    state.rangeMode = 'slice';
    state.rangeCacheKeys = {};
    state.rangeCacheValues = {};
    state.geoOptions = struct('showCoast', true, ...
        'coastColor', mcv.coastlineColor('Nero'), ...
        'wrapLongitude', true, 'projection', 'equirectangular');
    state.geoInfo = struct('isGeographic', false);
    state.maxDisplayPixels = 750000;
    state.displaySampling = struct('xIndices', [], 'yIndices', [], ...
        'wasDownsampled', false);
    state.cancelRequested = false;
    guidata(figureHandle, state);
    clearVariableSelection();
    setStatus('Apri un dataset e seleziona una variabile.', false);

    if ~isempty(initialFilename)
        openDataset(initialFilename);
    end

    function onOpenFile(~, ~)
        [name, folder] = uigetfile( ...
            {'*.nc;*.nc4;*.cdf', 'File NetCDF (*.nc, *.nc4, *.cdf)'; ...
             '*.*', 'Tutti i file'}, ...
            'Apri uno o piu dataset NetCDF', 'MultiSelect', 'on');
        if isequal(name, 0)
            return;
        end
        if iscell(name)
            filenames = cell(1, numel(name));
            for fileIndex = 1:numel(name)
                filenames{fileIndex} = fullfile(folder, name{fileIndex});
            end
            openDataset(filenames);
        else
            openDataset(fullfile(folder, name));
        end
    end

    function openDataset(filename)
        setStatus('Lettura dei metadati...', false);
        drawnow();
        try
            info = mcv.readDatasetInfo(filename);
            if numel(info.FileNames) == 1
                datasetSource = info.FileNames{1};
            else
                datasetSource = info.FileNames;
            end
            current = guidata(figureHandle);
            if ~isempty(current.profileFigure) && ishandle(current.profileFigure)
                delete(current.profileFigure);
            end
            current.filename = datasetSource;
            current.info = info;
            current.variableIndex = 0;
            [treeLabels, treeVariableIndices, treeGroupPaths, treeExpanded] = ...
                mcv.variableTreeRows(info);
            current.variableTreeExpanded = treeExpanded;
            current.variableTreeVariableIndices = treeVariableIndices;
            current.variableTreeGroupPaths = treeGroupPaths;
            current.xDimension = 0;
            current.yDimension = 0;
            current.indices = [];
            current.fixedDimensions = [];
            current.scanDimensions = [];
            current.scanDimension = 0;
            current.clickedPoint = [];
            current.clickedPointLabel = '';
            current.isPlaying = false;
            current.profileFigure = [];
            current.profileAxes = [];
            current.profiles = {};
            current.profileAxisName = '';
            current.sliceCacheKeys = {};
            current.sliceCacheValues = {};
            current.sliceCacheBytes = [];
            current.rangeCacheKeys = {};
            current.rangeCacheValues = {};
            guidata(figureHandle, current);

            set(handles.variableList, 'String', treeLabels, 'Value', 1);
            if iscell(datasetSource)
                fileLabel = sprintf('%d file: %s', numel(datasetSource), datasetSource{1});
                fileTooltip = strjoin(datasetSource, sprintf('\n'));
            else
                fileLabel = datasetSource;
                fileTooltip = datasetSource;
            end
            set(handles.fileText, 'String', fileLabel, 'TooltipString', fileTooltip);
            datasetTitle = mcv.getAttribute(info, 'title', '');
            if isnumeric(datasetTitle), datasetTitle = num2str(datasetTitle); end
            if isempty(datasetTitle)
                windowTitle = sprintf('MCVIEW - %s', fileLabel);
            else
                windowTitle = sprintf('MCVIEW - %s - %s', char(datasetTitle), fileLabel);
            end
            set(figureHandle, 'Name', windowTitle);
            set(handles.attributesButton, 'Enable', 'on');
            set(handles.compareButton, 'Enable', 'off');
            if isempty(info.Variables)
                clearVariableSelection();
                setStatus('Il dataset non contiene variabili leggibili.', true);
            else
                clearVariableSelection();
                setStatus('Dataset aperto. Seleziona una variabile.', false);
            end
        catch exception
            setStatus(exception.message, true);
        end
    end

    function onVariableChanged(source, ~)
        stopPlayback();
        selectedRow = get(source, 'Value');
        current = guidata(figureHandle);
        if selectedRow < 1 || ...
                selectedRow > numel(current.variableTreeVariableIndices)
            return;
        end
        groupPath = current.variableTreeGroupPaths{selectedRow};
        if ~isempty(groupPath)
            match = find(strcmp(current.variableTreeExpanded, groupPath), 1);
            if isempty(match)
                current.variableTreeExpanded{end + 1} = groupPath;
            else
                current.variableTreeExpanded(match) = [];
            end
            guidata(figureHandle, current);
            rebuildVariableTree(current.variableIndex);
            return;
        end
        variableIndex = current.variableTreeVariableIndices(selectedRow);
        if variableIndex == 0
            clearVariableSelection();
        else
            selectVariable(variableIndex);
        end
    end

    function rebuildVariableTree(selectedVariableIndex)
        current = guidata(figureHandle);
        [labels, variableIndices, groupPaths] = mcv.variableTreeRows( ...
            current.info, current.variableTreeExpanded);
        current.variableTreeVariableIndices = variableIndices;
        current.variableTreeGroupPaths = groupPaths;
        guidata(figureHandle, current);

        selectedRow = find(variableIndices == selectedVariableIndex & ...
            variableIndices > 0, 1);
        if isempty(selectedRow)
            set(handles.variableList, 'String', labels, 'Value', 1);
            if selectedVariableIndex > 0
                clearVariableSelection();
            end
            return;
        end
        set(handles.variableList, 'String', labels, 'Value', selectedRow);
    end

    function onShowAttributes(~, ~)
        current = guidata(figureHandle);
        if current.variableIndex == 0
            mcv.showAttributes(current.info, struct([]));
        else
            mcv.showAttributes(current.info, ...
                current.info.Variables(current.variableIndex));
        end
    end

    function selectVariable(index)
        current = guidata(figureHandle);
        if isempty(current.info) || isempty(current.info.Variables)
            return;
        end
        index = max(1, min(index, numel(current.info.Variables)));
        variableInfo = current.info.Variables(index);
        [xDimension, yDimension] = ...
            mcv.chooseVariablePlotDimensions(current.info, variableInfo);

        current.variableIndex = index;
        current.xDimension = xDimension;
        current.yDimension = yDimension;
        current.cutDimension = 0;
        current.activePlane = '';
        current.scanDimensions = [];
        current.scanDimension = 0;
        current.indices = ones(1, numel(variableInfo.Dimensions));
        current.clickedPoint = [];
        guidata(figureHandle, current);
        selectedRow = find(current.variableTreeVariableIndices == index, 1);
        if ~isempty(selectedRow)
            set(handles.variableList, 'Value', selectedRow);
        end
        set(handles.compareButton, 'Enable', onOff(numel(current.info.Variables) > 1));
        set(handles.planePopup, 'Value', 1);
        updateDimensionControls();
        renderSelection();
    end

    function clearVariableSelection()
        current = guidata(figureHandle);
        current.variableIndex = 0;
        current.xDimension = 0;
        current.yDimension = 0;
        current.cutDimension = 0;
        current.activePlane = '';
        current.indices = [];
        current.fixedDimensions = [];
        current.scanDimensions = [];
        current.scanDimension = 0;
        current.renderedData = [];
        current.xCoordinate = [];
        current.yCoordinate = [];
        current.axesInfo = struct('x', [], 'y', []);
        current.clickedPoint = [];
        current.clickedPointLabel = '';
        guidata(figureHandle, current);
        set(handles.variableList, 'Value', 1);
        set(handles.xPopup, 'String', {'(nessuna)'}, 'Value', 1, 'Enable', 'off');
        set(handles.yPopup, 'String', {'(nessuna)'}, 'Value', 1, 'Enable', 'off');
        set(handles.planePopup, 'Value', 1, 'Enable', 'off');
        set(handles.fixedPopup, 'String', {'(nessuna)'}, ...
            'Value', 1, 'Enable', 'off');
        set(handles.cutModePopup, 'Value', 1, 'Enable', 'off');
        set(handles.fixedEdit, 'String', '1', 'Enable', 'off');
        set(handles.applyCutButton, 'Enable', 'off');
        set(handles.cutPreviousButton, 'Enable', 'off');
        set(handles.cutNextButton, 'Enable', 'off');
        set(handles.fixedSlider, 'Enable', 'off', 'Min', 1, 'Max', 2, 'Value', 1);
        set(handles.fixedLabel, 'String', 'Asse di taglio');
        set(handles.fixedValueText, 'String', '');
        set(handles.scanLabel, 'String', 'Dimensione da scorrere');
        set(handles.scanPopup, 'String', {'(nessuna)'}, ...
            'Value', 1, 'Enable', 'off');
        set(handles.scanSlider, 'Enable', 'off', ...
            'Min', 1, 'Max', 2, 'Value', 1);
        setPlaybackControls('off');
        set(handles.profileButton, 'Enable', 'off');
        set(handles.compareButton, 'Enable', 'off');
        set(handles.detailsText, 'String', '');
        showEmptyAxes('Seleziona una variabile dal pannello a sinistra.');
    end

    function showEmptyAxes(message)
        cla(handles.axes);
        try
            delete(findall(figureHandle, 'Type', 'ColorBar'));
        catch
        end
        try
            delete(findall(figureHandle, 'Tag', 'colorbar'));
        catch
        end
        set(handles.axes, 'Visible', 'on', 'Box', 'on', ...
            'XLim', [0, 1], 'YLim', [0, 1], ...
            'XScale', 'linear', 'YScale', 'linear', 'YDir', 'normal');
        xlabel(handles.axes, '');
        ylabel(handles.axes, '');
        title(handles.axes, '');
        if nargin > 0 && ~isempty(message)
            set(handles.statusText, 'String', message, ...
                'ForegroundColor', [0.25, 0.25, 0.25]);
        end
    end

    function value = onOff(condition)
        if condition, value = 'on'; else, value = 'off'; end
    end

    function updateDimensionControls()
        current = guidata(figureHandle);
        if current.variableIndex == 0
            return;
        end
        variableInfo = current.info.Variables(current.variableIndex);
        if isempty(variableInfo.Dimensions)
            dimensionNames = {};
        else
            dimensionNames = {variableInfo.Dimensions.Name};
        end
        popupNames = [{'(nessuna)'}, dimensionNames];
        set(handles.xPopup, 'String', popupNames, ...
            'Value', current.xDimension + 1, 'Enable', 'on');
        set(handles.yPopup, 'String', popupNames, ...
            'Value', current.yDimension + 1, 'Enable', 'on');
        set(handles.planePopup, 'Enable', 'on');

        current.fixedDimensions = setdiff( ...
            1:numel(dimensionNames), [current.xDimension, current.yDimension], 'stable');
        if current.cutDimension > 0 && ...
                ~any(current.fixedDimensions == current.cutDimension)
            current.cutDimension = 0;
            current.activePlane = '';
        end

        if current.cutDimension == 0
            set(handles.fixedPopup, 'String', {'(nessuna)'}, 'Value', 1, 'Enable', 'off');
            set(handles.cutModePopup, 'Enable', 'off');
            set(handles.applyCutButton, 'Enable', 'off');
        else
            cutLabel = dimensionControlLabel(variableInfo, current.cutDimension);
            set(handles.fixedPopup, 'String', {cutLabel}, ...
                'Value', 1, 'Enable', 'on');
            set(handles.cutModePopup, 'Enable', 'on');
            set(handles.applyCutButton, 'Enable', 'on');
        end

        current.scanDimensions = setdiff( ...
            current.fixedDimensions, current.cutDimension, 'stable');
        if isempty(current.scanDimensions)
            current.scanDimension = 0;
            set(handles.scanPopup, 'String', {'(nessuna)'}, ...
                'Value', 1, 'Enable', 'off');
        else
            if ~any(current.scanDimensions == current.scanDimension)
                current.scanDimension = current.scanDimensions(1);
            end
            scanLabels = cell(1, numel(current.scanDimensions));
            for scanIndex = 1:numel(current.scanDimensions)
                scanLabels{scanIndex} = dimensionControlLabel( ...
                    variableInfo, current.scanDimensions(scanIndex));
            end
            selectedScan = find( ...
                current.scanDimensions == current.scanDimension, 1);
            set(handles.scanPopup, 'String', scanLabels, ...
                'Value', selectedScan, 'Enable', 'on');
        end
        guidata(figureHandle, current);
        syncCutControls();
        syncScanControls();
    end

    function label = dimensionControlLabel(variableInfo, dimension)
        current = guidata(figureHandle);
        axisInfo = mcv.readAxis(current.filename, current.info, ...
            variableInfo.Dimensions(dimension), variableInfo.Size(dimension), variableInfo);
        if isempty(axisInfo.units)
            label = sprintf('%s (1..%d)', ...
                variableInfo.Dimensions(dimension).Name, variableInfo.Size(dimension));
        else
            label = sprintf('%s [%s] (1..%d)', ...
                variableInfo.Dimensions(dimension).Name, axisInfo.units, ...
                variableInfo.Size(dimension));
        end
    end

    function onAxesChanged(~, ~)
        stopPlayback();
        set(handles.planePopup, 'Value', 1);
        current = guidata(figureHandle);
        xDimension = get(handles.xPopup, 'Value') - 1;
        yDimension = get(handles.yPopup, 'Value') - 1;
        if xDimension == 0 && yDimension > 0
            xDimension = yDimension;
            yDimension = 0;
        elseif xDimension > 0 && yDimension == xDimension
            yDimension = 0;
        end
        current.xDimension = xDimension;
        current.yDimension = yDimension;
        current.cutDimension = 0;
        current.activePlane = '';
        guidata(figureHandle, current);
        updateDimensionControls();
        renderSelection();
    end

    function onPlaneChanged(source, ~)
        selection = get(source, 'Value');
        if selection == 1
            return;
        end
        stopPlayback();
        current = guidata(figureHandle);
        if current.variableIndex == 0
            return;
        end
        variableInfo = current.info.Variables(current.variableIndex);
        mapping = mcv.findSpatialDimensions(current.info, variableInfo);
        [dimensions, cutDimension, planeName] = ...
            mcv.planeDimensions(mapping, selection);
        if any(dimensions == 0) || dimensions(1) == dimensions(2)
            setStatus(sprintf('Il piano %s non e disponibile per questa variabile.', planeName), true);
            set(source, 'Value', 1);
            return;
        end
        current.xDimension = dimensions(1);
        current.yDimension = dimensions(2);
        current.cutDimension = cutDimension;
        current.activePlane = planeName;
        current.clickedPoint = [];
        guidata(figureHandle, current);
        updateDimensionControls();
        renderSelection();
    end

    function onFixedDimensionChanged(~, ~)
        stopPlayback();
        syncCutControls();
    end

    function onCutModeChanged(~, ~)
        stopPlayback();
        syncCutControls();
    end

    function onApplyCut(~, ~)
        onIndexEdited(handles.fixedEdit, []);
    end

    function stepCut(direction)
        stopPlayback();
        current = guidata(figureHandle);
        if current.cutDimension == 0, return; end
        dimension = current.cutDimension;
        maximum = double(current.info.Variables(current.variableIndex).Size(dimension));
        nextValue = max(1, min(maximum, ...
            current.indices(dimension) + direction));
        setCutIndex(nextValue);
    end

    function onScanDimensionChanged(source, ~)
        stopPlayback();
        current = guidata(figureHandle);
        if isempty(current.scanDimensions), return; end
        selected = min(get(source, 'Value'), numel(current.scanDimensions));
        current.scanDimension = current.scanDimensions(selected);
        guidata(figureHandle, current);
        syncScanControls();
        renderSelection();
    end

    function onScanSlid(source, ~)
        stopPlayback();
        setScanIndex(round(get(source, 'Value')));
    end

    function syncScanControls()
        current = guidata(figureHandle);
        if current.variableIndex == 0 || current.scanDimension == 0
            set(handles.scanLabel, 'String', 'Dimensione da scorrere');
            set(handles.scanSlider, 'Enable', 'off', ...
                'Min', 1, 'Max', 2, 'Value', 1);
            setPlaybackControls('off');
            return;
        end
        variableInfo = current.info.Variables(current.variableIndex);
        dimension = current.scanDimension;
        lengthCurrent = double(variableInfo.Size(dimension));
        value = current.indices(dimension);
        axisInfo = mcv.readAxis(current.filename, current.info, ...
            variableInfo.Dimensions(dimension), lengthCurrent, variableInfo);
        displayValue = mcv.formatAxisValue(axisInfo, value, [], 8);
        set(handles.scanLabel, 'String', sprintf( ...
            'Scorri %s: %d/%d', axisInfo.name, value, lengthCurrent), ...
            'TooltipString', sprintf('%s = %s %s', ...
            axisInfo.name, displayValue, axisInfo.units));
        if lengthCurrent > 1
            sliderStep = [1 / (lengthCurrent - 1), ...
                min(1, 10 / (lengthCurrent - 1))];
            set(handles.scanSlider, 'Enable', 'on', ...
                'Min', 1, 'Max', lengthCurrent, 'Value', value, ...
                'SliderStep', sliderStep);
            setPlaybackControls('on');
        else
            set(handles.scanSlider, 'Enable', 'off', ...
                'Min', 1, 'Max', 2, 'Value', 1);
            setPlaybackControls('off');
        end
    end

    function setScanIndex(value)
        current = guidata(figureHandle);
        if current.scanDimension == 0, return; end
        dimension = current.scanDimension;
        maximum = double(current.info.Variables(current.variableIndex).Size(dimension));
        current.indices(dimension) = max(1, min(value, maximum));
        guidata(figureHandle, current);
        syncScanControls();
        renderSelection();
    end

    function syncCutControls()
        current = guidata(figureHandle);
        if current.cutDimension == 0 || current.variableIndex == 0
            set(handles.fixedSlider, 'Enable', 'off', 'Min', 1, 'Max', 2, 'Value', 1);
            set(handles.fixedEdit, 'Enable', 'off', 'String', '1');
            set(handles.cutModePopup, 'Enable', 'off');
            set(handles.applyCutButton, 'Enable', 'off');
            set(handles.cutPreviousButton, 'Enable', 'off');
            set(handles.cutNextButton, 'Enable', 'off');
            set(handles.fixedLabel, 'String', 'Asse di taglio');
            set(handles.fixedValueText, 'String', '');
            return;
        end
        dimension = current.cutDimension;
        lengthCurrent = double(current.info.Variables(current.variableIndex).Size(dimension));
        value = current.indices(dimension);
        if lengthCurrent > 1
            sliderStep = [1 / (lengthCurrent - 1), min(1, 10 / (lengthCurrent - 1))];
            set(handles.fixedSlider, 'Enable', 'on', 'Min', 1, 'Max', lengthCurrent, ...
                'Value', value, 'SliderStep', sliderStep);
            set(handles.cutPreviousButton, 'Enable', onOff(value > 1));
            set(handles.cutNextButton, 'Enable', onOff(value < lengthCurrent));
        else
            set(handles.fixedSlider, 'Enable', 'off', 'Min', 1, 'Max', 2, 'Value', 1);
            set(handles.cutPreviousButton, 'Enable', 'off');
            set(handles.cutNextButton, 'Enable', 'off');
        end
        variableInfo = current.info.Variables(current.variableIndex);
        dimensionName = variableInfo.Dimensions(dimension).Name;
        if dimension == current.cutDimension && ~isempty(current.activePlane)
            set(handles.fixedLabel, 'String', sprintf( ...
                'Taglio %s: asse %s', current.activePlane, dimensionName));
        else
            set(handles.fixedLabel, 'String', sprintf( ...
                'Asse di taglio: %s', dimensionName));
        end
        axisInfo = mcv.readAxis(current.filename, current.info, ...
            variableInfo.Dimensions(dimension), lengthCurrent, variableInfo);
        coordinateMode = get(handles.cutModePopup, 'Value') == 2;
        if coordinateMode && ~isempty(axisInfo.values) && ...
                numel(axisInfo.values) >= value && isfinite(axisInfo.values(value))
            editValue = num2str(axisInfo.values(value), 10);
        else
            editValue = num2str(value);
        end
        set(handles.fixedEdit, 'Enable', 'on', 'String', editValue);
        if ~isempty(axisInfo.values)
            displayValue = mcv.formatAxisValue(axisInfo, value, [], 10);
            set(handles.fixedEdit, 'TooltipString', sprintf('%s = %s %s', ...
                axisInfo.name, displayValue, axisInfo.units));
            set(handles.fixedValueText, 'String', sprintf( ...
                'Slice %d/%d | %s %s', value, lengthCurrent, ...
                displayValue, axisInfo.units));
        else
            set(handles.fixedValueText, 'String', sprintf( ...
                'Slice %d/%d', value, lengthCurrent));
        end
    end

    function onIndexSlid(source, ~)
        stopPlayback();
        setCutIndex(round(get(source, 'Value')));
    end

    function onIndexEdited(source, ~)
        stopPlayback();
        value = str2double(get(source, 'String'));
        if ~isfinite(value)
            syncCutControls();
            return;
        end
        if get(handles.cutModePopup, 'Value') == 1
            setCutIndex(round(value));
            return;
        end
        current = guidata(figureHandle);
        dimension = current.cutDimension;
        variableInfo = current.info.Variables(current.variableIndex);
        axisInfo = mcv.readAxis(current.filename, current.info, ...
            variableInfo.Dimensions(dimension), variableInfo.Size(dimension), variableInfo);
        [nearestIndex, actualValue] = mcv.nearestCoordinateIndex( ...
            axisInfo.values, value);
        if isempty(nearestIndex)
            syncCutControls();
            return;
        end
        setCutIndex(nearestIndex);
        setStatus(sprintf('Coordinata richiesta %.10g; uso %s[%d] = %.10g %s.', ...
            value, axisInfo.name, nearestIndex, actualValue, axisInfo.units), false);
    end

    function setCutIndex(value)
        current = guidata(figureHandle);
        if current.cutDimension == 0
            return;
        end
        dimension = current.cutDimension;
        maximum = double(current.info.Variables(current.variableIndex).Size(dimension));
        current.indices(dimension) = max(1, min(value, maximum));
        guidata(figureHandle, current);
        syncCutControls();
        renderSelection();
    end

    function onLimitsModeChanged(source, ~)
        if get(source, 'Value')
            set(handles.minEdit, 'Enable', 'off');
            set(handles.maxEdit, 'Enable', 'off');
        else
            set(handles.minEdit, 'Enable', 'on');
            set(handles.maxEdit, 'Enable', 'on');
        end
        renderSelection();
    end

    function onDisplayChanged(~, ~)
        renderSelection();
    end

    function onAnimationSpeed(source, delay)
        for itemIndex = 1:numel(handles.speedItems)
            set(handles.speedItems{itemIndex}, 'Checked', 'off');
        end
        set(source, 'Checked', 'on');
        current = guidata(figureHandle);
        current.animationDelay = delay;
        guidata(figureHandle, current);
    end

    function onAnimationDirection(source, ~)
        current = guidata(figureHandle);
        if strcmp(get(source, 'Checked'), 'on')
            set(source, 'Checked', 'off');
            current.animationDirection = 1;
        else
            set(source, 'Checked', 'on');
            current.animationDirection = -1;
        end
        guidata(figureHandle, current);
    end

    function onToggleLoop(source, ~)
        current = guidata(figureHandle);
        current.animationLoop = toggleChecked(source);
        guidata(figureHandle, current);
    end

    function onToggleFollow(source, ~)
        current = guidata(figureHandle);
        current.followGrowingFile = toggleChecked(source);
        guidata(figureHandle, current);
    end

    function onRangeMode(source, mode)
        for itemIndex = 1:numel(handles.rangeItems)
            set(handles.rangeItems{itemIndex}, 'Checked', 'off');
        end
        set(source, 'Checked', 'on');
        current = guidata(figureHandle);
        current.rangeMode = mode;
        guidata(figureHandle, current);
        set(handles.autoLimits, 'Value', 1);
        set(handles.minEdit, 'Enable', 'off');
        set(handles.maxEdit, 'Enable', 'off');
        renderSelection();
    end

    function onHistogram(~, ~)
        current = guidata(figureHandle);
        if isempty(current.renderedData) || ~isnumeric(current.renderedData)
            setStatus('Nessun dato numerico da rappresentare.', true);
            return;
        end
        values = double(current.renderedData(isfinite(current.renderedData)));
        if isempty(values)
            setStatus('La slice non contiene valori finiti.', true);
            return;
        end
        histogramFigure = figure('Name', 'MCVIEW - Istogramma', ...
            'NumberTitle', 'off', 'Color', background, 'Units', 'normalized', ...
            'Position', [0.25, 0.22, 0.50, 0.50]);
        histogramAxes = axes('Parent', histogramFigure, 'Units', 'normalized', ...
            'Position', [0.12, 0.14, 0.82, 0.78]);
        [counts, centers] = hist(values, 50);
        bar(histogramAxes, centers, counts, 1);
        grid(histogramAxes, 'on');
        xlabel(histogramAxes, 'Valore');
        ylabel(histogramAxes, 'Frequenza');
        title(histogramAxes, 'Distribuzione della slice corrente');
    end

    function onToggleCoast(source, ~)
        setCoastVisibility(toggleChecked(source));
    end

    function onCoastCheckbox(source, ~)
        setCoastVisibility(get(source, 'Value') ~= 0);
    end

    function setCoastVisibility(enabled)
        set(handles.showCoast, 'Value', double(enabled));
        set(handles.coastItem, 'Checked', onOff(enabled));
        current = guidata(figureHandle);
        current.geoOptions.showCoast = enabled;
        guidata(figureHandle, current);
        renderSelection();
    end

    function onCoastColorChanged(source, ~)
        names = get(source, 'String');
        selected = get(source, 'Value');
        if ischar(names)
            name = strtrim(names(selected, :));
        else
            name = names{selected};
        end
        current = guidata(figureHandle);
        current.geoOptions.coastColor = mcv.coastlineColor(name);
        guidata(figureHandle, current);
        renderSelection();
    end

    function onToggleLongitudeWrap(source, ~)
        current = guidata(figureHandle);
        current.geoOptions.wrapLongitude = toggleChecked(source);
        guidata(figureHandle, current);
        renderSelection();
    end

    function onProjection(source, projection)
        set(handles.equirectangularItem, 'Checked', 'off');
        set(handles.mercatorItem, 'Checked', 'off');
        set(source, 'Checked', 'on');
        current = guidata(figureHandle);
        current.geoOptions.projection = projection;
        guidata(figureHandle, current);
        renderSelection();
    end

    function onPixelLimit(source, maximumPixels)
        for itemIndex = 1:numel(handles.pixelItems)
            set(handles.pixelItems{itemIndex}, 'Checked', 'off');
        end
        set(source, 'Checked', 'on');
        current = guidata(figureHandle);
        current.maxDisplayPixels = maximumPixels;
        guidata(figureHandle, current);
        renderSelection();
    end

    function onCacheLimit(source, megabytes)
        for itemIndex = 1:numel(handles.cacheItems)
            set(handles.cacheItems{itemIndex}, 'Checked', 'off');
        end
        set(source, 'Checked', 'on');
        current = guidata(figureHandle);
        current.sliceCacheMaxBytes = megabytes * 1024 * 1024;
        current = trimSliceCache(current);
        guidata(figureHandle, current);
    end

    function onClearCache(~, ~)
        current = guidata(figureHandle);
        current.sliceCacheKeys = {};
        current.sliceCacheValues = {};
        current.sliceCacheBytes = [];
        current.rangeCacheKeys = {};
        current.rangeCacheValues = {};
        guidata(figureHandle, current);
        setStatus('Cache svuotata.', false);
    end

    function onCancelOperation(~, ~)
        current = guidata(figureHandle);
        current.cancelRequested = true;
        guidata(figureHandle, current);
        setStatus('Annullamento richiesto...', false);
    end

    function current = trimSliceCache(current)
        while numel(current.sliceCacheKeys) > current.sliceCacheLimit || ...
                sum(current.sliceCacheBytes) > current.sliceCacheMaxBytes
            if isempty(current.sliceCacheKeys), break; end
            current.sliceCacheKeys(1) = [];
            current.sliceCacheValues(1) = [];
            current.sliceCacheBytes(1) = [];
        end
    end

    function enabled = toggleChecked(source)
        if strcmp(get(source, 'Checked'), 'on')
            set(source, 'Checked', 'off');
            enabled = false;
        else
            set(source, 'Checked', 'on');
            enabled = true;
        end
    end

    function setPlaybackControls(mode)
        set(handles.firstButton, 'Enable', mode);
        set(handles.previousButton, 'Enable', mode);
        set(handles.playButton, 'Enable', mode);
        set(handles.nextButton, 'Enable', mode);
        set(handles.lastButton, 'Enable', mode);
    end

    function moved = stepFrame(direction, allowWrap)
        if nargin < 2, allowWrap = true; end
        moved = false;
        current = guidata(figureHandle);
        if current.scanDimension == 0
            return;
        end
        dimension = current.scanDimension;
        maximum = double(current.info.Variables(current.variableIndex).Size(dimension));
        if ischar(direction) && strcmp(direction, 'first')
            nextValue = 1;
        elseif ischar(direction) && strcmp(direction, 'last')
            nextValue = maximum;
        else
            nextValue = current.indices(dimension) + direction;
            if nextValue > maximum
                if allowWrap, nextValue = 1; else, return; end
            end
            if nextValue < 1
                if allowWrap, nextValue = maximum; else, return; end
            end
        end
        setScanIndex(nextValue);
        moved = true;
    end

    function onPlay(~, ~)
        current = guidata(figureHandle);
        if current.isPlaying
            stopPlayback();
            return;
        end
        current.isPlaying = true;
        guidata(figureHandle, current);
        set(handles.playButton, 'String', 'Stop');
        while ishandle(figureHandle)
            current = guidata(figureHandle);
            if ~current.isPlaying
                break;
            end
            moved = stepFrame(current.animationDirection, false);
            if ~moved
                if current.followGrowingFile && current.animationDirection > 0
                    grew = refreshDataset(true);
                    if grew
                        stepFrame(1, false);
                    end
                elseif current.animationLoop
                    stepFrame(current.animationDirection, true);
                else
                    stopPlayback();
                end
            end
            drawnow();
            current = guidata(figureHandle);
            if current.followGrowingFile && ~moved
                pause(max(0.5, current.animationDelay));
            else
                pause(current.animationDelay);
            end
        end
        if ishandle(figureHandle)
            set(handles.playButton, 'String', 'Play');
        end
    end

    function stopPlayback()
        if ~ishandle(figureHandle)
            return;
        end
        current = guidata(figureHandle);
        current.isPlaying = false;
        guidata(figureHandle, current);
        set(handles.playButton, 'String', 'Play');
    end

    function grew = refreshDataset(fromFollow)
        if nargin < 1, fromFollow = false; end
        grew = false;
        current = guidata(figureHandle);
        if current.variableIndex == 0, return; end
        oldVariable = current.info.Variables(current.variableIndex);
        oldPath = mcv.variablePath(oldVariable);
        oldNames = {oldVariable.Dimensions.Name};
        oldXName = dimensionName(oldNames, current.xDimension);
        oldYName = dimensionName(oldNames, current.yDimension);
        oldCutName = dimensionName(oldNames, current.cutDimension);
        oldScanName = '';
        oldScanLength = 0;
        if current.scanDimension > 0
            oldScanDimension = current.scanDimension;
            oldScanName = oldNames{oldScanDimension};
            oldScanLength = oldVariable.Size(oldScanDimension);
        end
        try
            newInfo = mcv.readDatasetInfo(current.filename);
            newPaths = cell(1, numel(newInfo.Variables));
            for index = 1:numel(newInfo.Variables)
                newPaths{index} = mcv.variablePath(newInfo.Variables(index));
            end
            newVariableIndex = find(strcmp(newPaths, oldPath), 1);
            if isempty(newVariableIndex)
                error('mcview:VariableDisappeared', ...
                    'La variabile %s non e piu presente nel dataset.', oldPath);
            end
            newVariable = newInfo.Variables(newVariableIndex);
            newNames = {newVariable.Dimensions.Name};
            newIndices = ones(1, numel(newNames));
            for newDimension = 1:numel(newNames)
                oldDimension = find(strcmp(oldNames, newNames{newDimension}), 1);
                if ~isempty(oldDimension) && oldDimension <= numel(current.indices)
                    newIndices(newDimension) = min( ...
                        current.indices(oldDimension), newVariable.Size(newDimension));
                end
            end
            current.info = newInfo;
            current.variableIndex = newVariableIndex;
            current.indices = newIndices;
            current.xDimension = findDimension(newNames, oldXName);
            current.yDimension = findDimension(newNames, oldYName);
            current.cutDimension = findDimension(newNames, oldCutName);
            current.scanDimension = findDimension(newNames, oldScanName);
            current.sliceCacheKeys = {};
            current.sliceCacheValues = {};
            current.sliceCacheBytes = [];
            current.rangeCacheKeys = {};
            current.rangeCacheValues = {};
            if ~isempty(oldScanName)
                newScanDimension = findDimension(newNames, oldScanName);
                if newScanDimension > 0
                    grew = newVariable.Size(newScanDimension) > oldScanLength;
                end
            end
            guidata(figureHandle, current);
            rebuildVariableTree(newVariableIndex);
            updateDimensionControls();
            if ~fromFollow || grew
                renderSelection();
            end
            if ~fromFollow
                setStatus('Dataset riletto.', false);
            end
        catch exception
            if ~fromFollow
                setStatus(exception.message, true);
            end
        end
    end

    function name = dimensionName(names, index)
        if index > 0 && index <= numel(names)
            name = names{index};
        else
            name = '';
        end
    end

    function index = findDimension(names, name)
        if isempty(name)
            index = 0;
            return;
        end
        index = find(strcmp(names, name), 1);
        if isempty(index), index = 0; end
    end

    function renderSelection()
        current = guidata(figureHandle);
        if current.variableIndex == 0
            return;
        end
        variableInfo = current.info.Variables(current.variableIndex);
        setStatus(sprintf('Lettura di %s...', variableInfo.Name), false);
        drawnow();
        try
            cacheKey = sliceCacheKey(variableInfo, current);
            cacheMatch = find(strcmp(current.sliceCacheKeys, cacheKey), 1);
            if isempty(cacheMatch)
                [data, xCoordinate, yCoordinate, selection, axesInfo] = ...
                    mcv.readVariableSlice(current.filename, current.info, variableInfo, ...
                    current.xDimension, current.yDimension, current.indices);
                cacheValue = struct('data', data, 'x', xCoordinate, 'y', yCoordinate, ...
                    'selection', selection, 'axesInfo', axesInfo);
                current.sliceCacheKeys{end + 1} = cacheKey;
                current.sliceCacheValues{end + 1} = cacheValue;
                current.sliceCacheBytes(end + 1) = mcv.estimateBytes(cacheValue);
                current = trimSliceCache(current);
            else
                cacheValue = current.sliceCacheValues{cacheMatch};
                data = cacheValue.data;
                xCoordinate = cacheValue.x;
                yCoordinate = cacheValue.y;
                selection = cacheValue.selection;
                axesInfo = cacheValue.axesInfo;
            end
            rawData = data;
            [data, xCoordinate, yCoordinate, axesInfo, geoInfo] = ...
                mcv.prepareGeographicSlice(data, xCoordinate, yCoordinate, ...
                axesInfo, current.geoOptions);
            [data, xCoordinate, yCoordinate, sampling] = mcv.downsampleSlice( ...
                data, xCoordinate, yCoordinate, current.maxDisplayPixels);
            if sampling.wasDownsampled
                geoInfo.xOrder = geoInfo.xOrder(sampling.xIndices);
                geoInfo.yOrder = geoInfo.yOrder(sampling.yIndices);
                if geoInfo.axesSwapped
                    geoInfo.longitudeOrder = geoInfo.yOrder;
                    geoInfo.latitudeOrder = geoInfo.xOrder;
                else
                    geoInfo.longitudeOrder = geoInfo.xOrder;
                    geoInfo.latitudeOrder = geoInfo.yOrder;
                end
                if ~isvector(axesInfo.x.values)
                    axesInfo.x.values = axesInfo.x.values( ...
                        sampling.xIndices, sampling.yIndices);
                    axesInfo.x.plotValues = axesInfo.x.plotValues( ...
                        sampling.xIndices, sampling.yIndices);
                    axesInfo.y.values = axesInfo.y.values( ...
                        sampling.xIndices, sampling.yIndices);
                    axesInfo.y.plotValues = axesInfo.y.plotValues( ...
                        sampling.xIndices, sampling.yIndices);
                elseif current.xDimension > 0
                    axesInfo.x.values = axesInfo.x.values(sampling.xIndices);
                    axesInfo.x.plotValues = axesInfo.x.plotValues(sampling.xIndices);
                    if isfield(axesInfo.x, 'timeLabels') && ...
                            ~isempty(axesInfo.x.timeLabels)
                        axesInfo.x.timeLabels = ...
                            axesInfo.x.timeLabels(sampling.xIndices);
                    end
                    if current.yDimension > 0
                        axesInfo.y.values = axesInfo.y.values(sampling.yIndices);
                        axesInfo.y.plotValues = axesInfo.y.plotValues(sampling.yIndices);
                        if isfield(axesInfo.y, 'timeLabels') && ...
                                ~isempty(axesInfo.y.timeLabels)
                            axesInfo.y.timeLabels = ...
                                axesInfo.y.timeLabels(sampling.yIndices);
                        end
                    end
                end
            end
            updatedCacheKeys = current.sliceCacheKeys;
            updatedCacheValues = current.sliceCacheValues;
            updatedCacheBytes = current.sliceCacheBytes;
            current = guidata(figureHandle);
            current.sliceCacheKeys = updatedCacheKeys;
            current.sliceCacheValues = updatedCacheValues;
            current.sliceCacheBytes = updatedCacheBytes;
            current.renderedData = data;
            current.xCoordinate = xCoordinate;
            current.yCoordinate = yCoordinate;
            current.axesInfo = axesInfo;
            current.geoInfo = geoInfo;
            current.displaySampling = sampling;
            current.clickedPoint = [];
            current.clickedPointLabel = '';
            guidata(figureHandle, current);
            set(handles.profileButton, 'Enable', 'off');
            drawData(variableInfo, data, xCoordinate, yCoordinate, axesInfo);
            describeSelection(variableInfo, rawData, selection);
            setStatus('Pronto.', false);
        catch exception
            cla(handles.axes);
            set(handles.detailsText, 'String', '');
            setStatus(exception.message, true);
        end
    end

    function key = sliceCacheKey(variableInfo, current)
        key = sprintf('%s|x%d|y%d|i%s', mcv.variablePath(variableInfo), ...
            current.xDimension, current.yDimension, sprintf('_%d', current.indices));
    end

    function drawData(variableInfo, data, xCoordinate, yCoordinate, axesInfo)
        cla(handles.axes);
        if ~(isnumeric(data) || islogical(data))
            text(handles.axes, 0.5, 0.5, 'Variabile non numerica', ...
                'HorizontalAlignment', 'center');
            axis(handles.axes, 'off');
            return;
        end

        numericData = double(data);
        current = guidata(figureHandle);
        if isempty(numericData)
            text(handles.axes, 0.5, 0.5, 'Variabile vuota', ...
                'HorizontalAlignment', 'center');
            axis(handles.axes, 'off');
            return;
        end
        if current.xDimension == 0
            text(handles.axes, 0.5, 0.5, sprintf('%g', numericData(1)), ...
                'HorizontalAlignment', 'center', 'FontSize', 24, 'FontWeight', 'bold');
            axis(handles.axes, 'off');
        elseif current.yDimension == 0
            plot(handles.axes, xCoordinate, numericData(:), 'LineWidth', 1.25);
            grid(handles.axes, 'on');
            xlabel(handles.axes, mcv.axisLabel(axesInfo.x), 'Interpreter', 'none');
            ylabel(handles.axes, variableLabel(variableInfo), 'Interpreter', 'none');
            axis(handles.axes, 'tight');
            applyDateTicks(axesInfo.x, 'x');
        else
            displayData = numericData';
            useBilinear = get(handles.interpolationPopup, 'Value') == 2 && ...
                size(displayData, 1) > 1 && size(displayData, 2) > 1;
            curvilinear = ~isvector(xCoordinate) || ~isvector(yCoordinate);
            if useBilinear || curvilinear
                zeroPlane = zeros(size(displayData));
                plotX = xCoordinate;
                plotY = yCoordinate;
                if curvilinear
                    plotX = xCoordinate';
                    plotY = yCoordinate';
                end
                if useBilinear
                    faceColor = 'interp';
                else
                    faceColor = 'flat';
                end
                plotHandle = surf(handles.axes, plotX, plotY, ...
                    zeroPlane, displayData, ...
                    'EdgeColor', 'none', 'FaceColor', faceColor);
                view(handles.axes, 2);
                axis(handles.axes, 'tight');
            else
                plotHandle = imagesc(handles.axes, ...
                    xCoordinate, yCoordinate, displayData);
                set(handles.axes, 'YDir', 'normal');
            end
            set(plotHandle, 'ButtonDownFcn', @onPlotClicked);
            applyVerticalDirection();
            xlabel(handles.axes, mcv.axisLabel(axesInfo.x), 'Interpreter', 'none');
            ylabel(handles.axes, mcv.axisLabel(axesInfo.y), 'Interpreter', 'none');
            colorbarHandle = colorbar(handles.axes);
            mcv.setColorbarLabel(colorbarHandle, variableInfo.Name, ...
                mcv.getAttribute(variableInfo, 'units', ''));
            applyColorLimits(numericData);
            applyDateTicks(axesInfo.x, 'x');
            applyDateTicks(axesInfo.y, 'y');
            applyGeographicDecoration();
            applyVerticalDirection();
        end

        applyColormap();
    end

    function applyVerticalDirection()
        if get(handles.flipVertical, 'Value')
            set(handles.axes, 'YDir', 'reverse');
        else
            set(handles.axes, 'YDir', 'normal');
        end
    end

    function applyGeographicDecoration()
        current = guidata(figureHandle);
        if ~isfield(current.geoInfo, 'isGeographic') || ~current.geoInfo.isGeographic
            return;
        end
        grid(handles.axes, 'on');
        axis(handles.axes, 'tight');
        if strcmp(current.geoInfo.projection, 'mercator')
            latitude = current.geoInfo.latitudeValues;
            projected = current.geoInfo.projectedLatitude;
            if ~isempty(latitude) && isvector(latitude)
                tickIndices = unique(round(linspace(1, numel(latitude), min(7, numel(latitude)))));
                tickLabels = arrayfun(@(value) sprintf('%.4g', value), ...
                    latitude(tickIndices), 'UniformOutput', false);
                if current.geoInfo.axesSwapped
                    set(handles.axes, 'XTick', projected(tickIndices), ...
                        'XTickLabel', tickLabels);
                else
                    set(handles.axes, 'YTick', projected(tickIndices), ...
                        'YTickLabel', tickLabels);
                end
            end
        end
        if current.geoOptions.showCoast
            xLimits = xlim(handles.axes);
            yLimits = ylim(handles.axes);
            [coastLongitude, coastLatitude] = mcv.coastlineData( ...
                current.geoInfo.projection);
            if current.geoInfo.axesSwapped
                longitudeCoordinate = current.yCoordinate;
            else
                longitudeCoordinate = current.xCoordinate;
            end
            [coastX, coastY] = mcv.prepareCoastline( ...
                coastLongitude, coastLatitude, current.geoInfo, ...
                longitudeCoordinate, current.geoOptions.wrapLongitude);
            hold(handles.axes, 'on');
            coastHandle = plot(handles.axes, coastX, coastY, ...
                '-', 'Color', current.geoOptions.coastColor, 'LineWidth', 0.75);
            try
                set(coastHandle, 'HitTest', 'off');
            catch
            end
            hold(handles.axes, 'off');
            xlim(handles.axes, xLimits);
            ylim(handles.axes, yLimits);
        end
    end

    function label = variableLabel(variableInfo)
        longName = mcv.getAttribute(variableInfo, 'long_name', variableInfo.Name);
        units = mcv.getAttribute(variableInfo, 'units', '');
        if isnumeric(longName), longName = num2str(longName); end
        if isnumeric(units), units = num2str(units); end
        if isempty(units)
            label = char(longName);
        else
            label = sprintf('%s [%s]', char(longName), char(units));
        end
    end

    function applyDateTicks(axisInfo, axisName, targetAxes)
        if isempty(axisInfo) || ~axisInfo.isTime
            return;
        end
        if nargin < 3
            targetAxes = handles.axes;
        end
        if isfield(axisInfo, 'isNonGregorianTime') && ...
                axisInfo.isNonGregorianTime && ...
                isfield(axisInfo, 'timeLabels') && ...
                ~isempty(axisInfo.timeLabels)
            tickIndices = unique(round(linspace(1, ...
                numel(axisInfo.plotValues), min(7, numel(axisInfo.plotValues)))));
            tickValues = axisInfo.plotValues(tickIndices);
            tickLabels = axisInfo.timeLabels(tickIndices);
            if strcmpi(axisName, 'x')
                set(targetAxes, 'XTick', tickValues, 'XTickLabel', tickLabels);
            else
                set(targetAxes, 'YTick', tickValues, 'YTickLabel', tickLabels);
            end
            return;
        end
        try
            datetick(targetAxes, axisName, 'yyyy-mm-dd', 'keeplimits');
        catch
            % Il dato rimane correttamente posizionato in unita datenum.
        end
    end

    function applyColormap()
        maps = get(handles.colormapPopup, 'String');
        mapName = maps{get(handles.colormapPopup, 'Value')};
        if strcmp(mapName, 'divergente')
            map = mcv.divergingMap(256);
        else
            try
                map = feval(mapName, 256);
            catch
                map = jet(256);
            end
        end
        normalized = linspace(0, 1, size(map, 1));
        transform = get(handles.transformPopup, 'Value');
        if transform == 2
            lookup = normalized .^ 4;
        elseif transform == 3
            lookup = normalized .^ 0.25;
        elseif transform == 4
            limits = caxis(handles.axes);
            if limits(1) <= 0 || limits(2) <= 0
                error('mcview:InvalidLogRange', ...
                    'La trasformazione Log10 richiede un intervallo positivo.');
            end
            physical = limits(1) + diff(limits) .* normalized;
            lookup = (log10(physical) - log10(limits(1))) ./ ...
                (log10(limits(2)) - log10(limits(1)));
        else
            lookup = normalized;
        end
        indices = 1 + round((size(map, 1) - 1) .* lookup);
        map = map(indices, :);
        if get(handles.invertColors, 'Value')
            map = flipud(map);
        end
        try
            colormap(handles.axes, map);
        catch
            colormap(map);
        end
    end

    function applyColorLimits(data)
        finiteValues = data(isfinite(data));
        if isempty(finiteValues)
            return;
        end
        if get(handles.autoLimits, 'Value')
            current = guidata(figureHandle);
            referenceValues = finiteValues(:);
            if strcmp(current.rangeMode, 'slice')
                lower = min(referenceValues);
                upper = max(referenceValues);
            elseif strcmp(current.rangeMode, 'global-all')
                [limits, referenceValues] = cachedVariableRange('all');
                lower = limits(1);
                upper = limits(2);
            else
                [limits, referenceValues] = cachedVariableRange('fast');
                if strcmp(current.rangeMode, 'percentile')
                    lower = mcv.percentile(referenceValues, 2);
                    upper = mcv.percentile(referenceValues, 98);
                elseif strcmp(current.rangeMode, 'symmetric')
                    magnitude = max(abs(limits));
                    lower = -magnitude;
                    upper = magnitude;
                else
                    lower = limits(1);
                    upper = limits(2);
                end
            end
            if get(handles.transformPopup, 'Value') == 4 && lower <= 0
                positiveValues = referenceValues(referenceValues > 0);
                if isempty(positiveValues)
                    error('mcview:InvalidLogData', ...
                        'La trasformazione Log10 richiede valori positivi.');
                end
                lower = min(positiveValues);
            end
            if lower == upper
                padding = max(1, abs(lower) * 0.01);
                lower = lower - padding;
                upper = upper + padding;
            end
            set(handles.minEdit, 'String', num2str(lower, 8));
            set(handles.maxEdit, 'String', num2str(upper, 8));
        else
            lower = str2double(get(handles.minEdit, 'String'));
            upper = str2double(get(handles.maxEdit, 'String'));
            if ~isfinite(lower) || ~isfinite(upper) || lower >= upper
                error('mcview:InvalidColorLimits', ...
                    'I limiti colore devono essere numeri finiti con min < max.');
            end
        end
        caxis(handles.axes, [lower, upper]);
    end

    function [limits, values] = cachedVariableRange(method)
        current = guidata(figureHandle);
        variableInfo = current.info.Variables(current.variableIndex);
        key = sprintf('%s|%s', mcv.variablePath(variableInfo), method);
        match = find(strcmp(current.rangeCacheKeys, key), 1);
        if isempty(match)
            setStatus(sprintf('Calcolo intervallo %s...', method), false);
            drawnow();
            current.cancelRequested = false;
            guidata(figureHandle, current);
            [limits, values] = mcv.computeVariableRange( ...
                current.filename, variableInfo, method, @rangeProgress);
            current = guidata(figureHandle);
            current.cancelRequested = false;
            current.rangeCacheKeys{end + 1} = key;
            current.rangeCacheValues{end + 1} = ...
                struct('limits', limits, 'values', values);
            guidata(figureHandle, current);
        else
            cached = current.rangeCacheValues{match};
            limits = cached.limits;
            values = cached.values;
        end
        if any(~isfinite(limits))
            error('mcview:NoFiniteRange', ...
                'Impossibile calcolare un intervallo finito per la variabile.');
        end
    end

    function keepGoing = rangeProgress(position, total)
        current = guidata(figureHandle);
        setStatus(sprintf('Scansione range: %d/%d...', position, total), false);
        drawnow();
        current = guidata(figureHandle);
        keepGoing = ~current.cancelRequested;
    end

    function describeSelection(variableInfo, data, selection)
        if isnumeric(data) || islogical(data)
            finiteValues = double(data(isfinite(data)));
            if isempty(finiteValues)
                rangeText = 'Statistiche: nessun valore finito';
            else
                rangeText = sprintf('Min: %.6g    Max: %.6g    Media: %.6g', ...
                    min(finiteValues), max(finiteValues), mean(finiteValues));
            end
        else
            rangeText = 'Statistiche: variabile non numerica';
        end
        typeText = sprintf('Tipo: %s', variableInfo.Datatype);
        if isempty(selection.start)
            sliceText = 'Selezione: scalare';
        else
            sliceText = sprintf('Start: [%s]    Count: [%s]', ...
                num2str(selection.start), num2str(selection.count));
        end
        frameText = currentFrameDescription();
        detailLines = {typeText; rangeText; sliceText};
        if ~isempty(frameText)
            detailLines{end + 1, 1} = frameText;
        end
        set(handles.detailsText, 'String', detailLines);
    end

    function textValue = currentFrameDescription()
        textValue = '';
        current = guidata(figureHandle);
        if current.scanDimension == 0, return; end
        dimension = current.scanDimension;
        variableInfo = current.info.Variables(current.variableIndex);
        axisInfo = mcv.readAxis(current.filename, current.info, ...
            variableInfo.Dimensions(dimension), variableInfo.Size(dimension), variableInfo);
        index = current.indices(dimension);
        value = mcv.formatAxisValue(axisInfo, index, [], 8);
        textValue = sprintf('Frame: %s[%d] = %s %s', ...
            axisInfo.name, index, value, axisInfo.units);
    end

    function onPlotClicked(~, ~)
        current = guidata(figureHandle);
        if isempty(current.renderedData) || current.yDimension == 0
            return;
        end
        point = get(handles.axes, 'CurrentPoint');
        if isvector(current.xCoordinate) && isvector(current.yCoordinate)
            [~, xIndex] = min(abs(current.xCoordinate - point(1, 1)));
            [~, yIndex] = min(abs(current.yCoordinate - point(1, 2)));
        else
            distance = (double(current.xCoordinate) - point(1, 1)) .^ 2 + ...
                (double(current.yCoordinate) - point(1, 2)) .^ 2;
            [~, linearIndex] = min(distance(:));
            [xIndex, yIndex] = ind2sub(size(distance), linearIndex);
        end
        if isempty(xIndex) || isempty(yIndex)
            return;
        end
        sourceXIndex = xIndex;
        if isfield(current.geoInfo, 'xOrder') && ...
                numel(current.geoInfo.xOrder) >= xIndex
            sourceXIndex = current.geoInfo.xOrder(xIndex);
        end
        sourceYIndex = yIndex;
        if isfield(current.geoInfo, 'yOrder') && ...
                numel(current.geoInfo.yOrder) >= yIndex
            sourceYIndex = current.geoInfo.yOrder(yIndex);
        end
        current.clickedPoint = [sourceXIndex, sourceYIndex];
        if current.scanDimension == 0
            set(handles.profileButton, 'Enable', 'off');
        else
            set(handles.profileButton, 'Enable', 'on');
        end
        value = double(current.renderedData(xIndex, yIndex));
        xText = coordinateText(current.axesInfo.x, xIndex, yIndex);
        yText = coordinateText(current.axesInfo.y, xIndex, yIndex);
        current.clickedPointLabel = sprintf('%s; %s', xText, yText);
        guidata(figureHandle, current);
        setStatus(sprintf('%s; %s; valore = %.10g', xText, yText, value), false);
    end

    function textValue = coordinateText(axisInfo, index, secondIndex)
        valueText = mcv.formatAxisValue(axisInfo, index, secondIndex, 10);
        if isempty(axisInfo.units)
            textValue = sprintf('%s = %s', axisInfo.name, valueText);
        else
            textValue = sprintf('%s = %s %s', axisInfo.name, valueText, axisInfo.units);
        end
    end

    function onProfile(~, ~)
        current = guidata(figureHandle);
        if isempty(current.clickedPoint) || current.scanDimension == 0
            setStatus('Seleziona prima un punto sulla mappa.', true);
            return;
        end
        scanDimension = current.scanDimension;
        indices = current.indices;
        indices(current.xDimension) = current.clickedPoint(1);
        indices(current.yDimension) = current.clickedPoint(2);
        variableInfo = current.info.Variables(current.variableIndex);
        try
            [profileData, coordinate, ~, ~, profileAxesInfo] = mcv.readVariableSlice( ...
                current.filename, current.info, variableInfo, scanDimension, 0, indices);
            current = guidata(figureHandle);
            axisName = profileAxesInfo.x.name;
            if isempty(current.profileFigure) || ~ishandle(current.profileFigure)
                [current.profileFigure, current.profileAxes] = createProfileWindow();
                current.profiles = {};
                current.profileAxisName = axisName;
            elseif ~strcmp(current.profileAxisName, axisName)
                cla(current.profileAxes);
                current.profiles = {};
                current.profileAxisName = axisName;
            end

            pointLabel = current.clickedPointLabel;
            profileLabel = sprintf('%s @ %s', variableInfo.Name, pointLabel);
            hold(current.profileAxes, 'on');
            lineHandle = plot(current.profileAxes, coordinate, double(profileData(:)), ...
                'LineWidth', 1.4);
            profile = struct('axisInfo', profileAxesInfo.x, ...
                'values', double(profileData(:)), 'variable', variableInfo.Name, ...
                'label', profileLabel, 'line', lineHandle);
            current.profiles{end + 1} = profile;
            if numel(current.profiles) > 5
                oldest = current.profiles{1};
                if ishandle(oldest.line), delete(oldest.line); end
                current.profiles(1) = [];
            end
            guidata(figureHandle, current);

            grid(current.profileAxes, 'on');
            xlabel(current.profileAxes, mcv.axisLabel(profileAxesInfo.x), ...
                'Interpreter', 'none');
            ylabel(current.profileAxes, 'Valore', 'Interpreter', 'none');
            title(current.profileAxes, sprintf('Profili lungo %s', axisName), ...
                'Interpreter', 'none');
            labels = cellfun(@(item) item.label, current.profiles, ...
                'UniformOutput', false);
            try
                legend(current.profileAxes, labels, 'Interpreter', 'none', ...
                    'Location', 'best');
            catch
                legend(current.profileAxes, labels);
            end
            if profileAxesInfo.x.isTime
                applyDateTicks(profileAxesInfo.x, 'x', current.profileAxes);
            end
            figure(current.profileFigure);
        catch exception
            setStatus(exception.message, true);
        end
    end

    function [profileFigure, profileAxes] = createProfileWindow()
        profileFigure = figure('Name', 'MCVIEW - Profili 1D', ...
            'NumberTitle', 'off', 'Color', background, 'Units', 'normalized', ...
            'Position', [0.22, 0.20, 0.58, 0.56]);
        profileAxes = axes('Parent', profileFigure, 'Units', 'normalized', ...
            'Position', [0.11, 0.20, 0.84, 0.72]);
        uicontrol(profileFigure, 'Style', 'checkbox', 'String', 'Log X', ...
            'Units', 'normalized', 'Position', [0.05, 0.05, 0.10, 0.07], ...
            'BackgroundColor', background, ...
            'Callback', @(source, ~) setProfileScale('XScale', source));
        uicontrol(profileFigure, 'Style', 'checkbox', 'String', 'Log Y', ...
            'Units', 'normalized', 'Position', [0.16, 0.05, 0.10, 0.07], ...
            'BackgroundColor', background, ...
            'Callback', @(source, ~) setProfileScale('YScale', source));
        uicontrol(profileFigure, 'Style', 'pushbutton', 'String', 'Pulisci', ...
            'Units', 'normalized', 'Position', [0.58, 0.05, 0.14, 0.07], ...
            'Callback', @clearProfiles);
        uicontrol(profileFigure, 'Style', 'pushbutton', 'String', 'Esporta CSV...', ...
            'Units', 'normalized', 'Position', [0.76, 0.05, 0.19, 0.07], ...
            'Callback', @exportProfiles);
    end

    function setProfileScale(propertyName, source)
        current = guidata(figureHandle);
        if isempty(current.profileAxes) || ~ishandle(current.profileAxes), return; end
        if get(source, 'Value')
            value = 'log';
        else
            value = 'linear';
        end
        set(current.profileAxes, propertyName, value);
    end

    function clearProfiles(~, ~)
        current = guidata(figureHandle);
        if ~isempty(current.profileAxes) && ishandle(current.profileAxes)
            cla(current.profileAxes);
        end
        current.profiles = {};
        guidata(figureHandle, current);
    end

    function exportProfiles(~, ~)
        current = guidata(figureHandle);
        if isempty(current.profiles)
            setStatus('Non ci sono profili da esportare.', true);
            return;
        end
        [name, folder] = uiputfile('*.csv', 'Esporta profili CSV', ...
            'mcview_profiles.csv');
        if isequal(name, 0), return; end
        filename = fullfile(folder, name);
        fileId = fopen(filename, 'w');
        if fileId < 0
            setStatus(sprintf('Impossibile scrivere %s.', filename), true);
            return;
        end
        cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
        fprintf(fileId, 'profile,variable,axis,axis_value,value\n');
        for profileIndex = 1:numel(current.profiles)
            profile = current.profiles{profileIndex};
            safeLabel = strrep(profile.label, '"', '""');
            safeVariable = strrep(profile.variable, '"', '""');
            for row = 1:numel(profile.values)
                fprintf(fileId, '"%s","%s","%s",%.15g,%.15g\n', ...
                    safeLabel, safeVariable, profile.axisInfo.name, ...
                    profile.axisInfo.values(row), profile.values(row));
            end
        end
        setStatus(sprintf('Profili esportati in %s.', filename), false);
    end

    function onCompare(~, ~)
        current = guidata(figureHandle);
        if current.variableIndex == 0 || current.xDimension == 0
            setStatus('Il confronto richiede almeno una dimensione visualizzata.', true);
            return;
        end
        variables = current.info.Variables;
        primaryInfo = variables(current.variableIndex);
        candidateIndices = [];
        for variableIndex = 1:numel(variables)
            if variableIndex == current.variableIndex, continue; end
            try
                mcv.matchSliceDimensions(primaryInfo, variables(variableIndex), ...
                    current.xDimension, current.yDimension, current.indices, ...
                    current.info);
                candidateIndices(end + 1) = variableIndex; %#ok<AGROW>
            catch
            end
        end
        if isempty(candidateIndices)
            setStatus('Non ci sono altre variabili compatibili con questa vista.', true);
            return;
        end
        candidateNames = cell(1, numel(candidateIndices));
        for index = 1:numel(candidateIndices)
            variable = variables(candidateIndices(index));
            if isfield(variable, 'DisplayName')
                candidateNames{index} = variable.DisplayName;
            else
                candidateNames{index} = variable.Name;
            end
        end
        [chosen, accepted] = listdlg('ListString', candidateNames, ...
            'SelectionMode', 'single', 'ListSize', [360, 300], ...
            'Name', 'Confronta variabili', ...
            'PromptString', 'Scegli la variabile di confronto:');
        if ~accepted || isempty(chosen), return; end
        operations = {'Affianca', 'Differenza', 'Rapporto'};
        [operationIndex, accepted] = listdlg('ListString', operations, ...
            'SelectionMode', 'single', 'ListSize', [260, 130], ...
            'Name', 'Operazione', 'PromptString', 'Scegli l''operazione:');
        if ~accepted || isempty(operationIndex), return; end
        operationKeys = {'side', 'difference', 'ratio'};

        secondaryInfo = variables(candidateIndices(chosen));
        try
            [primaryRead, secondaryRead] = mcv.readComparisonSlices( ...
                current.filename, current.info, primaryInfo, secondaryInfo, ...
                current.xDimension, current.yDimension, current.indices);
            primarySlice = comparisonSlice(primaryInfo, primaryRead.data, ...
                primaryRead.x, primaryRead.y, primaryRead.axesInfo);
            secondarySlice = comparisonSlice(secondaryInfo, secondaryRead.data, ...
                secondaryRead.x, secondaryRead.y, secondaryRead.axesInfo);
            mcv.showComparison(primarySlice, secondarySlice, ...
                operationKeys{operationIndex});
        catch exception
            setStatus(exception.message, true);
        end
    end

    function slice = comparisonSlice(variableInfo, data, x, y, axesInfo)
        slice = struct();
        slice.data = data;
        slice.x = x;
        slice.y = y;
        slice.axesInfo = axesInfo;
        if isfield(variableInfo, 'DisplayName')
            slice.title = variableInfo.DisplayName;
        else
            slice.title = variableInfo.Name;
        end
        slice.variableName = variableInfo.Name;
        units = mcv.getAttribute(variableInfo, 'units', '');
        if isnumeric(units), units = num2str(units); end
        slice.units = char(units);
    end

    function onExportMenu(~, ~)
        options = {'Vista corrente in PNG', 'Variabile nel workspace'};
        [choice, accepted] = listdlg('ListString', options, ...
            'SelectionMode', 'single', 'ListSize', [300, 100], ...
            'Name', 'Esporta', 'PromptString', 'Scegli cosa esportare:');
        if ~accepted || isempty(choice), return; end
        if choice == 1
            onExportImage([], []);
        else
            onExportWorkspace();
        end
    end

    function onExportWorkspace()
        current = guidata(figureHandle);
        if current.variableIndex == 0
            setStatus('Seleziona prima una variabile da esportare.', true);
            return;
        end
        variableInfo = current.info.Variables(current.variableIndex);
        dimensionCount = numel(variableInfo.Dimensions);
        if dimensionCount >= 3
            modeNames = { ...
                'Slice corrente a risoluzione nativa', ...
                'Snapshot selezionati lungo una dimensione', ...
                'Variabile completa'};
            modeKeys = {'slice', 'snapshots', 'full'};
        else
            modeNames = {'Slice corrente a risoluzione nativa', ...
                'Variabile completa'};
            modeKeys = {'slice', 'full'};
        end
        [modeIndex, accepted] = listdlg('ListString', modeNames, ...
            'SelectionMode', 'single', 'ListSize', [390, 145], ...
            'Name', 'Esporta nel workspace', ...
            'PromptString', 'Scegli la porzione da importare:');
        if ~accepted || isempty(modeIndex), return; end
        mode = modeKeys{modeIndex};

        snapshotDimension = 0;
        snapshotIndices = [];
        if strcmp(mode, 'snapshots')
            [snapshotDimension, snapshotIndices, accepted] = ...
                chooseWorkspaceSnapshots(current, variableInfo);
            if ~accepted, return; end
            elementCount = prod(double(variableInfo.Size)) / ...
                double(variableInfo.Size(snapshotDimension)) * ...
                numel(snapshotIndices);
            outputSize = double(variableInfo.Size(:))';
            outputSize(snapshotDimension) = numel(snapshotIndices);
            if ~confirmWorkspaceRead( ...
                    sprintf('%d snapshot', numel(snapshotIndices)), ...
                    outputSize, elementCount)
                return;
            end
        elseif strcmp(mode, 'full')
            outputSize = double(variableInfo.Size(:))';
            if isempty(outputSize), outputSize = 1; end
            if ~confirmWorkspaceRead('variabile completa', ...
                    outputSize, prod(outputSize))
                return;
            end
        end

        defaultName = mcv.workspaceVariableName(mcv.variablePath(variableInfo));
        [workspaceName, metadataName, accepted] = ...
            chooseWorkspaceNames(defaultName);
        if ~accepted, return; end

        setStatus(sprintf('Importazione di %s nel workspace...', ...
            mcv.variablePath(variableInfo)), false);
        drawnow();
        try
            metadata = workspaceMetadata(current, variableInfo, mode);
            if strcmp(mode, 'slice')
                [data, xCoordinate, yCoordinate, selection, axesInfo] = ...
                    mcv.readVariableSlice(current.filename, current.info, ...
                    variableInfo, current.xDimension, current.yDimension, ...
                    current.indices);
                selection.mode = 'slice';
                selection.xDimension = current.xDimension;
                selection.yDimension = current.yDimension;
                metadata.selection = selection;
                metadata.xCoordinate = xCoordinate;
                metadata.yCoordinate = yCoordinate;
                metadata.axesInfo = axesInfo;
            elseif strcmp(mode, 'snapshots')
                [data, selection] = mcv.readVariableSnapshots( ...
                    current.filename, variableInfo, ...
                    snapshotDimension, snapshotIndices);
                metadata.selection = selection;
                axisInfo = mcv.readAxis(current.filename, current.info, ...
                    variableInfo.Dimensions(snapshotDimension), ...
                    variableInfo.Size(snapshotDimension), variableInfo);
                metadata.snapshotAxis = axisInfo.name;
                metadata.snapshotUnits = axisInfo.units;
                metadata.snapshotCoordinates = ...
                    axisInfo.values(snapshotIndices);
                if axisInfo.isTime
                    metadata.snapshotLabels = ...
                        axisInfo.timeLabels(snapshotIndices);
                end
            else
                rawData = mcv.readVariableData( ...
                    current.filename, variableInfo, [], []);
                data = mcv.applyDataConventions(rawData, variableInfo);
                metadata.selection = struct('mode', 'full', ...
                    'originalSize', double(variableInfo.Size(:))');
            end
            metadata.exportedSize = size(data);
            assignin('base', workspaceName, data);
            assignin('base', metadataName, metadata);
            setStatus(sprintf( ...
                'Esportati %s (%s) e %s nel workspace.', ...
                workspaceName, formatByteCount(mcv.estimateBytes(data)), ...
                metadataName), false);
        catch exception
            setStatus(exception.message, true);
        end
    end

    function [dimension, indices, accepted] = ...
            chooseWorkspaceSnapshots(current, variableInfo)
        dimensionCount = numel(variableInfo.Dimensions);
        labels = cell(1, dimensionCount);
        for dimensionIndex = 1:dimensionCount
            labels{dimensionIndex} = sprintf('%d: %s (%d elementi)', ...
                dimensionIndex, variableInfo.Dimensions(dimensionIndex).Name, ...
                variableInfo.Size(dimensionIndex));
        end
        initialDimension = current.scanDimension;
        if initialDimension == 0
            dimensionNames = {variableInfo.Dimensions.Name};
            isTimeName = cellfun(@(name) any(strcmpi( ...
                name, {'time', 't', 'record'})), dimensionNames);
            initialDimension = find(isTimeName, 1);
        end
        if isempty(initialDimension) || initialDimension == 0
            initialDimension = dimensionCount;
        end
        [dimension, accepted] = listdlg('ListString', labels, ...
            'SelectionMode', 'single', 'InitialValue', initialDimension, ...
            'ListSize', [360, 180], 'Name', 'Dimensione snapshot', ...
            'PromptString', 'Scegli la dimensione degli snapshot:');
        if ~accepted || isempty(dimension)
            dimension = 0;
            indices = [];
            accepted = false;
            return;
        end
        maximum = double(variableInfo.Size(dimension));
        currentIndex = 1;
        if numel(current.indices) >= dimension
            currentIndex = current.indices(dimension);
        end
        prompt = sprintf([ ...
            'Indici lungo %s (1..%d). Esempi: 1, 1:10, ', ...
            '[1 5 20], all'], ...
            variableInfo.Dimensions(dimension).Name, maximum);
        answer = inputdlg(prompt, 'Snapshot da importare', 1, ...
            {num2str(currentIndex)});
        if isempty(answer)
            indices = [];
            accepted = false;
            return;
        end
        try
            indices = mcv.parseIndexSelection(answer{1}, maximum);
            accepted = true;
        catch exception
            setStatus(exception.message, true);
            indices = [];
            accepted = false;
        end
    end

    function accepted = confirmWorkspaceRead(description, outputSize, elementCount)
        estimatedBytes = double(elementCount) * 8;
        question = sprintf([ ...
            'Importare %s?\n\nDimensioni: %s\nMemoria dati stimata: %s\n', ...
            'Durante la lettura il picco puo essere maggiore.'], ...
            description, formatDimensions(outputSize), ...
            formatByteCount(estimatedBytes));
        answer = questdlg(question, 'Conferma importazione', ...
            'Importa', 'Annulla', 'Annulla');
        accepted = strcmp(answer, 'Importa');
    end

    function [workspaceName, metadataName, accepted] = ...
            chooseWorkspaceNames(defaultName)
        answer = inputdlg('Nome della variabile nel workspace:', ...
            'Esporta nel workspace', 1, {defaultName});
        if isempty(answer)
            workspaceName = '';
            metadataName = '';
            accepted = false;
            return;
        end
        workspaceName = mcv.workspaceVariableName(answer{1});
        maximumLength = namelengthmax();
        metadataBase = workspaceName;
        if numel(metadataBase) > maximumLength - 5
            metadataBase = metadataBase(1:maximumLength - 5);
        end
        metadataName = [metadataBase, '_info'];
        dataExists = evalin('base', sprintf( ...
            'exist(''%s'', ''var'')', workspaceName)) ~= 0;
        metadataExists = evalin('base', sprintf( ...
            'exist(''%s'', ''var'')', metadataName)) ~= 0;
        if dataExists || metadataExists
            overwrite = questdlg(sprintf([ ...
                '%s o %s esistono gia nel workspace. Sovrascriverli?'], ...
                workspaceName, metadataName), ...
                'Variabile esistente', 'Sovrascrivi', 'Annulla', 'Annulla');
            if ~strcmp(overwrite, 'Sovrascrivi')
                accepted = false;
                return;
            end
        end
        accepted = true;
    end

    function metadata = workspaceMetadata(current, variableInfo, mode)
        metadata = struct();
        metadata.source = current.filename;
        metadata.path = mcv.variablePath(variableInfo);
        metadata.name = variableInfo.Name;
        metadata.longName = mcv.getAttribute( ...
            variableInfo, 'long_name', variableInfo.Name);
        metadata.units = mcv.getAttribute(variableInfo, 'units', '');
        metadata.exportMode = mode;
        metadata.originalSize = double(variableInfo.Size(:))';
        if isempty(variableInfo.Dimensions)
            metadata.dimensionNames = {};
        else
            metadata.dimensionNames = {variableInfo.Dimensions.Name};
        end
        if isfield(variableInfo, 'Attributes')
            metadata.attributes = variableInfo.Attributes;
        else
            metadata.attributes = struct([]);
        end
    end

    function textValue = formatDimensions(dimensions)
        if isempty(dimensions)
            textValue = 'scalare';
            return;
        end
        parts = arrayfun(@(value) sprintf('%d', value), ...
            dimensions, 'UniformOutput', false);
        textValue = strjoin(parts, ' x ');
    end

    function textValue = formatByteCount(bytes)
        if bytes >= 1024 ^ 3
            textValue = sprintf('%.2f GB', bytes / 1024 ^ 3);
        elseif bytes >= 1024 ^ 2
            textValue = sprintf('%.2f MB', bytes / 1024 ^ 2);
        elseif bytes >= 1024
            textValue = sprintf('%.2f kB', bytes / 1024);
        else
            textValue = sprintf('%d byte', round(bytes));
        end
    end

    function onExportImage(~, ~)
        [name, folder] = uiputfile('*.png', 'Esporta vista PNG', 'mcview.png');
        if isequal(name, 0), return; end
        filename = fullfile(folder, name);
        try
            print(figureHandle, filename, '-dpng', '-r150');
            setStatus(sprintf('Immagine esportata in %s.', filename), false);
        catch exception
            setStatus(exception.message, true);
        end
    end

    function onClose(~, ~)
        stopPlayback();
        current = guidata(figureHandle);
        if ~isempty(current.profileFigure) && ishandle(current.profileFigure)
            delete(current.profileFigure);
        end
        delete(figureHandle);
    end

    function setStatus(message, isError)
        set(handles.statusText, 'String', message);
        if isError
            set(handles.statusText, 'ForegroundColor', errorColor);
        else
            set(handles.statusText, 'ForegroundColor', [0.25, 0.25, 0.25]);
        end
        drawnow();
    end
end
