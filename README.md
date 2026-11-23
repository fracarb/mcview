# MCVIEW

MCVIEW e un visualizzatore NetCDF libero e open source scritto in codice
compatibile con MATLAB e GNU Octave. L'obiettivo e unire l'immediatezza di
`ncview` con un modello di visualizzazione progressivamente piu ricco, ispirato
alla flessibilita di psyplot, senza richiedere Python per l'esecuzione.

Il progetto e una reimplementazione indipendente: non contiene codice copiato
da ncview o psyplot.

## Stato attuale

Questa prima versione e un MVP funzionante. Permette di:

- aprire file `.nc`, `.nc4` e `.cdf`;
- aprire piu file, ordinarli dalla coordinata temporale e concatenare
  automaticamente variabili compatibili lungo tempo;
- leggere ricorsivamente variabili nei gruppi NetCDF4;
- elencare le variabili usando il percorso completo, ad esempio `/ocean/temp`;
- mantenere assi vuoti finche non viene scelta esplicitamente una variabile;
- visualizzare scalari, serie 1D e campi 2D;
- scegliere liberamente le dimensioni X e Y;
- scorrere le dimensioni rimanenti per estrarre una slice;
- selezionare rapidamente i piani XY, XZ e YZ usando nomi e attributi CF;
- selezionare automaticamente l'asse ortogonale al piano e scegliere la
  posizione del taglio per indice o coordinata fisica, mostrando indice,
  coordinata e unita della slice;
- mantenere fissa la quota spaziale del taglio e scorrere o animare una
  dimensione separata, per esempio XZ a Y=32 lungo il tempo;
- avanzare o arretrare la quota del taglio con frecce dedicate, senza
  modificare la dimensione temporale selezionata;
- avanzare, arretrare o animare le slice lungo qualsiasi dimensione esclusa;
- controllare velocita, direzione e loop dell'animazione e seguire file in crescita;
- conservare in cache le ultime 24 slice per rendere fluide le animazioni;
- limitare la cache a 64, 256 o 512 MB;
- ridurre automaticamente le slice molto grandi conservando la corrispondenza
  con gli indici originali;
- usare variabili-coordinate dimensionali e coordinate ausiliarie dichiarate
  dall'attributo CF `coordinates`;
- mostrare nomi estesi e unita di misura sugli assi e sulla variabile;
- etichettare la colorbar con nome della variabile e unita di misura;
- convertire assi temporali CF come `days since 2000-01-01` in date leggibili;
- consultare attributi globali, di variabile e delle coordinate;
- riconoscere packing, `_FillValue`, `missing_value`, `valid_min/max/range`;
- cambiare colormap e impostare limiti colore automatici o manuali;
- calcolare range globale rapido/completo, percentile 2-98 o simmetrico su zero;
- mostrare istogrammi, scala cromatica Log10 e colormap divergente;
- invertire colori e asse Y, applicare enfasi ai valori bassi/alti e interpolazione;
- leggere il valore di una cella cliccando sulla mappa;
- sovrapporre fino a cinque profili 1D, usare assi logaritmici ed esportare CSV;
- confrontare due variabili affiancandole o calcolando differenza e rapporto;
- riconoscere mappe lon/lat, griglie curvilinee 2D e passaggio del dateline;
- scegliere automaticamente X=longitudine e Y=latitudine dai metadati CF,
  anche quando il file dichiara le dimensioni nell'ordine `lat, lon`;
- visualizzare proiezioni lon/lat o Mercatore con coste Natural Earth 1:10m,
  incluse le isole minori e senza Mapping Toolbox, attivabili da checkbox e
  con colore selezionabile;
- esportare la vista corrente in PNG;
- vedere tipo, intervallo, media e selezione `start/count` corrente.

## Requisiti

### GNU Octave

Serve il pacchetto `netcdf`:

```octave
pkg install -forge netcdf   % solo la prima volta, se non e gia installato
pkg load netcdf             % MCVIEW lo esegue automaticamente all'avvio
```

La prima versione e verificata automaticamente con GNU Octave 11.3.0 e
`netcdf` 1.0.21.

### MATLAB

