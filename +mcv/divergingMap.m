function map = divergingMap(count)
%DIVERGINGMAP Colormap blu-bianco-rosso per campi centrati su zero.

    if nargin < 1, count = 256; end
    anchors = [0.10, 0.25, 0.75; 1, 1, 1; 0.75, 0.12, 0.10];
    positions = [0, 0.5, 1];
    query = linspace(0, 1, count);
    map = zeros(count, 3);
    for channel = 1:3
        map(:, channel) = interp1(positions, anchors(:, channel), query, 'linear');
    end
    map = max(0, min(1, map));
end
