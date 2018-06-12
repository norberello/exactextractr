# Copyright (c) 2018 ISciences, LLC.
# All rights reserved.
#
# This software is licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License. You may
# obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

context('exact_extract')

test_that("Basic stat functions work", {
  # This test just verifies a successful journey from R
  # to C++ and back. The correctness of the algorithm
  # is tested at the C++ level.
  square <- sf::st_sfc(sf::st_polygon(
    list(
      matrix(
        c(0.5, 0.5, 2.5, 0.5, 2.5, 2.5, 0.5, 2.5, 0.5, 0.5),
        ncol=2,
        byrow=TRUE))))

  data <- matrix(1:9, nrow=3, byrow=TRUE)

  rast <- raster::raster(data, xmn=0, xmx=3, ymn=0, ymx=3)

  dat <- exact_extract(rast, square)

  # Calling without a function returns a matrix of weights and values
  expect_equal(dat[[1]],
    cbind(vals=1:9, weights=c(0.25, 0.5, 0.25, 0.5, 1, 0.5, 0.25, 0.5, 0.25))
  )

  # Calling with a function(w, v) returns the result of the function
  expect_equal(exact_extract(rast, square, fun=weighted.mean),
               5)

  # Calling with a string computes a named stat from the C++ library
  expect_equal(exact_extract(rast, square, fun='mean'), 5)
  expect_equal(exact_extract(rast, square, fun='min'), 1)
  expect_equal(exact_extract(rast, square, fun='max'), 9)
  expect_equal(exact_extract(rast, square, fun='mode'), 5)
  expect_equal(exact_extract(rast, square, fun='minority'), 1)
  expect_equal(exact_extract(rast, square, fun='variety'), 9)
})

test_that('MultiPolygons also work', {
  multipoly <- sf::st_sfc(
    sf::st_multipolygon(list(
      sf::st_polygon(
        list(
          matrix(
            c(0.5, 0.5, 2.5, 0.5, 2.5, 2.5, 0.5, 2.5, 0.5, 0.5),
            ncol=2,
            byrow=TRUE))),
      sf::st_polygon(
        list(
          matrix(
            4 + c(0.5, 0.5, 2.5, 0.5, 2.5, 2.5, 0.5, 2.5, 0.5, 0.5),
            ncol=2,
            byrow=TRUE))))))

  data <- matrix(1:100, nrow=10, byrow=TRUE)

  rast <- raster::raster(data, xmn=0, xmx=10, ymn=0, ymx=10)

  dat <- exact_extract(rast, multipoly)

  expect_equal(exact_extract(rast, multipoly, fun='variety'), 18)
})

test_that('We fail if the polygon extends outside the raster', {
  rast <- raster::raster(matrix(1:(360*720), nrow=360),
                         xmn=-180,
                         xmx=180,
                         ymn=-90,
                         ymx=90)

  square <- sf::st_sfc(sf::st_polygon(
    list(
      matrix(
        c(179, 0,
          180.000000001, 0,
          180, 1,
          179, 0),
        ncol=2,
        byrow=TRUE))))

  expect_error(exact_extract(rast, square))
})

test_that('Additional arguments can be passed to fun', {
  data <- matrix(1:9, nrow=3, byrow=TRUE)
  rast <- raster::raster(data, xmn=0, xmx=3, ymn=0, ymx=3)

  square <- sf::st_sfc(sf::st_polygon(
    list(
      matrix(
        c(0.5, 0.5, 2.5, 0.5, 2.5, 2.5, 0.5, 2.5, 0.5, 0.5),
        ncol=2,
        byrow=TRUE))))

  exact_extract(rast, square, function(w, x, custom) {
    expect_equal(custom, 6)
  }, 6)
})

test_that('Incorrect argument types are handled gracefully', {
  data <- matrix(1:9, nrow=3, byrow=TRUE)
  rast <- raster::raster(data, xmn=0, xmx=3, ymn=0, ymx=3)

  point <- sf::st_sfc(sf::st_point(1:2))
  linestring <- sf::st_sfc(sf::st_linestring(matrix(1:4, nrow=2)))
  multipoint <- sf::st_sfc(sf::st_multipoint(matrix(1:4, nrow=2)))
  multilinestring <- sf::st_sfc(sf::st_multilinestring(list(
    matrix(1:4, nrow=2),
    matrix(5:8, nrow=2)
  )))
  geometrycollection <- sf::st_sfc(sf::st_geometrycollection(list(
    sf::st_geometry(point)[[1]],
    sf::st_geometry(linestring)[[1]])))

  expect_error(exact_extract(rast, point))
  expect_error(exact_extract(rast, linestring))
  expect_error(exact_extract(rast, multipoint))
  expect_error(exact_extract(rast, multilinesetring))
  expect_error(exact_extract(rast, geometrycollection))
})