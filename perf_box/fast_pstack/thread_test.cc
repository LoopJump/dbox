

#include <iostream>
#include <thread>
#include <atomic>
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BT_BUF_SIZE 100

using namespace std;
unsigned long long get_tsc(void)
{
  unsigned int low, high;
  __asm__ volatile ("rdtsc" : "=a" (low), "=d" (high));
  return ((unsigned long long)high << 32) | low;
}

// Number of threads to create
const int NUM_THREADS = 1000;
long long backtrace_time_consumed[NUM_THREADS];
long long symbol_time_consumed[NUM_THREADS];

atomic<int> gtid(0);

void myfunc3(void)
{
  int nptrs;
  void *buffer[BT_BUF_SIZE];
  char **strings;
  static thread_local int tid = -1;
  if (tid == -1) {
    tid = gtid.fetch_add(1);
  }

  long long t1 = get_tsc();
  nptrs = backtrace(buffer, BT_BUF_SIZE);
  long long t2 = get_tsc();
  backtrace_time_consumed[tid] += t2 - t1;
  strings = backtrace_symbols(buffer, nptrs);
  long long t3 = get_tsc();
  symbol_time_consumed[tid] += t3 - t2;

  free(strings);
}

// Function to create a deep call stack
void deep_call_stack(int depth) {
  if (depth > 0) {
    // Recursive call to create a deep call stack
    deep_call_stack(depth - 1);
  } else {
    // std::chrono::seconds duration(1000);
    // std::this_thread::sleep_for(duration);
    myfunc3();
  }
}

// Function to create and manage multiple threads
void thread_func(int thread_id, int call_depth) {
  // Call the function to create a deep call stack
  for (int i = 0; i < 1000; i++) {
    deep_call_stack(call_depth);
  }
}

int main() {

  // Depth of the call stack for each thread
  int call_depth = 3;

  // Create an array of threads
  thread threads[NUM_THREADS];

  // Start each thread
  for (int i = 0; i < NUM_THREADS; i++) {
    threads[i] = thread(thread_func, i, call_depth);
  }

  // Wait for all threads to complete
  for (int i = 0; i < NUM_THREADS; i++) {
    threads[i].join();
  }

  long long backtrace_time_consumed_total = 0;
  long long symbol_time_consumed_total = 0;
  for (int i = 0; i < NUM_THREADS; i++) {
    backtrace_time_consumed_total += backtrace_time_consumed[i];
    symbol_time_consumed_total += symbol_time_consumed[i];
  }
  cout << "backtrace=" << backtrace_time_consumed_total << std::endl
       << "symbol=" <<  symbol_time_consumed_total << std::endl
       << "symbol/backtrace=" << symbol_time_consumed_total*1.0/backtrace_time_consumed_total
       << std::endl;
  return 0;
}

