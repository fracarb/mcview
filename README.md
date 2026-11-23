# MCVIEW

MCVIEW is a free and open-source NetCDF viewer written in code compatible with
both MATLAB and GNU Octave. It aims to combine the immediacy of `ncview` with a
progressively richer visualization model inspired by the flexibility of
psyplot, without requiring Python at runtime.

This project is an independent reimplementation. It does not contain code
copied from ncview or psyplot.

## Features

MCVIEW currently provides:

- support for `.nc`, `.nc4`, and `.cdf` files;
- multi-file collections, automatic time-coordinate sorting, and concatenation
  of compatible variables along the time dimension;
- recursive reading of variables stored in NetCDF4 groups;
- an expandable tree browser for NetCDF4 groups and subgroups, while preserving
  full paths such as `/ocean/temp`;
- empty plot axes until a variable is explicitly selected;
- scalar, 1D series, and 2D field visualization;
- free selection of the X and Y dimensions;
- slicing along every remaining dimension;
- quick XY, XZ, and YZ plane selection based on CF names and attributes;
- automatic selection of the axis orthogonal to the displayed plane, with cut
  positions specified either by index or physical coordinate;
- independent spatial-cut and scan dimensions, for example an XZ slice at
  Y=32 animated over time;
- dedicated controls for moving the spatial cut forward or backward without
  changing the selected time frame;
- forward, backward, and animated navigation along any excluded dimension;
- animation speed, direction, loop control, and support for growing files;
- a 24-slice cache for smooth animation, with configurable 64, 256, or 512 MB
  memory limits;
- automatic downsampling of very large slices while retaining their original
  index mapping;
- dimensional coordinate variables and auxiliary coordinates declared through
  the CF `coordinates` attribute;
- long names and units on plot axes, variables, and colorbars;
- readable CF time axes such as `days since 2000-01-01`;
- correct non-Gregorian CF calendars: `360_day`, `noleap`/`365_day`, and
  `all_leap`/`366_day`, without converting them to inaccurate Gregorian dates;
- global, variable, and coordinate attribute inspection;
- support for packing, `_FillValue`, `missing_value`, and
  `valid_min`/`valid_max`/`valid_range`;
- selectable colormaps and automatic or manual color limits;
- fast and complete global ranges, 2nd-98th percentiles, and ranges symmetric
  around zero;
- histograms, Log10 color scaling, and a diverging colormap;
- color and Y-axis inversion, low/high-value emphasis, and interpolation;
- point values obtained by clicking a map cell;
- up to five overlaid 1D profiles, logarithmic axes, and CSV export;
- side-by-side variable comparison, difference, and ratio;
- longitude/latitude maps, 2D curvilinear grids, and dateline handling;
- automatic X=longitude and Y=latitude selection from CF metadata, including
  datasets whose dimensions are declared as `lat, lon`;
- longitude/latitude and Mercator views with Natural Earth 1:10m coastlines,
  including small islands, without requiring the Mapping Toolbox;
- optional coastline display and selectable coastline colors;
- PNG export;
- display of data type, range, mean, and the current `start`/`count` selection.

## Requirements

### GNU Octave

The `netcdf` package is required:

```octave
pkg install -forge netcdf   % only once, if it is not already installed
pkg load netcdf             % MCVIEW also runs this automatically at startup
```

The project is automatically tested with GNU Octave 11.3.0 and `netcdf`
1.0.21.

### MATLAB

No `pkg load` command is needed. MCVIEW detects MATLAB and directly uses
`ncinfo` and `ncread`. The MATLAB implementation relies on classic graphics
APIs and does not require App Designer or `uifigure`.

## Getting started

Add the project directory to the MATLAB or Octave path, then run:

```matlab
mcview
```

To open a dataset directly:

```matlab
mcview('/path/to/file.nc')
```

To open every file matching a wildcard pattern:

```matlab
mcview('/path/to/experiment/run_*.nc')
```

The compact `ncview`-style syntax is also available from the Command Window:

```matlab
mcview file.nc
mcview run_*.nc
```

MCVIEW expands `*` directly in MATLAB and Octave. Matching files are initially
sorted by name and, when a recognizable time coordinate is present, reordered
in time and concatenated into a single collection. The `?` wildcard matches one
character, for example `mcview('run_??.nc')`. A pattern with no matches produces
an explicit command-line error.

An explicit file collection can also be provided:

```matlab
mcview({'run_001.nc', 'run_002.nc', 'run_003.nc'})
```

Runtime detection is centralized in `mcv.isOctave`, while conditional
dependency loading is handled by `mcv.setupEnvironment`.

## Testing

Run the portable core test suite from MATLAB or Octave in the project folder:

```matlab
addpath('tests')
run_tests
```

The tests generate small temporary NetCDF datasets and cover runtime detection,
coordinates, classic NetCDF files, nested NetCDF4 groups, CF axis selection,
dimension ordering, 3D planes, non-Gregorian calendars, coastlines, and
multi-file time concatenation.

Run the graphical smoke test when a graphics backend is available:

```matlab
addpath('tests')
run_gui_smoke_test
```

The `.github/workflows/ci.yml` workflow runs core and graphical tests with
Octave and MATLAB. MATLAB jobs in private repositories may require a MATLAB
batch licensing token.

## Architecture

- `mcview.m`: public entry point;
- `+mcv/resolveInputFiles.m`: portable file and wildcard expansion;
- `+mcv/setupEnvironment.m`: MATLAB/Octave compatibility and dependencies;
- `+mcv/createViewer.m`: portable graphical interface;
- `+mcv/readVariableSlice.m`: NetCDF selection and slice reading;
- `+mcv/mergeDatasetInfos.m`: multi-file catalog and concatenation;
- `+mcv/flattenDatasetInfo.m`: recursive NetCDF4 group traversal;
- `+mcv/variableTreeRows.m`: portable group and variable tree;
- `+mcv/decodeCFTime.m`: Gregorian and non-Gregorian CF calendars;
- `+mcv/computeVariableRange.m`: global ranges and fast sampling;
- `+mcv/prepareGeographicSlice.m`: dateline handling and map projection;
- `+mcv/coastlineData.m`: Natural Earth coastline loading;
- `data/natural_earth_10m_coastline.mat`: portable 1:10m coastline data;
- `tools/import_natural_earth_coastline.m`: toolbox-free shapefile importer;
- `+mcv/readCurvilinearCoordinates.m`: 2D CF auxiliary coordinates;
- `+mcv/downsampleSlice.m`: adaptive downsampling for large datasets;
- `.github/workflows/ci.yml`: continuous MATLAB/Octave validation;
- `+mcv/prepareSlice.m`: dimension-order normalization;
- `tests/run_tests.m`: portable regression tests.

## Roadmap

Planned milestones include:

1. additional map projections;
2. animation video export and extended playback controls;
3. plot recipes, multi-profile workflows, and transects;
4. native asynchronous reading where supported by the runtime;
5. automated benchmarks for large NetCDF datasets.

## License

MCVIEW is distributed under the MIT License. See [LICENSE](LICENSE).
