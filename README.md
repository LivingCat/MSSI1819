# Carpool simulation with different matching algorithms

(This readme provides a simple summary of the work for a more detailed desciption you can consult the [scientific paper](https://github.com/LivingCat/MSSI1819/blob/master/Ride_Sharing_in_FEUP__Last_Assignment.pdf))
(Setup guide [here](#setup-guide))

## Description
This project aims to simulate the way a closed community comes to the same destination currently and simulate the impact that different matching techniques have regarding the emissions of harmful gases to our atmosphere.

The matching techniques used are random, closest to starting point and a ”real life” algorithm that combines using the relationships between the rider and its passengers (friends, colleagues of the same year, colleagues of the same course and other students) and the detour distance added to the rider’s regular path.

Our simulation uses the software NetLogo and the model Traffic Grid Goal which simulates traffic moving in a city grid.

## Problem

In this project the main problem we are tackling is how to reduce the emissions of pollutant gases with the use of ride sharing in a closed community in which users are commuting to same destination but with different starting points. As a secondary goal we will also analyse, the different matching algorithms effect on the traffic and the ”happiness” of the rider to give the ride to the people matched to him 

## Controls

In the controls you can change the number of people from each cluster to be "placed into the world" and the matching algorithm to be used

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/controls.png)

## Scenarios
//TODO
### Random
//TODO
### Minimum distance
//TODO
### Real Life
//TODO

## Setup guide
### Opening the project

Open NetLogo.  
Click on the separator `File`.  
Select the option `Open...`.  
Select the file `NetLogo/Traffic Grid Goal.nlogo`.  

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/open.gif)

---

### Running the Project

Follow the Opening the project guide.  
Change the size for each cluster and the desired algorithm.  
Press the `Setup` button.  
Start the simulation by pressing the `Go` button.   

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/run.gif)
---

### Running the Experiments

Follow the Opening the project guide.  
Click on the separator `Tools`.  
Select the option `BehaviorSpace`.  
Select the Experiment with the desired number of people.  
Edit the Experiment, by pressing the `Edit` Button.  
&nbsp;&nbsp;&nbsp;&nbsp;Change the size of each cluster.  
&nbsp;&nbsp;&nbsp;&nbsp;Change the number of runs.  
&nbsp;&nbsp;&nbsp;&nbsp;Change the matching algorithm.  
&nbsp;&nbsp;&nbsp;&nbsp;Press the `Ok` button at the end.    
Press the `Run` button.   
Choose the output files location.  

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/exp.gif)
---


### The Developers

- [Catarina Ferreira](https://github.com/LivingCat)
- [Gil Teixeira](https://github.com/GilTeixeira)
- [Tiago Neves](https://github.com/Tiago-Seven)
