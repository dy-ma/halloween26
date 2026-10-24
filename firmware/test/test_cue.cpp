#include <assert.h>
#include <string.h>

#include <Cue.h>

int main() {
  cue::Node sender;
  sender.begin(0x112233445566ULL, 0xaabbccdd);

  cue::Message original;
  assert(sender.makeCue(0x887766554433ULL, "tractor:tipped", original));
  assert(original.source == 0x112233445566ULL);
  assert(original.destination == 0x887766554433ULL);
  assert(original.id == 0xaabbccdd00000001ULL);

  uint8_t bytes[cue::kWireSize];
  assert(cue::encode(cue::makeCuePacket(original), bytes, sizeof(bytes)));
  assert(bytes[0] == 'C' && bytes[1] == 'U' && bytes[2] == 'E');

  cue::Packet decoded;
  assert(cue::decode(bytes, sizeof(bytes), decoded));
  assert(decoded.kind == cue::PacketKind::CUE);
  assert(decoded.message.source == original.source);
  assert(decoded.message.destination == original.destination);
  assert(decoded.message.id == original.id);
  assert(strcmp(decoded.message.name, original.name) == 0);

  cue::Node receiver;
  receiver.begin(0x887766554433ULL, 1);
  assert(receiver.accept(decoded.message));
  assert(!receiver.accept(decoded.message));

  bytes[4] = 99;
  assert(!cue::decode(bytes, sizeof(bytes), decoded));
  assert(!sender.makeCue(0x887766554433ULL, "", original));

  const cue::Packet ack = cue::makeAckPacket(
    0x887766554433ULL,
    0x112233445566ULL,
    original.id,
    -67,
    true
  );
  assert(cue::encode(ack, bytes, sizeof(bytes)));
  assert(cue::decode(bytes, sizeof(bytes), decoded));
  assert(decoded.kind == cue::PacketKind::ACK);
  assert(decoded.reported_rssi == -67);

  const cue::Packet hello = cue::makeHelloPacket(
    0x112233445566ULL,
    "dc-motor"
  );
  assert(cue::encode(hello, bytes, sizeof(bytes)));
  assert(cue::decode(bytes, sizeof(bytes), decoded));
  assert(decoded.kind == cue::PacketKind::HELLO);
  assert(strcmp(decoded.message.name, "dc-motor") == 0);

  cue::DuplicateCache<2> cache;
  assert(!cache.contains(1, 1));
  assert(cache.remember(1, 1));
  assert(cache.contains(1, 1));
  assert(!cache.remember(1, 1));

  return 0;
}
