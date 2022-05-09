#pragma once

#include <iostream>
#include <unordered_map>
#include <vector>
#include <string>

#include "ortools/base/logging.h"
#include "ortools/sat/cp_model.h"
#include "ortools/sat/cp_model.pb.h"
#include "ortools/sat/cp_model_solver.h"
#include "ortools/sat/model.h"
#include "ortools/sat/sat_parameters.pb.h"

using namespace operations_research;
using namespace sat;
using std::string;
using std::to_string;
using std::unordered_map;
using std::vector;

template <typename T> struct VariableArray {
  unordered_map<string, unordered_map<string,T>> arrays = {};

  bool contains(string arrayName, vector<int> index) { return getArray(arrayName).contains(key(index)); }

  T& getVar(string arrayName, vector<int> index) { return getArray(arrayName).at(key(index)); }

  void setVar(string arrayName, vector<int> index, const T& var) { getArray(arrayName)[key(index)] = var; }

  string key(vector<int> index) {
    string result;
    for (auto const& s : index) {
      result += to_string(s);
    }
    return result;
  }

  unordered_map<string,T>& getArray(string arrayName) {
    if (arrays.contains(arrayName)) {
      return arrays[arrayName];
    }
    return arrays[arrayName];
  }
};

class VariableManager {
  CpModelBuilder& m;

  VariableArray<IntVar> intarrays = {};
  VariableArray<BoolVar> boolarrays = {};
  VariableArray<LinearExpr> exprarrays = {};

  IntVar& getIntVar(string name, vector<int> index) { return intarrays.getVar(name, index); }
  BoolVar& getBoolVar(string name, vector<int> index) { return boolarrays.getVar(name, index); }
  LinearExpr& getExpr(string name, vector<int> index) { return exprarrays.getVar(name, index); }

public:
  VariableManager(CpModelBuilder& m) : m(m) {}
  IntVar i(string arrayName, vector<int> index, const int lb, const int ub) {
    if (intarrays.contains(arrayName, index)) {
      return intarrays.getVar(arrayName, index);
    }
    if (lb > ub) {
        std::cout << "error using vm.i(.,.,.,.) : lb > ub " << lb << ">" << ub << std::endl;
        exit(1);
    }
    auto var = m.NewIntVar(Domain(lb, ub));
    //std::cout << "in vm after new int var" << std::endl;
    intarrays.setVar(arrayName, index, var);
    return var;
  }
  IntVar i(string arrayName, vector<int> index) {
      //std::cout << "in vm i(x,x)" << std::endl;
      if (!intarrays.contains(arrayName, index)) {
          std::cout << "error using vm.i(.,.)" << std::endl;
          exit(1);
      }
      auto result = intarrays.getVar(arrayName, index);
      //std::cout << "in vm i(x,x) after" << std::endl;
      return result;
  }
  BoolVar b(string arrayName, vector<int> index) {
    if (boolarrays.contains(arrayName, index)) {
      return boolarrays.getVar(arrayName, index);
    }
    auto var = m.NewBoolVar();
    boolarrays.setVar(arrayName, index, var);
    return var;
  }
  LinearExpr e(string arrayName, vector<int> index, const LinearExpr& expr) {
    if (exprarrays.contains(arrayName, index)) {
      return exprarrays.getVar(arrayName, index);
    }
    exprarrays.setVar(arrayName, index, expr);
    return expr;
  }
  LinearExpr e(string arrayName, vector<int> index) {
      if (!exprarrays.contains(arrayName, index)) {
          std::cout << "error using vm.e(.,.)" << std::endl;
          exit(1);
      }
      auto result = exprarrays.getVar(arrayName, index);
      return result;
  }
};
