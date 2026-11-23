function viewer = mcview(filename)
%MCVIEW Esplora interattivamente file NetCDF in MATLAB e GNU Octave.
%   MCVIEW apre una finestra vuota e permette di scegliere un file.
%   MCVIEW(FILENAME) apre direttamente il file NetCDF indicato.
%   MCVIEW(PATTERN) apre tutti i file che corrispondono a una wildcard,
%   per esempio MCVIEW('run_*.nc').
%   MCVIEW({FILE1, FILE2, ...}) concatena file compatibili lungo tempo.
%   Dalla Command Window sono valide anche le forme MCVIEW file.nc e
%   MCVIEW run_*.nc.
%
%   H = MCVIEW(...) restituisce l'handle della finestra.

    if nargin < 1
        filename = '';
    elseif ~isempty(filename)
        filenames = mcv.resolveInputFiles(filename);
        if numel(filenames) == 1
            filename = filenames{1};
        else
            filename = filenames;
        end
    end

    environment = mcv.setupEnvironment();
    figureHandle = mcv.createViewer(environment, filename);

    if nargout > 0
        viewer = figureHandle;
    end
end
