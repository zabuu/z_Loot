# Changelog

## 0.4.1 (2026-11-06)

* Map is no longer offset. The map is drawn by cropping its tiles instead of a scroll frame, so the wheel,
  drag, right-click and middle-click reach it again.

## 0.4.0 (2026-11-06)

* Map handles like z_Map: smooth zoom around the cursor, drag to pan (also when starting on a marker), a little
  room past the edges, right-click zooms out, middle-click or Reset resets.
* Boss list reads down the left column first, then the right. Short lists use one column.
* Collections show where each item drops and its drop chance; the tooltip lists every source, and clicking the
  row opens that boss. About 2,900 more item names, so search finds collection items before they are cached.

## 0.3.0 (2026-11-06)

* Compact 980x600 layout: instances | map with the boss list under it | loot (or About) on the right.
  The map stays visible while browsing loot.
* Map zoom (mouse wheel, + / -) and drag to pan. Reset button or middle-click resets the view.

## 0.2.0 (2026-11-05)

* New window: flat dark design, larger text, instance sidebar, boss list and Loot / Map / About tabs, size button.
* Maps use this client's own map files per instance floor (the old lookup showed black maps on OctoWoW).
* No InstanceJournal art needed any more.

## 0.1.0 (2026-11-05)

* First version on the InstanceJournal window.
