#pragma once

// Fraction
struct FfiFraction {
  int numerator;
  int denominator;
};
// Map<int,Fraction>
struct i2fracEntry {
  int key;
  struct FfiFraction value;
};
struct i2frac {
  int size;
  struct i2fracEntry* entries;
};
// Map<int,int>
struct i2iEntry {
  int key;
  int value;
};
struct i2i {
  int size;
  struct i2iEntry* entries;
};
// Map<int,Map<int,int>>
struct i2i2iEntry {
  int key;
  struct i2i value;
};
struct i2i2i {
  int size;
  struct i2i2iEntry* entries;
};
enum MachineType {
  REACTION_ = 0,
  MANUFACTURING_ = 1,
};
//// Schedule
// BatchItem
struct batchItem {
  int runs;
  int slots;
  struct FfiFraction time;
};
// Batch is basically just a Map<int,BatchItem>
struct i2batchItemEntry {
  int key;
  struct batchItem value;
};
struct batch {
  int size;
  struct i2batchItemEntry* entries;
};
struct batchList {
  int size;
  struct batch* entries;
};
// Map<int,List<Batch>>
struct k2batchesEntry {
  enum MachineType key;
  struct batchList value;
};
struct k2batches {
  int size;
  struct k2batchesEntry* entries;
};
// Schedule
struct FfiSchedule {
  struct k2batches machine2batches;
  double time;
  int optimal;
  int infeasible;
};
// Problem
struct FfiProblem {
  struct i2i runsExcess;
  int* tids; // num tids == num madePerRuns?
  struct i2i madePerRun;
  struct i2i timePerRun;
  struct i2i job2machine;
  struct i2i2i dependencies;
  struct i2i inventory;
  struct i2i maxNumSlotsOfMachine;
  struct i2i maxNumSlotsOfJob;
  struct i2i maxNumRunsPerSlotOfJob;
  struct i2frac materialBonus;
  struct i2frac timeBonus;
  int float2int;
  struct FfiSchedule* approximation; // pointer since this is optional
};

// void startWorker(void (*submitSchedule)(struct FfiSchedule x), void (*notifyStopped)(), struct FfiProblem problem);
// void stopWorker();