#include <windows.h>

#include "event_loop.h"
#include "ffi_conversions.h"
#include "ffi_types.h"
#include "problem.h"

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
  switch (ul_reason_for_call) {
  case DLL_PROCESS_ATTACH:
    break;
  case DLL_THREAD_ATTACH:
    break;
  case DLL_PROCESS_DETACH:
    break;
  case DLL_THREAD_DETACH:
    break;
  default:
    break;
  }
  return TRUE;
}

EventLoop event_loop{};

#define EXPORT extern "C" __declspec(dllexport)

// clang-format off
// callers: dart messenger isolate
EXPORT void startWorker(void (*publishSolution)(struct FfiSchedule* x),
                        void (*notifyStopped)(),
                        struct FfiProblem problem) {
  //std::cout << "in startWorker : " << publishSolution << std::endl;
  // dart free's this FfiSchedule
  Problem p = ffi2cpp_problem(problem);
  //std::this_thread::sleep_for(std::chrono::hours(12211));
  event_loop.start(p,
                   [&](Schedule schedule) { publishSolution(make_schedule(schedule)); },
                   // dart will free the schedule created here.. i think.
                   // i apply dart's free to the memory i give it so. i guess it should work.
                   // it does not crash so that's a good sign lol.
                   notifyStopped);
}
// clang-format on

// callers: ui isolate
EXPORT void stopWorker() { event_loop.stop(); }
