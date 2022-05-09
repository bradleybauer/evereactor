#pragma once

#include <condition_variable>
#include <optional>
#include <queue>
#include <thread>

#include "problem_solver.h"
#include "schedule.h"

struct Message {
  std::optional<Problem> problem;
  std::optional<Schedule> schedule;
  bool should_quit = false;
};

class EventLoop {
public:
  // callers: dart messenger isolate
  void start(Problem p, std::function<void(Schedule schedule)> submitSchedule, std::function<void()> notifyStopped) {
    std::cout << "in EventLoop::start" << std::endl;
    // start worker
    workerThread = std::thread([&]() {
      ProblemSolver solver(p, [&](std::optional<Schedule> schedule) {
        const bool should_quit = !schedule.has_value() || schedule.value().optimal || schedule.value().infeasible;
        post({.schedule = schedule, .should_quit = should_quit});
      });
      // blocks until ortools solver finishes (finds the optimal solution or determines if the problem is infeasible)
      solver.solve();
    });
    workerThread.detach();

    event_loop();
  }

  // callers: dart ui isolate & worker thread
  void stop() {
    mtx.lock();
    schedules.push_front({.should_quit = true});
    mtx.unlock();
    cond.notify_all();
    if (workerThread.joinable()) { // empty thread is not joinable
      workerThread.join();
    }
    // TODO call into dart to notify stopped
  }

  // callers: worker thread
  void post(Message message) {
    mtx.lock();
    schedules.push_back(message);
    mtx.unlock();
    cond.notify_all();
  }

private:
  // void workerFunc() {}

  void event_loop() {
    std::cout << "in EventLoop::event_loop" << std::endl;
    bool running = true;
    std::unique_lock lock{mtx}; // does not unlock on destruction
    while (running) {
      std::cout << "cond wait" << std::endl;
      cond.wait(lock);
      while (schedules.size() > 0) {
        const Message message = schedules.front();
        schedules.pop_front();
        if (message.schedule.has_value()) {
          // TODO call into dart to deliver schedule data
        }
        if (message.should_quit) {
          // at this point worker thread has been joined
          running = false;
          break;
        }
      }
    }
    lock.unlock();
  }

  std::mutex mtx;
  std::condition_variable cond;
  std::deque<Message> schedules;
  std::thread workerThread;
  std::function<void(Schedule schedule)> submitSchedule;
  std::function<void()> notifyStopped;
};
