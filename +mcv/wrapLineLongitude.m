function [longitude, latitude] = wrapLineLongitude(longitude, latitude, domain)
%WRAPLINELONGITUDE Riporta linee in 180/360 gradi separando le discontinuita.
%   L'inserimento di NaN evita che PLOT colleghi i due lati della mappa con
%   una linea quando una costa attraversa il meridiano di taglio.

    longitude = double(longitude(:));
    latitude = double(latitude(:));
    if strcmp(domain, '360')
        longitude = mod(longitude, 360);
    else
        longitude = mod(longitude + 180, 360) - 180;
    end
    if numel(longitude) < 2
        return;
    end

    finitePairs = isfinite(longitude(1:end - 1)) & ...
        isfinite(longitude(2:end)) & isfinite(latitude(1:end - 1)) & ...
        isfinite(latitude(2:end));
    breaks = finitePairs & abs(diff(longitude)) > 180;
    if ~any(breaks)
        return;
    end

    breakAfter = [breaks; false];
    positions = (1:numel(longitude))' + [0; cumsum(double(breaks))];
    outputLength = numel(longitude) + sum(breaks);
    wrappedLongitude = NaN(outputLength, 1);
    wrappedLatitude = NaN(outputLength, 1);
    wrappedLongitude(positions) = longitude;
    wrappedLatitude(positions) = latitude;
    wrappedLongitude(positions(breakAfter) + 1) = NaN;
    wrappedLatitude(positions(breakAfter) + 1) = NaN;
    longitude = wrappedLongitude;
    latitude = wrappedLatitude;
end
