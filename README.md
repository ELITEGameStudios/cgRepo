
Lecture 8 - Visual Effects Reflection

I tried my best to follow along with the pace of the class while also writing the shaders' code manually to the best of my ability. I understand the effect metallic is supposed to give; The visibility/intensity of your color becomes more or less dependent on the amount of light hitting its normal. Smoothness determines how much the light scatters or focuses on a given surface, and visually shows more or less blurred/accurate reflections of light surfaces. 

Stencil buffers "assign" pixels stencil values depending on if a certain gameobject resides there or not, where you could use as a mask/transparency filter for gameobjects which detect this stencil value and are on those same pixels.

The alpha texture simply takes the alpha value of the 2D texture since it stores info in RGBA format, which includes alpha data.
