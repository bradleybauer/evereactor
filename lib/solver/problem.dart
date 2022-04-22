// TODO max number of runs per slot depends on all time efficiency modifiers
//      maybe will not worry about this. in most real use cases this will not come into effect... I hope.
//      at least it will not for my use cases, which is producing tons of ships and all the intermediates in excess.
import '../models/industry_type.dart';
import '../models/inventory.dart';
import '../sde_extra.dart';

class Problem {
  final Map<int, int> runsExcess; // buildItems
  final Set<int> tids; // buildItems
  final Map<int, Map<int, int>> dependencies; // build
  final Inventory inventory;
  final Map<IndustryType, int> maxNumSlotsOfMachine; // buildOptions
  final Map<int, int> maxNumSlotsOfJob; // buildItems // limits number of blueprints used for a job type
  final Map<int, int> maxNumRunsPerSlotOfJob; // buildItems // limits number of runs on any blueprint for a job type
  final Map<int, double> jobMaterialBonus; // buildItems & buildOptions
  final Map<int, double> jobTimeBonus; // buildItems & buildOptions
  final int float2int; // idk yet, ircc can be dynamically computed

  // functions of constructor args
  late final Set<IndustryType> machines;
  late final Map<int, IndustryType> job2machine;
  late final bool M2DependsOnM1;

  int? minNumBatches;
  int? maxNumBatches;
  int? maxNumRuns;
  int? minNumRuns;
  int? completionTimeUpperBound;
  int? completionTimeLowerBound;
  int? inverseDependencies;
  int? timesGCD;

  // int? scheduleCompletionTime;
  // int? approximationBatches;
  // int? approximationTime;

