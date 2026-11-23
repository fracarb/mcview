# Dati cartografici

`natural_earth_10m_coastline.mat` contiene le linee di costa **Natural
Earth 1:10m** insieme alle coste delle isole minori. Le versioni dei due
shapefile sorgente sono registrate nel campo `metadata.sourceVersions`.

- Sorgente: https://www.naturalearthdata.com/downloads/10m-physical-vectors/
- Licenza dei dati: pubblico dominio
- Conversione: `tools/import_natural_earth_coastline.m`

Il formato MAT permette di usare le coste sia in MATLAB sia in GNU Octave
senza Mapping Toolbox e senza il pacchetto `mapping`.
