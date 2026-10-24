#include <assert.h>
#include <string.h>
#include "../../sync/firmware/src/AssemblyStatus.h"

int main() {
  cue::Node node;
  node.begin(0xAABBCCDDEEFFULL, 42);
  cue::Message message;
  const uint64_t destination = 0x020000000001ULL;
  assert(makeAssemblyStatus(node, destination, "dc:limit:fwd", 0x0123456789ABCDEFULL, message));
  assert(strcmp(message.name, "dc:limit:fwd:0123456789ABCDEF") == 0);
  const uint64_t first_status_id = message.id;
  assert(makeAssemblyStatus(node, destination, "dc:complete", 0x0123456789ABCDEFULL, message));
  assert(message.id != first_status_id);
  assert(!makeAssemblyStatus(node, destination, "this-status-is-too-long", 1, message));
  assert(makeAssemblyStatus(node, destination, "dc:limits:10", 0, message));
  assert(strcmp(message.name, "dc:limits:10") == 0);
}