  Problem({
    required this.runsExcess,
    required this.tids,
    required this.dependencies,
    required this.inventory,
    required this.maxNumSlotsOfMachine,
    required this.maxNumSlotsOfJob,
    required this.maxNumRunsPerSlotOfJob,
    required this.jobMaterialBonus,
    required this.jobTimeBonus,
    this.float2int = 1000,
  }) {
    job2machine = Map.fromEntries(tids.map((tid) => MapEntry(tid, SD.industryType(tid))));
    machines = tids.map((tid) => SD.industryType(tid)).toSet();

    // for each item, not all its dependencies have the same machine as the item
    M2DependsOnM1 = !dependencies.entries
        .every((parent) => parent.value.entries.every((child) => job2machine[child.key] == job2machine[parent.key]));
  }
//     @staticmethod
//     def M2AndM1WithDeps():
//         runsExcess = {2: 2}
//         madePerRun = {1: 1, 2: 1}
//         timePerRun = {1: 3600, 2: 3600}
//         dependencies = {2: {1: 1}}
//         job2machine = {1: 'M1', 2: 'M2'}
//         maxNumSlots = {'M1': 1, 'M2': 1}
//         maxNumSlotsPerJob = 1
//         machineBonusFloat = 0
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def real():
//         madePerRun = {
//             1: 1,
//             2: 1,
//             3: 1,
//             4: 1,
//             5: 1,
//             6: 1,
//             7: 1,
//             8: 1,
//             9: 1,
//             10: 10000,
//             11: 2200,
//             12: 400,
//             13: 1500,
//             14: 750,
//             15: 300,
//             16: 6000,
//             17: 200,
//             18: 3000,
//             19: 200,
//             20: 200,
//             21: 200,
//             22: 200,
//             23: 200,
//             24: 200,
//             25: 200,
//             26: 200,
//             27: 200,
//             28: 200,
//             29: 200,
//             30: 200,
//             31: 200,
//             32: 200,
//             33: 200,
//             34: 200,
//             35: 200
//         }
//         timePerRun = {
//             1: (3 * 24 + 11) * 3600 + 20 * 60,
//             2: 2 * 60 + 30,
//             3: 2 * 60 + 30,
//             4: 60 + 15,
//             5: 25,
//             6: 5 * 60,
//             7: 2 * 60 + 30,
//             8: 2 * 60 + 30,
//             9: 4 * 3600 + 10 * 60
//         } | {i: 3 * 3600
//              for i in range(10, 35 + 1)}
//         dependencies = {
//             1: {
//                 2: 120,
//                 3: 495,
//                 4: 2100,
//                 5: 10500,
//                 6: 53,
//                 7: 900,
//                 8: 600,
//                 9: 1
//             },
//             2: {
//                 10: 13,
//                 11: 3,
//                 12: 1
//             },
//             3: {
//                 10: 22,
//                 13: 1,
//                 14: 2
//             },
//             4: {
//                 10: 17,
//                 11: 6,
//                 13: 2,
//                 15: 2
//             },
//             5: {
//                 10: 44,
//                 16: 11
//             },
//             6: {
//                 10: 9,
//                 17: 2
//             },
//             7: {
//                 10: 27,
//                 18: 11,
//                 13: 1,
//                 15: 2
//             },
//             8: {
//                 10: 22,
//                 16: 9,
//                 12: 1
//             },
//             10: {
//                 19: 100,
//                 20: 100
//             },
//             11: {
//                 21: 100,
//                 22: 100,
//                 23: 100
//             },
//             12: {
//                 24: 100,
//                 25: 100,
//                 26: 100,
//                 27: 100
//             },
//             13: {
//                 28: 100,
//                 29: 100,
//                 30: 100
//             },
//             14: {
//                 31: 100,
//                 32: 100,
//                 23: 100
//             },
//             15: {
//                 19: 100,
//                 33: 100
//             },
//             16: {
//                 34: 100,
//                 24: 100
//             },
//             17: {
//                 22: 100,
//                 32: 100,
//                 35: 100,
//                 27: 100
//             },
//             18: {
//                 20: 100,
//                 29: 100
//             }
//         }
//         job2machine = {i: 'M2' for i in range(1, 9 + 1)} | {i: 'M1' for i in range(10, 35 + 1)}
//         runsExcess = {
//             1: 8,
//             10: 250,
//             11: 250,
//             12: 250,
//             13: 250,
//             14: 250,
//             15: 250,
//             16: 250,
//             17: 250,
//             18: 250,
//         }
//         maxNumSlots = {'M1': 150, 'M2': 50}
//         maxNumSlotsPerJob = 25
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     def realWithInv():
//         madePerRun = {
//             1: 1,
//             2: 1,
//             3: 1,
//             4: 1,
//             5: 1,
//             6: 1,
//             7: 1,
//             8: 1,
//             9: 1,
//             10: 10000,
//             11: 2200,
//             12: 400,
//             13: 1500,
//             14: 750,
//             15: 300,
//             16: 6000,
//             17: 200,
//             18: 3000,
//             19: 200,
//             20: 200,
//             21: 200,
//             22: 200,
//             23: 200,
//             24: 200,
//             25: 200,
//             26: 200,
//             27: 200,
//             28: 200,
//             29: 200,
//             30: 200,
//             31: 200,
//             32: 200,
//             33: 200,
//             34: 200,
//             35: 200
//         }
//         timePerRun = {
//             1: (3 * 24 + 11) * 3600 + 20 * 60,
//             2: 2 * 60 + 30,
//             3: 2 * 60 + 30,
//             4: 60 + 15,
//             5: 25,
//             6: 5 * 60,
//             7: 2 * 60 + 30,
//             8: 2 * 60 + 30,
//             9: 4 * 3600 + 10 * 60
//         } | {i: 3 * 3600
//              for i in range(10, 35 + 1)}
//         dependencies = {
//             1: {
//                 2: 120,
//                 3: 495,
//                 4: 2100,
//                 5: 10500,
//                 6: 53,
//                 7: 900,
//                 8: 600,
//                 9: 1
//             },
//             2: {
//                 10: 13,
//                 11: 3,
//                 12: 1
//             },
//             3: {
//                 10: 22,
//                 13: 1,
//                 14: 2
//             },
//             4: {
//                 10: 17,
//                 11: 6,
//                 13: 2,
//                 15: 2
//             },
//             5: {
//                 10: 44,
//                 16: 11
//             },
//             6: {
//                 10: 9,
//                 17: 2
//             },
//             7: {
//                 10: 27,
//                 18: 11,
//                 13: 1,
//                 15: 2
//             },
//             8: {
//                 10: 22,
//                 16: 9,
//                 12: 1
//             },
//             10: {
//                 19: 100,
//                 20: 100
//             },
//             11: {
//                 21: 100,
//                 22: 100,
//                 23: 100
//             },
//             12: {
//                 24: 100,
//                 25: 100,
//                 26: 100,
//                 27: 100
//             },
//             13: {
//                 28: 100,
//                 29: 100,
//                 30: 100
//             },
//             14: {
//                 31: 100,
//                 32: 100,
//                 23: 100
//             },
//             15: {
//                 19: 100,
//                 33: 100
//             },
//             16: {
//                 34: 100,
//                 24: 100
//             },
//             17: {
//                 22: 100,
//                 32: 100,
//                 35: 100,
//                 27: 100
//             },
//             18: {
//                 20: 100,
//                 29: 100
//             }
//         }
//         inventory = {i: 10000 for i in madePerRun}
//         job2machine = {i: 'M2' for i in range(1, 9 + 1)} | {i: 'M1' for i in range(10, 35 + 1)}
//         runsExcess = {1: 8, 10: 204, 11: 204, 13: 204, 14: 204, 15: 204, 16: 204, 18: 204}
//         maxNumSlots = {'M1': 150, 'M2': 50}
//         maxNumSlotsPerJob = 20
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        inventory=inventory,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def prob1():
//         runsExcess = {
//             1: 400,
//             2: 400,
//             3: 400,
//             4: 400,
//             5: 250,
//             6: 400,
//         }
//         dependencies = {
//             1: {
//                 7: 100,
//                 8: 100,
//             },
//             2: {
//                 9: 100,
//                 10: 100,
//             },
//             3: {
//                 11: 100,
//                 12: 100,
//             },
//             4: {
//                 13: 100,
//                 14: 100,
//                 15: 100,
//             },
//             5: {
//                 16: 200,
//                 17: 1,
//                 18: 200,
//             },
//             6: {
//                 19: 100,
//                 20: 100,
//                 21: 100,
//                 22: 100,
//             },
//         }
//         madePerRun = {
//             1: 1,
//             2: 1,
//             3: 1,
//             4: 1,
//             5: 1,
//             6: 1,
//             7: 200,
//             8: 200,
//             9: 200,
//             10: 200,
//             11: 200,
//             12: 200,
//             13: 200,
//             14: 200,
//             15: 200,
//             16: 200,
//             17: 10,
//             18: 200,
//             19: 200,
//             20: 200,
//             21: 200,
//             22: 200,
//         }
//         timePerRun = {i: 3 * 3600 for i in madePerRun}
//         inventory = {19: 300, 9: 841, 21: 32, 13: 98}
//         job2machine = {i: 'M1' for i in madePerRun}
//         maxNumSlots = {'M1': 150, 'M2': 150}
//         maxNumSlotsPerJob = 10
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        inventory=inventory,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def prob2():
//         runsExcess = {
//             1: 124,
//             2: 90,
//             4: 682,
//             5: 429,
//             6: 133,
//             7: 200,
//             8: 500,
//             9: 682,
//             10: 300,
//             11: 400,
//             12: 73,
//         }
//         dependencies = {
//             1: {
//                 2: 3,
//                 3: 5,
//             },
//             2: {
//                 3: 2,
//             },
//             3: {
//                 4: 1
//             },
//             10: {
//                 9: 2,
//             }
//         }
//         madePerRun = {
//             1: 1,
//             2: 2,
//             3: 1,
//             4: 1,
//             5: 3,
//             6: 1,
//             7: 1,
//             8: 1,
//             9: 1,
//             10: 1,
//             11: 4,
//             12: 1,
//         }
//         timePerRun = {
//             1: 2 * 3600,
//             2: 3600,
//             3: 3600,
//             4: 3600 // 4,
//             5: 3600 // 4,
//             6: 3600 // 4,
//             7: 3600 // 4,
//             8: 3600 // 4,
//             9: 3600 // 2,
//             10: 2 * 3600,
//             11: 3600 // 4,
//             12: 3600 // 4,
//         }
//         inventory = {
//             2: 300,
//         }
//         job2machine = {i: 'M1' for i in madePerRun}
//         maxNumSlots = {'M1': 150}
//         maxNumSlotsPerJob = 10
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        inventory=inventory,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def prob3():
//         runsExcess = {
//             1: 124,
//             2: 90,
//             4: 682,
//             5: 429,
//             6: 133,
//             7: 200,
//             8: 500,
//             9: 682,
//             10: 300,
//             11: 400,
//             12: 73,
//         }
//         dependencies = {
//             1: {
//                 2: 3,
//                 3: 5,
//             },
//             2: {
//                 3: 2,
//             },
//             3: {
//                 4: 1
//             },
//             10: {
//                 9: 2,
//             }
//         }
//         madePerRun = {
//             1: 1,
//             2: 2,
//             3: 1,
//             4: 1,
//             5: 3,
//             6: 1,
//             7: 1,
//             8: 1,
//             9: 1,
//             10: 1,
//             11: 4,
//             12: 1,
//         }
//         timePerRun = {
//             1: 3 * 3600,
//             2: 3 * 3600,
//             3: 3 * 3600,
//             4: 3 * 3600,
//             5: 3 * 3600,
//             6: 3 * 3600,
//             7: 3 * 3600,
//             8: 3 * 3600,
//             9: 3 * 3600,
//             10: 3 * 3600,
//             11: 3 * 3600,
//             12: 3 * 3600,
//         }
//         inventory = {
//             2: 300,
//         }
//         job2machine = {i: 'M1' for i in madePerRun}
//         maxNumSlots = {'M1': 150}
//         maxNumSlotsPerJob = 25
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        inventory=inventory,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def prob4():
//         runsExcess = {1: 102, 2: 102}
//         madePerRun = {1: 1, 2: 1, 3: 1}
//         timePerRun = {1: 3600, 2: 3600, 3: 3600}
//         dependencies = {1: {3: 100}}
//         job2machine = {i: 'M1' for i in madePerRun}
//         inventory = {3: 500}
//         maxNumSlots = {'M1': 150}
//         maxNumSlotsPerJob = 10
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        inventory=inventory,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def onlyM():
//         runsExcess = {1: 4}
//         madePerRun = {1: 1}
//         timePerRun = {1: 3600}
//         dependencies = {}
//         job2machine = {1: 'M2'}
//         maxNumSlots = {'M2': 1}
//         maxNumSlotsPerJob = 1
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def onlyMDep():
//         runsExcess = {1: 4}
//         madePerRun = {1: 1, 2: 1}
//         timePerRun = {1: 3600, 2: 3600}
//         dependencies = {1: {2: 1}}
//         job2machine = {1: 'M2', 2: 'M2'}
//         maxNumSlots = {'M2': 1}
//         maxNumSlotsPerJob = 1
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def MAndR():
//         runsExcess = {1: 2, 2: 2}
//         madePerRun = {1: 1, 2: 1}
//         timePerRun = {1: 3600, 2: 3600}
//         job2machine = {1: 'M1', 2: 'M2'}
//         maxNumSlots = {'M1': 1, 'M2': 1}
//         maxNumSlotsPerJob = 1
//         machineBonusFloat = .022
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
//
//     @staticmethod
//     def rand():
//         N = 40  #TODO i think there is an infinite loop in here when N is small (N==4)
//         # runsExcess = {i+1 : random.randint(1,800) for i in range(N//4)}
//         runsExcess = {i + 1: random.randint(1, 800) for i in range(N // 4)}
//         madePerRun = {i + 1: random.randint(1, 200) for i in range(N)}
//         # timePerRun = {i+1 : random.randint(3600 // 4, 12 * 3600 // 4) for i in range(N)}
//         timePerRun = {i + 1: random.randint(1, 12 * 3600 // 4) for i in range(N)}
//
//         referencedItems = set()
//         for k in runsExcess:
//             referencedItems.add(k)
//
//         # Add zero to 5 dependency trees
//         dependencies = {}
//         for i in range(random.randint(0, 5)):
//             if len(referencedItems) >= N - 1:  # Node N is a special node that is never a parent
//                 break
//             # Pick a parent at random that we have not seen yet
//             p = random.choice(list(referencedItems))
//             while p in dependencies or p == N:  # TODO this is a BUG, it is causing inf loops
//                 p = random.choice(list(referencedItems))
//
//             # Pick up to two children at random
//             cs = {}
//             for _ in range(random.randint(1, 2)):
//                 c = random.randint(p + 1, N)
//                 referencedItems.add(c)
//                 cs[c] = random.randint(1, 200)
//
//             dependencies[p] = cs
//
//         # Filter unused items
//         for i in range(1, N + 1):
//             if i not in referencedItems:
//                 del madePerRun[i]
//                 del timePerRun[i]
//                 if i in runsExcess:
//                     del runsExcess[i]
//
//         # Add a bit of inventory
//         inventory = {}
//         if len(dependencies) > 0:
//             possibleInventoryItems = set()
//             for parent in dependencies:
//                 for child in dependencies[parent]:
//                     possibleInventoryItems.add(child)
//             for i in range(random.randint(0, len(possibleInventoryItems))):
//                 c = random.choice(list(possibleInventoryItems))
//                 possibleInventoryItems.remove(c)
//                 inventory[c] = random.randint(1, 50 * madePerRun[c])
//
//         job2machine = {i: 'M1' for i in madePerRun}
//         maxNumSlots = {'M1': random.randint(1, 150)}
//         maxNumSlotsPerJob = random.randint(1, min(30, maxNumSlots['M1']))
//         machineBonusFloat = random.randint(1, 50) / 1000  # 0 to 5%
//         return Problem(runsExcess=runsExcess,
//                        madePerRun=madePerRun,
//                        timePerRun=timePerRun,
//                        job2machine=job2machine,
//                        dependencies=dependencies,
//                        inventory=inventory,
//                        maxNumSlots=maxNumSlots,
//                        maxNumSlotsPerJob=maxNumSlotsPerJob,
//                        machineBonusFloat=machineBonusFloat)
}
