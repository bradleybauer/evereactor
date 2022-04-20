# something tells me there are bugs here...
# this code basically 'disentangles' the individual bill of materials

# get map tid -> quantity where quantity is the amount of tid that needs to be purchased in order to do the build.
# schedule is a list of batches
# batch is a map tid->(runs,lines)
# [buildItems] is the item level build information
# The BOM (Bill Of Materials) is whatever is required by produced that is not supplied by inventory
def getTotalBOM(schedule, inventory, buildItems):
    produced = {}
    # if required is not initialized like this, then the following can occur:
    #   if sylFib is set to buy but is also a target then, consider where sylFib is produced in batch 0 and
    #   a consumer of sylFib is produced in batch 0 (for simpl there is only 1 batch). Then targetNumRuns of sylFib is set in
    #   produced and numAsDeps of sylFib is set in required. This causes targetNumRuns to cancel out some of numAsDeps
    #   (in return statement) which is not supposed to happen.
    required = {target:runs*bps[target].prodPerRun for (target,runs) in buildItems.targets} # produced target items cancel this out
    for batch in schedule:
        for tid, (runs,lines) in batch.items():
            produced[tid] = produced.get(tid,0) + bps[tid].prodPerRun * runs
            for mid, qtyPerRun in bps[tid].mats:
                required[mid] = required.get(mid,0) + getNumChildNeeded(qtyPerRun, runs, lines)
    result = max(0,required - produced - inventory)
    # remove items with zero required
    return result

# Compute the individual BOM's for each item in the total BOM where individual BOM's share the cost of common materials.
# ex: if A requires 1 C, B requires 1 C, C requires 1 D, and 1 run of C produces 2 C's.
#     Then A and B should share the cost of the 1 run of C and so the BOM for both A and B should contain .5 D's.
#     The sum of the D's in the individual BOM's equals the total D's in the BOM for the whole schedule (totalBOM).
# [schedule] is a list of batches
# [inventory] is a map tid -> quantity
# [buildItems] is the item level build information
def getBOMs(schedule, inventory, buildItems):
    # how much mid is needed by each parent of mid
    # mid -> (pid -> number mid needed by pid)
    # for any given mid, this can be seen as a tree where mid is the root.
    mid2numNeeded = {}

    # the total number of runs of tid scheduled
    # tid -> totalNumRuns
    totalRuns = {}

    # calculate mid2numNeeded and totalRuns
    for batch in schedule: # batch is a map tid->(runs,lines)
        for tid, (runs,lines) in batch.items():
            totalRuns[tid] = totalRuns.get(tid,0) + runs
            for mid, qtyPerRun in bps[tid].mats:
                if mid not in mid2numNeeded:
                    mid2numNeeded[mid] = {}
                mid2numNeeded[mid][tid] = mid2numNeeded[mid].get(tid, 0) + getNumChildNeeded(qtyPerRun, runs, lines) # parent wants numNeeded more of child

    # for items that are both dependents and targets we need to treat them differently
    for mid in mid2numNeeded:
        for pid,qty in mid2numNeeded[mid].items():
            if pid in buildItems.targets and pid in mid2numNeeded:
                fractionAsTarget = buildItems.targetsRuns[pid] / totalRuns[pid]
                # Creates a leaf in the tree since -pid is NOT in mid2numNeeded since it is not a mid (no material has negative id)
                mid2numNeeded[mid][-pid] = mid2numNeeded[mid][pid] * fractionAsTarget
                mid2numNeeded[mid][pid] *= (1-fractionAsTarget)

    # what fraction of the total number of mid does pid (parent) need?
    # mid -> (pid -> fraction)
    mid2fraction = {}
    # normalize the quantities
    for mid in mid2numNeeded:
        sum = 0
        for pid,qty in mid2numNeeded[mid].items():
            sum += qty
        for pid in mid2numNeeded[mid]:
            mid2fraction[mid] = mid2numNeeded[mid] / sum

    indivBOMs = {}
    for mid,qty in getTotalBOM(schedule, inventory, buildItems):
        for tid,share in getShare(mid, mid2fraction):
            tid = abs(tid) # in case tid is both target and dependency then tid is negative for target branch
            if tid not in indivBOMs:
                indivBOMs[tid] = {}
            indivBOMs[tid][mid] = share * qty

    return totalBOM, indivBOMs

# tid -> percent
# for each tid (target) what fraction of the total number of needed [mid] (material) is due to building tid?
def getShare(mid, mid2fraction):
    share = {}
    
    # if this item is a target
    if mid not in mid2fraction:
        return {mid:1.0}
    
    # share is a weighted combination of parent shares
    for pid,frac in mid2fraction[mid].items():
        for tid,subshare in getShare(pid,mid2fraction):
            share[tid] = share.get(tid,0) + frac * subshare

    return share
