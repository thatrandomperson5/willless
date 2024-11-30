# Call Structure
1. Initial Construction
2. Layout Construction Call
3. Per Tick Calls
  1. Pre-Compute Layouts for text
  2. Re-Layout Call
  3. Compute Layouts
  4. Render


# Coordinate Structure
* Same as buju but adapted for illwill
* A box at (0,0) with height 10 and width 10 will span in bounds [0, 0, 9, 9]
* Float values from buju coordinates are all rounded in a optimal way
* As mentioned above, coordinates are inclusive [0, 0, 5, 5] is a 6x6 cube.
