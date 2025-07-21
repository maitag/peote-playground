# isometric projection experiments

## version 1 - basic proof of concept

The `Main.hx` application consists of a small isometric grid that can be interacted with (zoom and click);

Mouse controls;
- wheel : zoom in and out
- button left : click a cell
- button other : reset the grid

Key controls;
- numpad 0 : toggle cell labels

Run it with e.g.

```
lime test hl
```

## version 2 - render map

`MainMap.hx` application extends on version 1. 

run it with e.g.

```
lime test hl --app-main=MainMap
````

Here the screen is filled with tile elements, arranged for the isometric grid.

A 2D tilemap is projected to the tiles on the grid. The map is larger than what can be display on screen. The view of the map can be changed.

Tile y position is animated on the GPU as a wave.


Mouse controls;
- wheel : zoom in and out
- button left : click a cell

Key controls;

- w|a|s|d|arrows : change map view
- numpad 8 : reduce wave amplitude
- numpad 9 : increase wave amplitude
- numpad 5 : reduce wave length
- numpad 6 : increase wave length
- numpad 0 : toggle cell labels