#include <windows.h>

#include "event_loop.h"
#include "ffi_conversions.h"
#include "ffi_types.h"
#include "problem.h"

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
  switch (ul_reason_for_call) {
  case DLL_PROCESS_ATTACH:
    // print("process attach");
    break;
  case DLL_THREAD_ATTACH:
    // print("thread attach");
    break;
  case DLL_PROCESS_DETACH:
    // print("process detach");
    break;
  case DLL_THREAD_DETACH:
    // print("thread detach");
    break;
  default:
    // print("default");
    break;
  }
  return TRUE;
}

EventLoop event_loop{};

#define EXPORT extern "C" __declspec(dllexport)

// clang-format off
// callers: dart messenger isolate
EXPORT void startWorker(void (*submitSchedule)(struct FfiSchedule x),
                        void (*notifyStopped)(),
                        struct FfiProblem problem) {
    std::cout << "in startWorker" << std::endl;
    Problem p = ffi2cpp_problem(problem);
    p.print();
    std::this_thread::sleep_for(std::chrono::minutes(12211));
  event_loop.start(p,
                   [&](Schedule schedule) {
                       submitSchedule(*make_schedule(schedule));
                   },
                   notifyStopped);
}
// clang-format on

// callers: ui isolate
EXPORT void stopWorker() { event_loop.stop(); }