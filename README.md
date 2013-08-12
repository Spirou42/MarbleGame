# MarbleGame
A simple Game about marbles and gravity.

==========



## Game description
The player has to clear a levels from all active Marbles by creating clusters of 3 or more marbles of the same "marble type" (ThreeInARow-Game ).  
The player throws/releases marbles into the level. Afterwards gravity takes over and the marble plungs and rolls to its final destination. If three or more marbles of the same type collied or have colided in a short amount of time, these marbles are removed from the level.  

### Collisions 
While the "real" collision of the physics engine are hasty, collisions are made more persistent by measuring the time between collisions. This makes it possible allow the play ball to hit a single marble and afterwards (while moving fast) another marble or a cluster of two marbles.

	     *
	         			 *				                         Multi
	**____*			**___*			**__*_*		    ***___*      _______

The measured time is also used to comment on the style of the throws and can be used by the score unit to add multipliers.

### Game modes 
There will be different ways to play MarbleGame.

* Normal
 	+ The higher the score the better. Each level has a three score limits [min; normal; master]. 
 		1. Score < min  
 			Level not finished.
 		2. min < Score < normal  
 			Level finished as *Amateur*
 		3. normal < Score < master  
 			Level finished as *Professional*
 		4. master < Score  
 			Level finished as *Master*	
* Time 
 	+ Create as much points in a given amount of time by clearing the level as fast as possible.  
 	Each level has tree time limits [master; normal; max].
		1. LevelTime < master  
			Level finished as *Master*
		2. normal > LevelTime > master
			Level finished as *Professional*
		3. max > LevelTime > normal  
			Level finished as *Amateur*
		4. Leveltime > max  
			Level not finished

* Relaxed 
 	- Removing all marbles no matter how long it takes or how many points you create. All  level limit (win/loos conditions) are turned off. The score and level time are recorded for statistical reasosn only :)


### How to score.

1. Each dropped Marble costs 1 point
2. creating a simple (3-Marble) cluster without any modifier will add 3 points.  
--> dropping marbles and removing them without any finess will not increase the score.
3. The time it took to create the a "hit" will add a multiplyer to the score.
4. Creating a 

