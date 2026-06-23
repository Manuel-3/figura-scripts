Contest entry for **Aquatic** avatar contest.

**Notable things about it:**

- Water simulation using a mesh and displacing the height of vertices
- No external libraries used / used only my own
- Works on default permissions (due to a lot of black magic script wizardry)
- Generates fish icon textures for the action wheel for each tropical fish variant

**Features**

- Bunch of settings at the top of the scripts if you wanna change stuff
- Change tropical fish models in action wheel
- Draining and filling the bowl in action wheel
- Accurate cog/gear animations while driving
- Splash particles
- Animated water texture that also adjusts to biome color

**How does this work on default permissions??**

Two major things were done here. Firstly, I used [Task](https://github.com/Manuel-3/figura-scripts/tree/main/src/task) which implements asynchronous for and while loops that utilize as many instructions as it can below the instruction limits. This cut down immensely on the init instructions, theoretically making that even run on low permission level. The second part is the fluid simulation, which used about double of the allowed default instruction limit. To cut that down, I split the computation that would usually be done in one tick, into two ticks. To adjust, some of the forces involved need to double to get roughly the same result as before, and the render delta has to be adjusted to interpolate from two ticks ago, instead of from last tick. With that, it fits just about below the default limit. I also had to implement an asynchronous table sorting function, as organizing the vertices into a usable grid using the inbuilt table.sort basically always went over the default limit as well.
