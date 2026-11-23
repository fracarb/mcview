function label = axisLabel(axisInfo)
%AXISLABEL Compone nome esteso e unita di misura per un asse.

    if isempty(axisInfo.units)
        label = axisInfo.longName;
    else
        label = sprintf('%s [%s]', axisInfo.longName, axisInfo.units);
    end
end
