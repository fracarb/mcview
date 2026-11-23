function [coastX, coastY] = prepareCoastline( ...
        coastLongitude, coastLatitude, geoInfo, longitudeCoordinate, wrapLongitude)
%PREPARECOASTLINE Orienta e interrompe le coste secondo gli assi del plot.

    if ~wrapLongitude && min(longitudeCoordinate(:)) >= 0 && ...
            max(longitudeCoordinate(:)) > 180
        domain = '360';
    else
        domain = '180';
    end
    [coastLongitude, coastLatitude] = mcv.wrapLineLongitude( ...
        coastLongitude, coastLatitude, domain);
    if isfield(geoInfo, 'axesSwapped') && geoInfo.axesSwapped
        coastX = coastLatitude;
        coastY = coastLongitude;
    else
        coastX = coastLongitude;
        coastY = coastLatitude;
    end
end
