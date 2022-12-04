# xakra_waterpump
## Requirements
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [vorp_inputs](https://github.com/VORPCORE/vorp_inputs-lua)

## Description
With this script players will be able to pump water into the water pumps. They will be able to choose the number of empty bottles they want to fill, and the character will do the animation of pumping water. A bottle will appear under the water.

With this script it can also be used to drink water, improving the animation. (To use it you have to remove the water from your metabolism script)

Players will be warned that they are hungry or thirsty, with a notification and screen effect every 30s. (VORP METABOLISM only)

In the Config file you can configure:
-   Key to pump water
-   Vorp progress bar color
-   Name of the empty bottle and water item
-   Enable or disable drink water option with this script
-   Amount of thirst that the water will give
-   Probability of returning an empty bottle
-   Enable or disable metabolism notifications when hungry or thirsty (VORP METABOLISM only)
-   All script texts

## Instructions to incorporate script
-   Copy the script into a folder (to choose) from the 'resources' folder.
-   Add 'ensure xakra_waterpump' in the 'Resources.cfg' document

Video: https://youtu.be/Ys8IwgCLM7I