# README

* Stack:
Ruby: 3.47
Rails: 8.1.3.1
PostgreSQL: 18.2

* System dependencies

* Configuration

* Database creation
For local development I'm using PostgreSQL with PostGIS extension installed (https://github.com/postgis/docker-postgis) in a docker container. Container is configured via `docker-compose.yml` file and can be started using Foreman/Overmind along with the rails server, or with:
```
$ docker compose up db
```

* Database initialization

I'm using OpenStreetMap data exported as OSM file and then imported to PostgreSQL using `osm2pgsql` utility (https://osm2pgsql.org/).

```
osm2pgsql -d spatial_api_dev -U gis -H localhost -P 5433 -W -c map.osm

```

where `spatial_api_dev` is the database and `map.osm` is the file with exported OSM data.

# Endpoints

There are couple of endpoint in the application, ie.:

## Street names
```
/api/v1/streets              # default order asc
/api/v1/streets?order=desc   # order: asc|desc
```

which returns GeoJSON response with all street names.

```
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "name": "Chemiczna"
      }
    },
    {
      "type": "Feature",
      "properties": {
        "name": "Działkowa"
      }
    },
    {
      "type": "Feature",
      "properties": {
        "name": "Elektronowa"
      }
    },
    ...
  ]
}
```

## Places

### Index

```
/api/v1/places
/api/v1/places?json=simple      # simple formatting instead of GeoJSON
/api/v1/places?order=asc|desc   # sort
```

This endpoint returns either simple array:
```
[
"bench",
"nightclub",
"waste_basket",
...
"grit_bin",
"atm",
...
"shop/bakery",
...
"leisure/fitness_centre",
...
"tourism/information",
...
"man_made/utility_pole"
]
```

or proper GeoJSON:
```
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "text": "bench"
      }
    },
    {
      "type": "Feature",
      "properties": {
        "text": "nightclub"
      }
    },
...
  ]
}
```

Names from this endpoint can be used in other endpoints.

### Places/search

```
/api/v1/places/[amenity] ie. /api/places/nightclub
/api/v1/places/[place_type]/[place_name] ie. /api/places/shop/bakery
# can be called with singular or plural place type, ie.
/api/v1/places/[place_type]/[place_name] ie. /api/places/shops/bakery
```

These endpoints returns list of all places with given type:
```
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          15.498695599999998,
          51.944443199122375
        ]
      },
      "properties": {
        "place_type": "amenity",
        "name": "Hot Shots"
      }
    }
  ]
}
```

```
/api/v1/places/bench?loc=[lon],[lat]&r=500   # radius in meters
/api/v1/places/bench?loc=[lon],[lat]&r=500m  # radius in meters
/api/v1/places/bench?loc=[lon],[lat]&r=2k    # radius in kilometers
/api/v1/places/bench?loc=[lon],[lat]&r=2km   # radius in kilometers
/api/v1/places/bench?loc=15.49,51.94&r=500 
```

Searching for given place type in given radius from location.

*_All search endpoints accept `order` and `json` params for sorting and showing results in simpler format._*