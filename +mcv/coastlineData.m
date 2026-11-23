function [longitude, latitude] = coastlineData(projection)
%COASTLINEDATA Restituisce le coste Natural Earth senza toolbox opzionali.

    persistent naturalEarthLongitude naturalEarthLatitude
    if isempty(naturalEarthLongitude)
        packageFolder = fileparts(mfilename('fullpath'));
        dataFile = fullfile(fileparts(packageFolder), 'data', ...
            'natural_earth_10m_coastline.mat');
        if exist(dataFile, 'file') == 2
            coastline = load(dataFile, 'longitude', 'latitude');
            naturalEarthLongitude = double(coastline.longitude);
            naturalEarthLatitude = double(coastline.latitude);
        else
            [naturalEarthLongitude, naturalEarthLatitude] = schematicCoastline();
        end
    end
    longitude = naturalEarthLongitude;
    latitude = naturalEarthLatitude;

    if nargin > 0 && strcmp(projection, 'mercator')
        clipped = max(-85, min(85, latitude));
        latitude = (180 / pi) .* log(tan(pi / 4 + clipped .* pi / 360));
    end
end

function [longitude, latitude] = schematicCoastline()
%SCHEMATICCOASTLINE Fallback minimo per installazioni senza il dataset.

    northAmerica = [-168 72; -145 70; -125 58; -130 50; -124 40; -117 32; ...
        -105 24; -97 19; -86 21; -80 26; -81 32; -70 44; -60 49; -55 60; ...
        -65 70; -100 75; -135 73; -168 72];
    southAmerica = [-81 12; -72 11; -61 7; -50 1; -36 -6; -40 -20; ...
        -50 -34; -55 -53; -68 -55; -76 -35; -81 -10; -81 12];
    greenland = [-73 60; -50 60; -20 70; -25 82; -55 84; -73 75; -73 60];
    eurasia = [-10 36; 0 44; 15 45; 30 60; 55 70; 90 75; 130 70; ...
        170 65; 160 50; 140 35; 120 20; 105 5; 80 8; 65 25; 45 30; ...
        35 42; 20 35; 5 36; -10 36];
    africa = [-17 37; 10 37; 33 31; 50 12; 42 -12; 28 -34; 15 -35; ...
        2 -25; -10 5; -17 20; -17 37];
    australia = [112 -11; 130 -12; 151 -25; 146 -39; 125 -35; 113 -22; 112 -11];
    antarctica = [-180 -70; -120 -75; -60 -68; 0 -72; 60 -68; 120 -74; ...
        180 -70];
    japan = [130 31; 136 35; 142 44];
    madagascar = [49 -12; 50 -25; 44 -20; 49 -12];
    polygons = {northAmerica, southAmerica, greenland, eurasia, africa, ...
        australia, antarctica, japan, madagascar};
    longitude = [];
    latitude = [];
    for index = 1:numel(polygons)
        longitude = [longitude; polygons{index}(:, 1); NaN]; %#ok<AGROW>
        latitude = [latitude; polygons{index}(:, 2); NaN]; %#ok<AGROW>
    end
end
