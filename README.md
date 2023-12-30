# APOLLO 11 LANDER

#### Video Demo: https://www.youtube.com/watch?v=hxL9pn6PkBs

#### Description:


## Table of Contents
- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Code Overview](#code-overview)
- [Successes and Challenges](#successes-and-challenges)
- [Code Improvements](#code-improvements) 
- [Game Improvements](#game-improvements)
- [Miscellaneous](#miscellaneous)
- [Credits](#credits)
- [Future Development](#future-development)


## Introduction

Welcome to the Apollo 11 Lander, a minimalistic lunar lander developed in Lua using the LOVE2D engine. This is my final project for CS50. To run this version of the game, ensure you have [Love2D](https://love2d.org/) installed on your system.

My primary objective was not to revolutionize the lunar lander genre but to excel in execution within the framework of a classic design and the Love2D engine. By narrowing the scope and crafting a minimalist lunar lander, the aim was to provide an experience that excelled in simplicity. Key objectives included clear visual presentation, fluid gameplay, interesting level design and an engaging atmosphere. Immersive elements, including background music, carefully chosen sound effects, crash animations, low fuel alerts and background NASA chatter were implemented to elevate the overall user experience.


## Project Structure

The entire codebase resides in the `main.lua` file, accompanied by game assets found in the `font`, `sounds`, and `sprites`. While I aimed to maintain organization within `main.lua`, the complexity grew as the project evolved, resulting in over 1.3k lines of code. Recognizing this, I acknowledge the need to modularize and refactor the codebase for better maintainability in future projects.


## Code Overview

The code follows the typical structure of a Love2D game, organized into 3 key sections:

### love.load()

The initialization process begins by setting the resolution and populating tables (`LANDER`, `LUNAR`, etc.) with physics data and graphics. Several counters and timekeeping variables are also initialized. A central component, the game manager, is created to control finite states governing actions in `love.update()` and displayed content in `love.draw()`. The game manager, represented by the `GAME_MANAGER` an array like table, defines states such as (tutorial, gameplay, paused, etc). Conceptualizing, implementing and managing these states was one of the project's highlights for me.
```
GAME_MANAGER = {"1-tutorial", "2-game_play", "3-paused", "4-landed", "5-crashed", "6-out_of_bounds", "7-score_screen", "8-loaded", "9-splash_screen"} 
```
Next, the game initializes five levels as tables. A section for `love.draw()` sets up fonts, text, art, and basic logic for various display elements. Each element has a `draw()` method, called in specific `love.draw()` game states to render on-screen.

Following the display setup, a section for loading audio media and setting initial volume levels is implemented for sound effects and music.

### love.update(dt)

In this section, the code manages the game's logic and dynamics. First the current level is loaded by redefining tables and resetting flags.A universal volume control system is implemented, accessible from any game state. All fo the different game states follow. They are demarcated `if/then` statements, each state managing specific aspects of the game. For instance, the largest `2-game_play` state controls soundtrack and sound effect volumes, lander movement, collisions, out-of-bounds detection, fuel alerts, pausing, and more.

Am interesting aspect of this section is the collision system. Initially I utilized a cumbersome "pixel matching" algorithm. However, due to the "bullet through paper" problem the lander would often pass through the surface at high speeds. A more robust line intersection and coincidence checker was implemented using the formula:

```
-- Declare numerators and denominator to be used  
local a_numerator = (D.x - C.x)*(C.y - A.y) - (C.x - A.x)*(D.y - C.y)
local b_numerator = (B.x - A.x)*(C.y - A.y) - (C.x - A.x)*(B.y - A.y) 
local denominator = (D.x - C.x)*(B.y - A.y) - (B.x - A.x)*(D.y - C.y)
```
This optimized system checks if an imaginary line segment at the bottom of the lander intersects or coincides with any line segments making up the lunar surface. This allows for consistent collision detection even at high speeds. The old pixel-matching system remains commented out for posterity.

Additional attempts to enhance user experience include the use of ghost images to smooth the animation of the lander's movement across the screen. Three ghost images of varying opacities move ahead of the lander to create a smooth visual effect. Although I am not sure if this very noticeable.

Finally, the love.keypressed function is redefined in each section to accommodate specific key configurations based on the current game state. At the end of `love.update(dt)`, sounds are muted if the current state is not 2-game_play.

### love.draw()

This section simply involves calling the `draw()` method for graphical elements previously initialized in `love.load()` and rendering them in the appropriate states.


## Successes and Challenges

One of my favorite achievements in this project is the effective implementation of the finite state game manager. Organizing and structuring the code became quite manageable within specific states. The game manager proved invaluable in avoiding a convoluted web of conditions checking variables for every event, resulting in a more readable codebase.

Another significant success lies in the optimization of the collision system. Although it demanded time and effort to understand and derive the formulas for line segment intersection, the resulting confidence in the implementation was well worth it. The decision to forego the use of Love2D physics and collision detection libraries in favor of a manual implementation was intentional. I feel this approach yielded a deeper understanding of the subject. With a firmer understanding of collision and physics implementation in videogames I feel more confident in leveraging existing libraries to expedite development for a future project.


## Code Improvements

In retrospect, I recognize the need for significant code refactoring to enhance maintainability and readability. Going forward, the following improvements would be prioritized:

### Code Modularization

The sprawling `main.lua` file, with over 1.3k lines of code, presents an opportunity for better organization. The plan would be to divide the code into smaller, focused files. Each major category, such as sound management, game states, and graphics rendering, would have its dedicated file. This modular approach would aim to streamline code navigation and facilitate future updates.

### Abstraction

Introducing more abstraction will be a priority to improve code readability and maintainability. Many sections of the code could benefit from abstraction through the creation of functions that encapsulate specific systems to enhance clarity and reuse.

Some examples would be:

- `load_sound()` - Contains all sound loading and volume control logic
- `state_transition(state_a, state_b)` - Handles transitioning between game states
- `load_graphics()` - Draws sprites, textures, etc.  

## Game Improvements

As of now, the game stands as a bug-free and enjoyable experience. It successfully captures the essence of a simplistic lunar lander, providing an immersive and entertaining gameplay experience.

### Minor Enhancements

Consideration is being given to several minor improvements that could enhance the player experience. For example, visual cues such as turning the velocity reading green when within an acceptable landing range.

### Long-Term Goals

A key improvement would be the implementation of a procedural level generation system. This system would inject variability into each playthrough, adding a layer of unpredictability and significantly improving the replay value. I am enthusiastic about the possibility of working on its implementation given sufficient free time in the future.


## Miscellaneous

In implementing the physics for the game, I utilized key Apollo 11 data extracted from [Lander Physics Data](https://nssdc.gsfc.nasa.gov/nmc/spacecraft/display.action?id=1969-059C):

- **Lander Mass**: 15,103 kg  
- **Lunar Gravity**: 1.6 m/s²
- **Lander Acceleration due to Gravity**: 1.6 m/s² 
- **Lunar Gravitational Force on Lander**: 24,164.8 N
- **Lander Descent Thruster Force**: 45,000 N
- **Total Lander Acceleration when Thrusters Fire**: -1.38 m/s²
- **Lander Maneuvering Thruster Force**: 450 N (4 modules, 4 nozzles = 7,200 N - not precisely accurate, but adjusted for gameplay)
- **Lander Maneuvering Thruster Acceleration**: 0.12 m/s²
- **Scale**: 1 pixel in the game is defined as a 1 meter square.


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
    - Video by [Ze Rubenator](https://www.youtube.com/watch?v=f9INvTu-gOI) on YouTube

**Fonts**
- [DSKY Fonts](https://github.com/ehdorrii/dsky-fonts) by [ehdorrii](https://github.com/ehdorrii) on GitHub

**Art & Assets**
- Lander and thruster pixel art made using [Piskel](https://www.piskelapp.com/)
- Splash Screen Background from [NASA Image Catalog](https://nssdc.gsfc.nasa.gov/imgcat/html/object_page/a11_h_44_6642.html)  
- Credits Background from [NASA History Site](https://history.nasa.gov/alsj/a11/AS11-40-5874HR.jpg)
- Background images retouched by [Leonardo.AI](https://app.leonardo.ai/)   

**Helpful Tutorials** 
- [CS50 Seminar](https://www.youtube.com/watch?v=iOA5YspoJDM)
- [General Love2D usage](https://www.youtube.com/watch?v=kpxkQldiNPU&list=PLqPLyUreLV8DrLcLvQQ64Uz_h_JGLgGg2)  
- [Line Intersection Video 1](https://www.youtube.com/watch?v=fHOLQJo0FjQ)
- [Line Intersection Video 2](https://www.youtube.com/watch?v=bvlIYX9cgls)  

**NASA Websites**  
- [Lander Physics Data](https://nssdc.gsfc.nasa.gov/nmc/spacecraft/display.action?id=1969-059C)  
- [Lunar Rock Characteristics](https://www.lroc.asu.edu/posts/157)

Shoutout to CS50 duck debugger [cs50.ai](cs50.ai) for tons of help and encouragement throughout development!

Inspired by a scene from [First Man (2018)](https://www.youtube.com/watch?v=TrvXqosqkls)


## Future Development

- Implement a procedural level generation system to elevate replay value.
- Turning velocity readings green when within a safe landing threshold.
- Break up `main.lua` into multiple files, as described above, to enhance code organization.
- Abstract out more logic into reusable functions, promoting code readability and reusability.