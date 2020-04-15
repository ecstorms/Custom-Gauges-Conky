# Custom-Gauges-Conky
This repository contains the conky script and corresponding python code for this conky setup: https://www.reddit.com/r/Conkyporn/comments/fwfzw9/conky_desktop_with_custom_gaugesprogress_bars/

The basic idea is that the conky script calls the python program, which then collects system information and updates the images the conky displays.  

Unfortunately, I can't share the image files for the custom gauges I use because I got them from Adobe Stock, which prohibits redistribution.  So none of this code will run out of the box; you will need to create your own image files for the conky to diplay.  Also, note that having conky update large images every few seconds can use a fair amoung of computer resources -- if you are running on a slower system, I recommend increasing the conky update interval. 


