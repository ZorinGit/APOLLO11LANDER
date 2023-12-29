# APOLLO 11 LANDER

#### Video Demo: https://www.youtube.com/watch?v=hxL9pn6PkBs

#### Description

## Table of Contents
- [Basic Description](#basic-description)
- [Files](#files)
- [Tour of main.lua](#tour-of-mainlua)
- [What Went Well](#what-went-well)
- [Improving Code](#improving-code) 
- [Improving Game](#improving-game)
- [Miscellaneous](#miscellaneous)
- [Credits](#credits)
- [Future Work](#future-work)

## Basic Description

This is a classic minimalistic lunar lander game with an Apollo 11 theme written in lua using the LOVE2D engine. Note this version requires a Love2d installation to run.

## Files 

All of the code is in `main.lua` while `font`, `sounds` and `sprites` contain the relevant game files. Although I tried to keep `main.lua` well organized, it became unmanageable towards the end with over 1.3k lines of code. I will definitely endeavor to break up the code base for future projects.

## Tour of main.lua

This follows the typical structure of a Love2d game:

### love.load()

Starts by setting the resolution and importing physics data and graphics into tables `LANDER`, `LUNAR` and so on. Several counters and time keepers are also initialized. Afterwards, the game manager is created:

```
GAME_MANAGER = {"1-tutorial", "2-game_play", "3-paused", "4-landed", "5-crashed", "6-out_of_bounds", "7-score_screen", "8-loaded", "9-splash_screen"} 
```

This is the heart of the game and controls the finite states that govern what gets executed in `love.update()` or displayed in `love.draw()`. It was also one of my favorite systems to implement.

The 5 levels are loaded next as tables. Following is a section dedicated to `love.draw()`. It sets up fonts, text, art and some basic logic for many of the display elements. Each element has a `draw` method that will be called in different `love.draw()` game states to render on screen.  

This if followed by a sounds section loading in all the audio media and setting some initial volume levels.

### love.update(dt) 

Here the current level is loaded up by redefining tables and setting flags. The volume control system follows; this can be universally accessed by any game state. Next come all of the game states controlling the different aspects of the game, gated by `if/then` statements checking the current state. 

For example, the biggest `2-game_play` state plays specific sound tracks, outlines how the lander moves, checks for landing collision, out of bounds, fuel alerts, pausing and more.

The most interesting aspect of here was implementing the collision system. Originally collision was checked by "pixel matching" where 2 pixels of the lander were checked across a table of hundreds of pixels making up the entire surface. Unfortunately this was not good enough as the lander routinely passed through the surface at higher speeds. 

A more effective line intersection and coincidence checker was implemented using this formula:

```
-- declare numerators and denominator to be used  
local a_numerator = (D.x - C.x)*(C.y - A.y) - (C.x - A.x)*(D.y - C.y)
local b_numerator = (B.x - A.x)*(C.y - A.y) - (C.x - A.x)*(B.y - A.y) 
local denominator = (D.x - C.x)*(B.y - A.y) - (B.x - A.x)*(D.y - C.y)
```

This system checks if an imaginary line segment at the bottom of the lander is ever intersected or coincident with any of the line segments making up the surface (usually 4-6 segments). Thanks to this optimization, collision was detected at virtually any speed, except for extremely high speeds that would never naturally occur in the game. The old system is commented out and kept for posterity.

I also tried to smooth the animation of the lander traveling across the screen using 3 ghost images of different opacities that move ahead of the lander. Not sure if this makes much of a difference.  

Lately of note is the `love.keypressed` function which is redefined in each section, as the keys and their effects differ based on the context of the current game state. At the very end after all the states are defined, some sounds are turned off if the current state is not `2-game_play`.

### love.draw()

Most of the code here was already written in `love.load()`, so I am just calling the `draw` functions for the appropriate graphical elements in each state.

## What Went Well

I am very happy with how the finite state game manager worked here to organize and structure my code. Especially with so many states, it would have been a nightmare to write conditions checking variables for every single event. 

I also really enjoyed optimizing the collision system. Although it took me a long time to understand and derive the formulas above for line segment intersection, I think it was worth it because now I am confident I understand its implementation. In fact, I chose to not use physics and collision detection Love2d libraries because I felt I would learn a lot more trying to implement them myself. 

Now that I feel more comfortable with the subject, I would seek libraries for the next game project.

## Improving Code

For starters, going forward I would seek to break up `main.lua` into sub files that contain much smaller chunks of code. Each big category like importing sounds or the different game states could easily be their own file, which would make the code much more manageable. 

I also feel there needs to be more abstraction in my code - many sections could be broken up into functions that abstract away systems, making the code much more readable.

Some examples would be:

- `sound.lua` - Contains all sound loading and volume control logic
- `states.lua` - Handles transitioning between game states
- `graphics.lua` - Draws sprites, textures, etc.  

## Improving Game

I feel the game is fairly bug free at this stage. It is also fun to play and fairly immersive for a simplistic lander game. There are some minor improvements I am considering, such as turning the velocity reading green when it is within acceptable landing range.

As for long term goals, the game is not very replayable. I believe that a procedural level generation system would really improve the replay value. I would enjoy working on implementing this if I have the time in the future.

## Miscellaneous

Following are some of the Apollo 11 numbers used to implement physics in the game. These were extracted from [Lander Physics Data](https://nssdc.gsfc.nasa.gov/nmc/spacecraft/display.action?id=1969-059C):

- lander mass = 15103 kg  
- lunar gravity in N = 1.6 kg * m/s^2
- lander acceleration due to gravity 1.6 m/s^2 
- lunar gravitational force on lander = 24164.8 N
- lander descent thruster force = 45000 N
- total lander acceleration when thrusters fire = -1.38 m/s^2
- lander maneuvering thruster force = 450 N and 4 modules and 4 nozzles = 7200 N (not exactly accurate but lateral speed was too slow otherwise)
- lander maneuvering thruster acceleration = 0.12 m/s^2
- Scale: 1 pixel in game is defined as 1 meter

## Credits

**Engine**  
[Love2D](https://love2d.org/)

**Music** 
- By [Kevin MacLeod](https://en.wikipedia.org/wiki/Kevin_MacLeod)
    - [Equatorial Complex](https://www.youtube.com/watch?v=IXVLVUI7PQE)
    - [Frozen Star](https://www.youtube.com/watch?v=Ay1D30B8shE) 
    - [Wizardtorium](https://www.youtube.com/watch?v=5e1hPW0rLK8)
    - [Fanfare for Space](https://www.youtube.com/watch?v=ZI02y1d3UnQ)

**Sounds**
- [Apollo 11 Mission Control chatter](https://www.youtube.com/watch?v=xc1SzgGhMKc) 
- Collisions
    - [newlocknew on Freesound](https://freesound.org/people/newlocknew/sounds/564809/)
    - [Link-Boy on Freesound](https://freesound.org/people/Link-Boy/sounds/414844/)
- Thrusters  
    - Video by [Played N Faved - Sound Effects & Stock Footage](https://www.youtube.com/watch?v=Ac-Vw7D8v3A) on YouTube 
- Fuel Alarm
    - Video by [Ze Rubenator on YouTube](https://www.youtube.com/watch?v=f9INvTu-gOI)  
- [DSKY Fonts](https://github.com/ehdorrii/dsky-fonts) by [ehdorrii](https://github.com/ehdorrii) on GitHub

**Art & Assets**
- Lander and thruster pixel art made using [Piskel](https://www.piskelapp.com/)
- Inspired by a scene from [First Man (2018)](https://www.youtube.com/watch?v=TrvXqosqkls)
- Splash Screen Background from [NASA Image Catalog](https://nssdc.gsfc.nasa.gov/imgcat/html/object_page/a11_h_44_6642.html)  
- Credits Background from [NASA History Site](https://history.nasa.gov/alsj/a11/AS11-40-5874HR.jpg)
- Background images retouched by [Leonardo.AI](https://app.leonardo.ai/)   

**Helpful Tutorials** 
- [CS50 Seminar](https://www.youtube.com/watch?v=iOA5YspoJDM)
- [General Love2D usage](https://www.youtube.com/watch?v=kpxkQldiNPU&list=PLqPLyUreLV8DrLcLvQQ64Uz_h_JGLgGg2)  
- Line Intersection
    - [Line Intersection Video 1](https://www.youtube.com/watch?v=fHOLQJo0FjQ)
    - [Line Intersection VIdeo 2](https://www.youtube.com/watch?v=bvlIYX9cgls)  

**NASA Websites**  
- [Lander Physics Data](https://nssdc.gsfc.nasa.gov/nmc/spacecraft/display.action?id=1969-059C)  
- [Lunar Rock Characteristics](https://www.lroc.asu.edu/posts/157)

Shoutout to CS50 duck debugger [cs50.ai](cs50.ai) for tons of help and encouragement throughout development!

## Future Work 

Potential improvements for the future:

- Procedural level generation system to increase replay value 
- Turn velocity readings green when within safe landing threshold 
- Break up `main.lua` into multiple files as described above
- Abstract out more logic into reusable functions