Gossip-Simulator
---
# Gossip Simulator
## Gossip Algorithm for information propagation
The Gossip algorithm involves the following:
• Starting: A participant(actor) it told/sent a rumor(fact) by the main process
• Step: Each actor selects a random neighbor and tells it the rumor
• Termination: Each actor keeps track of rumors and how many times it has
heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, you can play with other numbers or other stopping criteria).

------------

## Topologies
The actual network topology plays a critical role in the dissemination speed of Gossip protocols. As part of this project you have to experiment with various topologies. The topology determines who is considered a neighbor in the above algorithms.
• Full Network: Every actor is a neighbor of all other actors. That is, every actor can talk directly to any other actor.
• Line: Actors are arranged in a line. Each actor has only 2 neighbors (one left and one right, unless you are the first or last actor).
• Random 2D Grid: Actors are randomly position at x, y coordinates on a [0- 1.0] x [0-1.0] square. Two actors are connected if they are within .1 distance to other actors.
• 3D torus Grid: Actors form a 3D grid. The actors can only talk to the grid neighbors. And, the actors on outer surface are connected to other actors on opposite side, such that degree of each actor is 6.
• Honeycomb: Actors are arranged in form of hexagons. Two actors are connected if they are connected to each other. Each actor has maximum degree 3.
 Honeycomb with a random neighbor: Actors are arranged in form of hexagons (Similar to Honeycomb). The only difference is that every node has one extra connection to a random node in the entire network.
 

------------

 ## Step to compile the code

```
 cd gossip-simulator/
 mix escript.build
```

## Step to run the code

- For Linux
```
 cd proj2
 ./proj2 numNode topology algorithm
```
- For Windows
```
 cd proj2
 escript proj2 numNode topology algorithm
```
For argument topology, full, line, rand2D, 3Dtorus, honeycomb and randhoneycomb is allowed.
For argument algorithm, gossip, push-sum is allowed.
##The largest network we've tested

| Topology        | Gossip    |  Push_sum |
| --------   | -----:   | :----: |
|   full    |   4000  |   1000  |
|  line   |   10000  |   600  |
|rand2D  |   2000  |   1000  |
|3Dtorus  |   10000  |   2000  |
|honeycomb  |   5000  |   1000  |
|randhoneycomb  |   5000  |   1000  |



