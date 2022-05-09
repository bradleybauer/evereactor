#pragma once

#include <array>
#include <string>
#include <map>

enum class IndustryType {
  REACTION = 0,      // M1
  MANUFACTURING = 1, // M2
};

static const std::map<IndustryType, std::string> machine2str{ {IndustryType::REACTION,"M1"}, {IndustryType::MANUFACTURING,"M2"} };