Non serve `pkg load`: MCVIEW rileva MATLAB e usa direttamente `ncinfo` e
`ncread`. Il ramo MATLAB e progettato per usare esclusivamente API grafiche
classiche, evitando App Designer e `uifigure`.

## Avvio

Aggiungere la cartella del progetto al path e lanciare:

```matlab
mcview
```

oppure aprire direttamente un dataset:

```matlab
mcview('/percorso/al/file.nc')
```

Per aprire da terminale tutti i file che corrispondono a un pattern wildcard:

```matlab
mcview('/percorso/esperimento/run_*.nc')
```

Nella Command Window si puo usare anche la sintassi compatta in stile `ncview`:

```matlab
mcview file.nc
mcview run_*.nc
```

Il carattere `*` viene espanso direttamente da MCVIEW sia in MATLAB sia in
Octave. I file trovati sono ordinati per nome e, quando contengono una
coordinata temporale riconoscibile, vengono poi riordinati nel tempo e
concatenati come una singola collezione. Anche `?` e supportato per indicare un
singolo carattere, per esempio `mcview('run_??.nc')`. Se il pattern non trova
file, MCVIEW mostra un errore esplicito nel terminale.

Per concatenare piu file lungo una dimensione unlimited/temporale:

```matlab
mcview({'run_001.nc', 'run_002.nc', 'run_003.nc'})
```

Il rilevamento del runtime e centralizzato in `mcv.isOctave`; il caricamento
condizionale delle dipendenze avviene in `mcv.setupEnvironment`.

## Test

Da Octave o MATLAB, nella cartella del progetto:

```matlab
addpath('tests')
run_tests
```

I test creano piccoli dataset NetCDF temporanei e verificano runtime,
coordinate, file NetCDF classic, gruppi NetCDF4, selezione CF degli assi,
ordine delle dimensioni, piani 3D, coste e concatenazione temporale multi-file.

Lo smoke test grafico, da eseguire con un backend grafico disponibile, e:

```matlab
addpath('tests')
run_gui_smoke_test
```

La workflow `.github/workflows/ci.yml` esegue test core e grafici con Octave e
test core/grafici con MATLAB. Nei repository GitHub privati il job MATLAB puo
richiedere un MATLAB batch licensing token.

## Architettura

- `mcview.m`: entry point pubblico;
- `+mcv/resolveInputFiles.m`: espansione portabile di file e wildcard;
- `+mcv/setupEnvironment.m`: compatibilita MATLAB/Octave e dipendenze;
- `+mcv/createViewer.m`: interfaccia grafica portabile;
- `+mcv/readVariableSlice.m`: selezione e lettura NetCDF;
- `+mcv/mergeDatasetInfos.m`: catalogo e concatenazione multi-file;
- `+mcv/flattenDatasetInfo.m`: scansione ricorsiva dei gruppi NetCDF4;
- `+mcv/computeVariableRange.m`: range globali e campionamento rapido;
- `+mcv/prepareGeographicSlice.m`: dateline e proiezione geografica;
- `+mcv/coastlineData.m`: caricamento delle coste Natural Earth;
- `data/natural_earth_10m_coastline.mat`: coste 1:10m in formato portabile;
- `tools/import_natural_earth_coastline.m`: importatore shapefile senza toolbox;
- `+mcv/readCurvilinearCoordinates.m`: coordinate CF ausiliarie 2D;
- `+mcv/downsampleSlice.m`: riduzione adattiva per dataset molto grandi;
- `.github/workflows/ci.yml`: verifica continua MATLAB/Octave;
- `+mcv/prepareSlice.m`: normalizzazione dell'ordine dimensionale;
- `tests/run_tests.m`: test di regressione portabili.

## Roadmap

Le prossime milestone previste sono:

1. browser gerarchico ad albero per gruppi NetCDF gia supportati dal reader;
2. calendari CF non gregoriani (`360_day`, `noleap`, `all_leap`);
3. ulteriori proiezioni cartografiche;
4. export video delle animazioni e controllo della velocita;
5. ricette di plot, profili multipli e transect;
6. lettura asincrona nativa quando il runtime offre primitive compatibili;
7. benchmark automatici su dataset NetCDF di grandi dimensioni.

## Licenza

MCVIEW e distribuito con licenza MIT. Vedere [LICENSE](LICENSE).
