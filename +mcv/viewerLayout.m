function layout = viewerLayout()
%VIEWERLAYOUT Coordinate normalizzate della finestra principale.
%   Un'unica griglia evita disallineamenti quando vengono aggiunti controlli.

    sidebarX = 0.015;
    sidebarWidth = 0.255;
    mainX = 0.300;
    mainWidth = 0.685;

    layout.openButton = [sidebarX, 0.935, 0.145, 0.045];
    layout.attributesButton = [0.165, 0.935, 0.105, 0.045];
    layout.fileText = [sidebarX, 0.892, sidebarWidth, 0.032];
    layout.variablesLabel = [sidebarX, 0.852, sidebarWidth, 0.028];
    layout.variableList = [sidebarX, 0.635, sidebarWidth, 0.212];

    layout.xLabel = [sidebarX, 0.596, 0.055, 0.028];
    layout.xPopup = [0.075, 0.591, 0.195, 0.038];
    layout.yLabel = [sidebarX, 0.552, 0.055, 0.028];
    layout.yPopup = [0.075, 0.547, 0.195, 0.038];
    layout.planePopup = [sidebarX, 0.504, sidebarWidth, 0.036];

    layout.fixedLabel = [sidebarX, 0.468, sidebarWidth, 0.028];
    layout.fixedPopup = [sidebarX, 0.431, sidebarWidth, 0.033];
    layout.cutValueLabel = [sidebarX, 0.398, 0.045, 0.026];
    layout.cutModePopup = [0.060, 0.394, 0.090, 0.033];
    layout.fixedEdit = [0.155, 0.394, 0.065, 0.033];
    layout.applyCutButton = [0.225, 0.394, 0.045, 0.033];
    layout.cutPreviousButton = [sidebarX, 0.365, 0.035, 0.025];
    layout.fixedSlider = [0.055, 0.367, 0.175, 0.021];
    layout.cutNextButton = [0.235, 0.365, 0.035, 0.025];
    layout.fixedValueText = [sidebarX, 0.345, sidebarWidth, 0.020];

    layout.scanLabel = [sidebarX, 0.313, sidebarWidth, 0.026];
    layout.scanPopup = [sidebarX, 0.278, sidebarWidth, 0.032];
    layout.scanSlider = [sidebarX, 0.253, sidebarWidth, 0.019];

    layout.firstButton = [sidebarX, 0.214, 0.045, 0.033];
    layout.previousButton = [0.065, 0.214, 0.045, 0.033];
    layout.playButton = [0.115, 0.214, 0.055, 0.033];
    layout.nextButton = [0.175, 0.214, 0.045, 0.033];
    layout.lastButton = [0.225, 0.214, 0.045, 0.033];

    layout.colormapLabel = [sidebarX, 0.177, 0.095, 0.026];
    layout.colormapPopup = [0.115, 0.172, 0.155, 0.036];
    layout.autoLimits = [sidebarX, 0.135, sidebarWidth, 0.033];
    layout.minLabel = [sidebarX, 0.099, 0.030, 0.026];
    layout.minEdit = [0.045, 0.094, 0.085, 0.036];
    layout.maxLabel = [0.145, 0.099, 0.035, 0.026];
    layout.maxEdit = [0.180, 0.094, 0.090, 0.036];
    layout.statusText = [sidebarX, 0.012, sidebarWidth, 0.070];

    layout.transformLabel = [mainX, 0.946, 0.082, 0.026];
    layout.transformPopup = [0.382, 0.940, 0.120, 0.038];
    layout.interpolationPopup = [0.510, 0.940, 0.095, 0.038];
    layout.invertColors = [0.612, 0.941, 0.100, 0.035];
    layout.flipVertical = [0.715, 0.941, 0.075, 0.035];
    layout.profileButton = [0.795, 0.940, 0.060, 0.038];
    layout.compareButton = [0.860, 0.940, 0.060, 0.038];
    layout.exportButton = [0.925, 0.940, 0.060, 0.038];

    layout.mapLabel = [mainX, 0.903, 0.050, 0.026];
    layout.showCoast = [0.355, 0.899, 0.115, 0.032];
    layout.coastColorLabel = [0.480, 0.903, 0.080, 0.026];
    layout.coastColorPopup = [0.565, 0.899, 0.095, 0.034];

    layout.axes = [mainX, 0.180, mainWidth, 0.705];
    layout.detailsText = [mainX, 0.015, mainWidth, 0.125];
end
