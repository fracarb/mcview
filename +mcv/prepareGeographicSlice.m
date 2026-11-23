function [data, xCoordinate, yCoordinate, axesInfo, geoInfo] = ...
        prepareGeographicSlice(data, xCoordinate, yCoordinate, axesInfo, options)
%PREPAREGEOGRAPHICSLICE Applica wrapping e proiezione a una slice lon/lat.

    geoInfo = struct('isGeographic', false, 'projection', 'equirectangular', ...
        'axesSwapped', false, 'latitudeValues', [], 'projectedLatitude', [], ...
        'xOrder', 1:max(1, size(data, 1)), ...
        'yOrder', 1:max(1, size(data, 2)), ...
        'longitudeOrder', 1:max(1, size(data, 1)), ...
        'latitudeOrder', 1:max(1, size(data, 2)));
    [isGeographic, axesSwapped] = mcv.isGeographicAxes(axesInfo);
    if ~isGeographic
        return;
    end
    geoInfo.isGeographic = true;
    geoInfo.axesSwapped = axesSwapped;
    if nargin < 5 || ~isfield(options, 'projection')
        options.projection = 'equirectangular';
    end
    if ~isfield(options, 'wrapLongitude'), options.wrapLongitude = true; end
    geoInfo.projection = options.projection;

    if options.wrapLongitude
        if axesSwapped
            wrapped = mod(double(yCoordinate) + 180, 360) - 180;
        else
            wrapped = mod(double(xCoordinate) + 180, 360) - 180;
        end
        if isvector(wrapped)
            [wrapped, order] = sort(wrapped);
            if axesSwapped
                yCoordinate = wrapped;
                data = data(:, order);
                axesInfo.y.values = yCoordinate;
                axesInfo.y.plotValues = yCoordinate;
                geoInfo.yOrder = order;
            else
                xCoordinate = wrapped;
                data = data(order, :);
                axesInfo.x.values = xCoordinate;
                axesInfo.x.plotValues = xCoordinate;
                geoInfo.xOrder = order;
            end
        else
            if axesSwapped
                yCoordinate = wrapped;
                axesInfo.y.values = wrapped;
                axesInfo.y.plotValues = wrapped;
            else
                xCoordinate = wrapped;
                axesInfo.x.values = wrapped;
                axesInfo.x.plotValues = wrapped;
            end
        end
    end

    if axesSwapped
        geoInfo.latitudeValues = double(axesInfo.x.values);
        if strcmp(options.projection, 'mercator')
            xCoordinate = mercatorLatitude(double(xCoordinate));
        end
        geoInfo.projectedLatitude = double(xCoordinate);
        geoInfo.longitudeOrder = geoInfo.yOrder;
        geoInfo.latitudeOrder = geoInfo.xOrder;
    else
        geoInfo.latitudeValues = double(axesInfo.y.values);
        if strcmp(options.projection, 'mercator')
            yCoordinate = mercatorLatitude(double(yCoordinate));
        end
        geoInfo.projectedLatitude = double(yCoordinate);
        geoInfo.longitudeOrder = geoInfo.xOrder;
        geoInfo.latitudeOrder = geoInfo.yOrder;
    end
end

function projected = mercatorLatitude(latitude)
    latitude = max(-85, min(85, latitude));
    projected = (180 / pi) .* log(tan(pi / 4 + latitude .* pi / 360));
end
