#pragma once

#include <Cue.h>
#include <stdio.h>

// Keep Cue v2 unchanged. A fresh event ID deduplicates each returned status;
// the original command ID travels in the name as a fixed-width hex suffix.
inline bool makeAssemblyStatus(
  cue::Node &node, uint64_t destination, const char *status,
  uint64_t command_id, cue::Message &message
) {
  if (destination == 0) return false;
  char name[cue::kNameCapacity] = {};
  const int length = command_id == 0
    ? snprintf(name, sizeof(name), "%s", status)
    : snprintf(name, sizeof(name), "%s:%016llX", status,
        static_cast<unsigned long long>(command_id));
  return length > 0 && static_cast<size_t>(length) < sizeof(name)
    && node.makeCue(destination, name, message);
}
