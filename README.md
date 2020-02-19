Gossip-Simulator
---
## Step to compile the code
---
```
 cd gossip-simulator/
 mix escript.build
```

## Step to run the code
---
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
---
| Topology        | Gossip    |  Push_sum |
| --------   | -----:   | :----: |
|   full    |   4000  |   1000  |
|  line   |   10000  |   600  |
|rand2D  |   2000  |   1000  |
|3Dtorus  |   10000  |   2000  |
|honeycomb  |   5000  |   1000  |
|randhoneycomb  |   5000  |   1000  |



