# exactextractr

[![Build Status](https://gitlab.com/isciences/exactextractr/badges/master/build.svg)](https://gitlab.com/isciences/exactextractr/pipelines)

This package provides routines to perform fast and accurate zonal statistics on `raster` and `sf` objects in R using the [`exactextract`](https://github.com/isciences/exactextract) library.
Relative to other implementations, such as the `extract` function in the `raster` package, it:

* computes the exact percentage of each raster cell that is covered by a polygon
* avoids the use of computationally expensive raster disaggregation or polygon clipping methods

Additional background and a description of the method is available [here](https://github.com/isciences/exactextract#background).

### Example

```r
require(raster)
require(sf)
require(exactextractr)

# Pull some administrative boundaries for Brazil
brazil <- st_as_sf(getData('GADM', country='BRA', level=2))

# Pull some climate data (max. temperature)
temp <- getData('worldclim', var='tmax', res=10)[[12]]

# Find the mean-max temperature for each administrative boundary
brazil$max_dec_temp <- exact_extract(temp, brazil, weighted.mean, na.rm=TRUE)

plot(brazil['max_dec_temp'])
```

### Dependencies

Installation requires the [GEOS](https://geos.osgeo.org/) geometry processing library.
For best performance, it is recommended to use version 3.7, which introduced some optimizations important to `exactextractr`.
On Windows, GEOS will be downloaded automatically as part of package install.
On MacOS, it can be installed using Homebrew (`brew install geos`).
On Linux, it can be installed from system package repositories (`apt-get install libgeos-dev` on Debian/Ubuntu, or `yum install libgeos-devel` on CentOS/RedHat.)

On Windows, the R build tools ([Rtools](https://cran.r-project.org/bin/windows/Rtools/)) are also necessary.

### Installation

`exactextractr` is not in CRAN and can be installed from source only. Using [`devtools`](https://CRAN.R-project.org/package=devtools), the package can be installed with:

```r
devtools::install_github('isciences/exactextractr')
```

### Limitations

 * Raster and polygon inputs must be in the same coordinate reference system.
 * The portion of the raster that intersects any given polygon must fit into memory. (The entire raster does not need to fit into memory.)

