# phase-based-itd-from-hrir

on the [sadie-ii database](https://www.york.ac.uk/sadie-project/database.html), there are some really cool graphs that show the interaural time difference (ITD) of each sofa file. but, they seem really sinusoidal, don't they?

we know the woodworth model for calculating ITD is:

$ITD = (a/c)(\theta + sin(\theta))$ for $[0 \leq \theta \leq \pi / 2]$

and

$ITD = (a/c)(\pi - \theta + sin(\theta))$ for $[\pi / 2 \leq \theta \leq \pi]$

where $a$ is head radius, $c$ is speed of sound, and $\theta$ is azimuth.

well, we also know that for sufficiently small values of $\theta$, $sin(\theta) \approx \theta$. so, overall, graphing a woodworth model would generally look like a piecewise function of linear relationships, not this smooth sine shape. what, then, does this smooth sine shape on their website represent, and how do we calculate it?

chances are that they are graphing the ITD weighted across a band of frequencies. after all, that's a great amount of information they're representing, and it's much easier to do that from a sofa file which has a recorded head-related impulse responses (HRIR) than it is to simulate a HRIR from the spherical model of the woodworth model. how do we get the ITD from a bunch of frequencies?

it's phase. you read the name of this repo, it's phase.
