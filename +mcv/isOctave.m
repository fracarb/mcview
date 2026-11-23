function result = isOctave()
%ISOCTAVE Restituisce true quando il codice gira in GNU Octave.

    persistent cachedResult;
    if isempty(cachedResult)
        cachedResult = (exist('OCTAVE_VERSION', 'builtin') ~= 0);
    end
    result = cachedResult;
end
