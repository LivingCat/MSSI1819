# Carpool simulation with different matching algorithms

(This readme provides a simple summary of the work for a more detailed desciption you can consult the [scientific paper](https://github.com/LivingCat/MSSI1819/blob/master/Ride_Sharing_in_FEUP__Last_Assignment.pdf))

## Index

1. [Description](#description)
3. [Problem](#problem)
4. [Controls](#controls)
5. [Scenarios](#scenarios)
    1. [None](#none)
    2. [Random](#random)
    3. [Minimum distance](#minimum-distance)
    4. [Real Life](#real-life)
6. [Results](#results)
7. [Conclusion](#conclusion)
8. [Developers](#the-developers)
9. [Setup guide](#setup-guide)

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
In the demo's gifs you can see the differences between the matching algorithms:
* Circles - Highlight the cars being tracked
* Numbers - Stops in the order that the rider has made to pick up people (0 being the starting position)

For example in the [minimum distance algorithm](#minimum-distance) the stops that a rider makes are close to their starting position while in the [real life algorithm](#real-life) the rider is trying to have the least detour possible relative to the usual distance they make.

(Circles and Numbers on the demo's gifs added using a video editor)
### None
No matching is really used.
Every person that has a car, is a rider and goes in their car to the destination. Every person that doesn’t have a car is discarded.

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/none_gif.gif)
### Random
This matching algorithm only takes into consideration the number of seats available in the rider’s car.
For each rider:
* The algorithm selects capacity number of users, to fill all the available seats in the vehicle. Capacity is the number of available  eats in the rider’s vehicle

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/random_gif.gif)
### Minimum distance
For each rider:
* A triple is created with the rider, the potential passenger and the distance that that user pickup location is from the rider’s starting point;
* A list of all the potential triples is constructed.

With the final list we then order the elements of the list in ascending order and finally we start to process the list, assigning the passengers to the riders and assigning at most capacity passengers to each rider

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/min_distance_gif.gif)
### Real Life
This algorithm is the closest out of all 3 that mimics the aspects that any of us would take into consideration when practicing ride sharing in our everyday life. 
This algorithm takes into consideration 3 factors:
* The existing relationship between a rider and the potential passenger, such as friends or students that enrolled in the same year and same degree.
* The detour the rider would need to make to pick the passenger up, in terms of distance the rider would need to make, in comparison with the usual distance they make;
* How many seats are available/ how full the vehicle is

![](https://github.com/LivingCat/MSSI1819/blob/master/docs/real_life_gif.gif)

## Results
![](https://github.com/LivingCat/MSSI1819/blob/master/Result%20Analysis/Charts/cars_speed.png)
![](https://github.com/LivingCat/MSSI1819/blob/master/Result%20Analysis/Charts/co_emissions.png)
![](https://github.com/LivingCat/MSSI1819/blob/master/Result%20Analysis/Charts/riders_willingness.png)

## Conclusion
The best of the alternatives we have presented in this work, is the Minimum Distance, if we only take into consideration the results of the emissions. 

However this alternative doesn’t consider the willingness of the driver to make that ride, for example in real life everyone takes into consideration the person or people with who they would share their ride with and how great is the detour.

Taking into consideration those factors the Real Life alternative is good, since it reduces the number of riders on the road compared to the scenario representing the population right now, which leads to a higher average speed of the cars with a lower traffic volume, for a higher volume of users, the reduction
in CO emissions is also noticeable

## The Developers

- [Catarina Ferreira](https://github.com/LivingCat)
- [Gil Teixeira](https://github.com/GilTeixeira)
- [Tiago Neves](https://github.com/Tiago-Seven)

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
