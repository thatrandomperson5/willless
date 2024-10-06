

import unittest

import willless/utils

test "can wrap":
  const text1 = "Nulla facilisi. Fusce eget ex ac tellus sollicitudin porttitor. Sed metus sapien, egestas sed efficitur id, tristique eget ipsum. Donec pellentesque sem ligula, a aliquam turpis tempus non. Phasellus bibendum dui massa, vel iaculis arcu egestas eu. Suspendisse potenti. Pellentesque sit amet risus iaculis dui consequat maximus. Vestibulum et arcu massa. Etiam faucibus dolor eu dolor aliquam, in facilisis mauris molestie."
  echo hardWrap(text1, 10)
  echo hardWrap(text1, 5)

  const text2 = "Nulla facilisi. Fusce eget ex ac tellus sollicitudin porttitor. Sed metus sapien, egestas sed efficitur id, tristique eget ipsum. Donec pellentesque sem ligula, a aliquam turpis tempus non. Phasellus bibendum dui massa, vel iaculis arcu egestas eu. Suspendisse potenti.\n Pellentesque sit amet risus iaculis dui consequat maximus. Vestibulum et arcu massa. \nEtiam faucibus dolor eu dolor aliquam, in facilisis mauris molestie."
  echo hardWrap(text2, 10)

