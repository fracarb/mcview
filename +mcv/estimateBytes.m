function bytes = estimateBytes(value)
%ESTIMATEBYTES Stima i byte occupati da un valore MATLAB/Octave.

    information = whos('value');
    bytes = double(information.bytes);
end
