function [plotDimensions, cutDimension, planeName] = ...
        planeDimensions(mapping, selection)
%PLANEDIMENSIONS Restituisce assi del piano e asse ortogonale di taglio.

    if selection == 2
        plotDimensions = [mapping.x, mapping.y];
        cutDimension = mapping.z;
        planeName = 'XY';
    elseif selection == 3
        plotDimensions = [mapping.x, mapping.z];
        cutDimension = mapping.y;
        planeName = 'XZ';
    elseif selection == 4
        plotDimensions = [mapping.y, mapping.z];
        cutDimension = mapping.x;
        planeName = 'YZ';
    else
        plotDimensions = [0, 0];
        cutDimension = 0;
        planeName = '';
    end
end
