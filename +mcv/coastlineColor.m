function color = coastlineColor(name)
%COASTLINECOLOR Converte il nome GUI nel corrispondente colore RGB.

    if iscell(name), name = name{1}; end
    name = lower(strtrim(char(name)));
    switch name
        case 'bianco'
            color = [1, 1, 1];
        case 'rosso'
            color = [0.90, 0.10, 0.10];
        case 'grigio'
            color = [0.45, 0.45, 0.45];
        case 'blu'
            color = [0.10, 0.30, 0.90];
        case 'verde'
            color = [0.10, 0.65, 0.20];
        case 'giallo'
            color = [1.00, 0.85, 0.05];
        case 'magenta'
            color = [0.85, 0.10, 0.75];
        case 'ciano'
            color = [0.05, 0.80, 0.85];
        otherwise
            color = [0, 0, 0];
    end
end
