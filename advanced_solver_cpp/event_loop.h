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
  void start(Problem p, std::function<void(Schedule)> submitSchedule, std::function<void()> notifyStopped) {
    // start worker
    workerThread = std::thread([&]() {
      solver = new ProblemSolver(p, [&](std::optional<Schedule> schedule) {
        auto should_quit = !schedule.has_value() || schedule.value().optimal || schedule.value().infeasible;
        post({.schedule = schedule, .should_quit = should_quit});
      });
      // blocks until ortools solver finishes (finds the optimal solution or determines if the problem is infeasible)
      solver->solve();
    });

    while (true) {
      auto message = await_message();
      if (message.schedule.has_value()) {
        submitSchedule(message.schedule.value());
      }
      if (message.should_quit) {
        std::cout << "shouldQuit" << std::endl;
        break;
      }
    }

    solver->stop();

    if (workerThread.joinable()) {
      workerThread.join();
    }
    delete solver;
    notifyStopped();
  }

  // callers: dart ui isolate & worker thread
  void stop() {
    mtx.lock();
    schedules.push_front({.should_quit = true});
    mtx.unlock();
    cond.notify_all();
  }

  // callers: worker thread
  void post(Message message) {
    mtx.lock();
    schedules.push_back(message);
    mtx.unlock();
    cond.notify_all();
  }

private:
  Message await_message() {
    bool shouldQuit = false;
    std::unique_lock lock{mtx}; // does not unlock on destruction
    Message result;
    while (true) {
      cond.wait(lock);
      // only submit the most recent schedule
      while (schedules.size() > 0) {
        result = schedules.front();
        schedules.pop_front();
        if (result.should_quit) {
          break;
        }
      }
      if (result.schedule.has_value() || result.should_quit) {
        break;
      }
    }
    lock.unlock();
    return result;
  }

  ProblemSolver* solver;
  std::mutex mtx;
  std::condition_variable cond;
  std::deque<Message> schedules;
  std::thread workerThread;
};
