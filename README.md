# Test-case for Postgres Pointcloud performance issue

Running the test-case requires a 9.6 Postgres instance with the [Pointcloud
extension](https://github.com/pgpointcloud/pointcloud) installed and ready to use.

The easiest is to run a container based on the [`elemoine/pointcloud`
image](https://hub.docker.com/r/elemoine/pointcloud/). The instructions below assume that Docker is
used. Adapt the instructions if you don't want to use Docker.

## Set up

Pull the `elemoine/pointcloud` Docker image and start a Postgres instance:

```bash
$ make pull
$ make run
```

Look at the `Makefile` if unsure.

Restore the `lopocs` database from `lopocs.dump`:

```bash
$ make restore
```

## Bad case

With the Pointcloud extension loaded before the PostGIS extension:

```bash
$ make psql
psql -U postgres -h localhost -p 9999 -d lopocs
psql (9.6.3)
Type "help" for help.

lopocs=# \timing
Timing is on.
lopocs=# select pc_version();  -- load the Pointcloud extension first
 pc_version 
------------
 1.1.0
(1 row)

Time: 4.721 ms
lopocs=# select points from airport where st_intersects(pc_envelopegeometry(points), st_geometryfromtext('POLYGON((475290.686434015 -4707886.81255759,475290.686434015 -4707441.43255759,476044.586434015 -4707441.43255759,476044.586434015 -4707886.81255759,475290.686434015 -4707886.81255759))', 4978));

Time: 10041.373 ms
```

10 seconds!

## Good case

With the PostGIS extension loaded before the Pointcloud extension:

```bash
$ make psql
psql -U postgres -h localhost -p 9999 -d lopocs
psql (9.6.3)
Type "help" for help.

lopocs=# \timing
Timing is on.
lopocs=# select postgis_version();  -- load the PostGIS extension first
            postgis_version            
---------------------------------------
 2.3 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
(1 row)

Time: 57.336 ms
lopocs=# select points from airport where st_intersects(pc_envelopegeometry(points), st_geometryfromtext('POLYGON((475290.686434015 -4707886.81255759,475290.686434015 -4707441.43255759,476044.586434015 -4707441.43255759,476044.586434015 -4707886.81255759,475290.686434015 -4707886.81255759))', 4978));

Time: 515.023 ms
```

500 milliseconds!
