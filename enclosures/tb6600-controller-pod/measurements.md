# TB6600 controller pod — measurements

Working measurement log for the proposed perfboard/XIAO/battery/antenna pod.
These are raw caliper readings from the supplied photos. No fit clearances or
model dimensions have been added yet.

## Photo set 1

| Photo | Part / dimension shown | Reading | Confidence / notes |
| --- | --- | ---: | --- |
| 1 | Perfboard length | 69.96 mm | High; outside edge to outside edge |
| 2 | Perfboard width | 30.20 mm | High; outside edge to outside edge |
| 3 | Perfboard thickness | 1.45 mm | High; bare PCB thickness |
| 4 | LiPo width | 18.37 mm | High; narrow face dimension, including wrapping |
| 5 | LiPo length | 26.71 mm | High; long face dimension, including wrapping |
| 6 | LiPo thickness | 8.13 mm | High; maximum wrapped thickness shown |
| 7 | Antenna pigtail reach | 62.21 mm | Medium; appears to be between the XIAO-side connector reference and the antenna feed/solder reference, not free cable length alone |
| 8 | Antenna body length | 38.53 mm | High; black flex/PCB antenna outside length |
| 9 | Antenna body width | 18.19 mm | High; black flex/PCB antenna outside width |
| 10 | XIAO/header assembly envelope | 16.53 mm | Medium; appears to be the assembled stack/projection shown edge-on; exact endpoints should be confirmed before modeling |

## Photo set 2

| Photo | Part / dimension shown | Reading | Confidence / notes |
| --- | --- | ---: | --- |
| 1 | TB6600 body span at the flat labeled face | 80.27 mm | High; outside face to outside face across the body |
| 2 | Small side feature dimension | 5.48 mm | High photo reading, but superseded as the actual slot width by the direct 2.83 mm follow-up measurement |
| 3 | Small side-vent opening / reach dimension | 9.90 mm | High reading; interpreted as the second vent/reach dimension used by the wraparound arm |

## Direct follow-up measurements

| Part / dimension | Reading | Confidence / notes |
| --- | ---: | --- |
| Side-vent slot width | 2.83 mm | High; direct user measurement. Model hook width reduced to 2.30 mm. |
| Clear gap between the nearest facing edges of the two selected vent slots | about 27.00 mm | Direct user measurement from the second installed-fit photo set; with 2.83 mm slot width, the model derives 29.83 mm center spacing. |
| Revised LiPo length | 65.63 mm | Direct user measurement; replaces the original small pouch for this revision. |
| Revised LiPo broad-face height | 36.22 mm | Direct user measurement. |
| Revised LiPo thickness | 10.00 mm | Direct user measurement. |

The XIAO will be installed in female Dupont headers. The antenna wall was later
removed from the bumper to improve printability.

The original layout shown in photo 4 was:

- Perfboard horizontal across the flat labeled face of the driver.
- Populated XIAO on the left side of the perfboard.
- LiPo flat on the unused right side, with its connector and wires remaining
  accessible.
- Antenna pigtail exiting left to a plastic antenna support beyond the metal
  driver body.
- A removable printed bumper wrapping over the driver and snapping into the
  small side vents. The heatsink fins are not used as attachment points.
- The perfboard bolts to four M2 heat-set-insert bosses using its existing
  corner holes; this supersedes the earlier slide-rail idea.

The second physical-fit photo set revises that layout:

- The 65.63 × 36.22 mm battery face lies flat and parallel to both the TB6600
  face and the perfboard; only its 10.00 mm thickness adds to the stack.
- The carrier uses one continuous outer box with internal battery and PCB
  cutouts. It retains the DC carrier's slide-in battery access and soft Velcro
  retention rather than using a rigid clip. Its installed top edge stays fully
  open so the battery slides in after the perfboard is screwed down.
- The board has 5.00 mm nominal clearance above the measured battery envelope.
- Two snap-arm pairs engage the two selected side-vent positions. The measured
  27.00 mm is an edge-to-edge vent gap, not a center-to-center dimension.

## Visible construction details to retain

- Perfboard has four corner mounting holes.
- The corner holes accept M2 screws. The measured board-edge-to-hole-edge gap
  is 1.05–1.10 mm in both axes (1.075 mm nominal for the model).
- The XIAO ESP32-S3 has soldered header pins and a battery lead/connector.
- The external antenna uses a short coax pigtail and a rectangular adhesive
  antenna body.
- Battery dimensions include its existing foil/tape wrapping; the wire and
  connector need a separate cable exit and bend allowance.

## Still pending

- Exact perfboard hole diameter. The initial model assumes 2.20 mm M2
  clearance, giving nominal center offsets of 2.175 mm from each board edge and
  approximately 65.61 × 25.85 mm hole-center spacing.
- Exact solder/header projection below the populated perfboard. The corrected
  flat revision currently reserves 5.00 mm over the measured battery envelope.
- Confirmation of the exact endpoints in photos 7 and 10 if their clearances
  become critical.
- Minimum desired battery-lead bend radius. The broad access opening and open
  top avoid fixing the lead to one exit side.
- Exact wall thickness behind a side vent and the vent center position relative
  to the flat labeled face. These can be tuned with a small hook fit gauge.

The photo sets are complete. Validate the side-vent hook with a small fit gauge
before relying on the full bumper snap fit.
