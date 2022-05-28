**Eve Reactor**

Welcome to Eve Reactor my Eve Online industry calculator.

I have put a lot of effort into building this application and also into playing eve online. But the time has come for me to move on in life and stop putting 40 hours of work/play every week into video games. So I am going to share this app even in it's unfinished state.

**Design**

Eve Reactor calculates cost & profit of building a set of items and also automatically schedules the build. Materials are bought from sell orders and products are sold to buy orders. Only the best orders from a set of systems (user specified) are used. Outputs are copy-pastable into a spreadsheet.

The automatic scheduler is the most important function of the app. It tells you exactly what jobs to start and when to start them. Note, I do not claim the output schedules are the most optimal way to do the builds in all situations. But, I think the scheduler is pretty good.

Currently, the web version does not work due to a bug in the persistence library I am using.

**Building**

This project is built with flutter and ortools.

To build and run the app use
`flutter run -d windows`
or
`flutter run -d chrome`

The scheduler uses google's ortools. To recompile the dll you must first install ortools then use visual studio >= 2019 to build the project in the directory `advanced_solver_cpp`. Yes the output DLL is called `WINDOWSISCOOL.dll`. That started as just a temporary name for testing but I am too lazy to change it now.

**Automatic scheduling solver**

On windows the advanced solver for automatic planning of industry jobs is available.
Here are a few notes on that.

So how does it work? The solver schedules jobs into **batches**. This is intended to give the user only a few login timepoints for restarting jobs and also it is intended to reduce the computational complexity of the problem. The general scheduling problem (for minimizing completion time) where jobs can start and end at arbitrary times is way too difficult computationally.

Two issues prevent this from being a straight forward scheduling problem. First, frame each run as a job and the input materials as dependent jobs, then you have a basic scheduling problem. But the issue is in the excess and reuse of excess. For example, A needs 1 C, B needs 1 C, C is produced in quantities of 2. So if A is built with or before B then only A has a dependent C job, B uses the excess C. The issue is that the job dependencies change based on how they are scheduled, I do not know any scheduling algorithms that can handle that kind of detail. Second, how do you optimally convert runs into jobs so that a general job scheduling algorithm can be used? If you use 1 job = 1 run, then you make a scheduling problem with a *large* amount of jobs. Which is not good because scheduling problems with tree like dependencies and parallel machines is NP-Hard. Thus the ortools and the custom algorithm.

If you start the solver while it is already solving then it restarts (stops/starts again).

If you start/stop the solver (or spam click start) very quickly then the threading code can get fucked up. This could be worked around but, meh, just don't do it....

Also, if you change any settings in the options pane then the solver stops.

The advanced solver can not be paused and started again. So once the solver stops then to continue solving the problem it must start from the initial unsolved state (solving starts over from scratch).

It is possible that produced schedules have some very short batches (1 hour to 3 hour batches). This is sort of undesirable but it happens. If you do not like it you can re-optimize and hope that ortools finds a more desirable schedule. (i think ortools solves in a non-deterministic way)

I unfortunately did not add a way to specify that batches should start or stop during user provided time intervals.

If you add ten thousand avatar runs and only have 1 reaction line and 1 manufacturing line then the scheduler gives up. Basically, the scheduler does not make schedules with more than 100 batches.

**UX quirks**

When the orders for items to be bought or sold at market are not available then the market module returns infinity for the cost or profit. So, if you add 999999 runs of **Paladin** to the build then you will see that the profit and cost are both negative.

Unfortunately the table headers do not have an indicator to show whether they are sorted ascending/descending or not sorted.

Changing the number of runs of an item while the targets table is sorted will cause the table to resort immediately and the input box you were typing into to loose focus. This is annoying and unexpected. Sorry.

Setting the build/buy option on intermediates naturally causes the contents of the intermediates table to change. This can be disorienting so I suggest to toggle build/buy from bottom to top!

![](img.jpg?raw=true)