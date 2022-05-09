#pragma once

#include "event_loop.h"
#include "ffi_types.h"
#include "problem.h"

Problem ffi2cpp_problem(struct FfiProblem problem);

FfiSchedule* make_schedule(Schedule schedule);
void destroy_schedule(FfiSchedule* schedule);