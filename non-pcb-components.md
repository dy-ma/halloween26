# Non-PCB component recommendations

Shortlist researched 2026-09-19. These are separately purchased power/harness items, outside the JLC PCB assembly BOM. No purchases made. Prices and availability are listing snapshots, not reserved quotes; shipping, tax and possible tariffs are extra.

**Preferred starting combination:** Mean Well GST120A24-P1M brick, Littelfuse MINI inline holder, and a two-pin Deutsch DT connection for an exposed prop harness. XT60H is a simpler alternative for connections kept dry. Final supply capacity and fuse amperage depend on the completed mechanism; the PCB power path still has an unverified 5 A design target.

## Power supply: brick versus metal box

| Option | Exact model and buying link | Output | Why choose it? |
|---|---|---|---|
| **Preferred: enclosed brick** | [Mean Well GST120A24-P1M — DigiKey](https://www.digikey.com/en/products/detail/mean-well-usa-inc/GST120A24-P1M/7703595) | 24 V, 5 A, 120 W | Mains circuitry is already enclosed; convenient for a portable assembly. Listing showed **$44.70 each**, 4,931 in stock. |
| Metal-box alternative | [Mean Well LRS-150-24 — Mouser](https://www.mouser.com/en/ProductDetail/MEAN-WELL/LRS-150-24?qs=vDxCgdWo2h%2Bym5KOpEI%2Bpw%3D%3D) | 24 V, 6.5 A, 156 W | Mounts inside a larger electrical enclosure and gives direct screw-terminal wiring. Current price/stock not reliably retrieved; check before ordering. |

The **brick** accepts a grounded IEC C13 power cord at its C14 inlet. Check whether the cord is included. The P1M output is a **5.5 mm outside / 2.5 mm inside, center-positive barrel plug**; 2.1 mm is a different mating size. It has overload, overvoltage and temperature protection. See the [Mean Well GST120A datasheet](https://www.meanwell.com/Upload/PDF/GST120A/GST120A-SPEC.PDF).

The barrel connection needs a mating socket rated for the actual current before adapting to the fuse/pigtail harness. Avoid choosing an unspecified adapter solely because it fits. A panel-mounted socket can go in the enclosure; the exact adapter is still to select. The brick's barrel is not a locking or weather-sealed connector, even if the subsequent harness uses Deutsch.

The **metal box** has exposed AC terminals. Its installation needs an enclosure/terminal guarding, cable strain relief and protective-earth connection. It is fanless and has a **115/230 V input selector** that must match the mains supply. Its 6.5 A capacity does not increase the PCB's allowed current: protection and power-path limits still apply. See the [Mean Well LRS-150 datasheet](https://www.meanwell.com/Upload/PDF/LRS-150/LRS-150-SPEC.PDF).

Neither option is a rainproof outdoor supply. Plan a dry location with ventilation. For this first assembly, the brick avoids adding mains-terminal integration to the project. The metal box becomes attractive if the driver, controller and supply will all mount in one suitable enclosure.

## Inline fuse holder and replaceable fuse

| Item | Recommendation | Purchase / reference |
|---|---|---|
| **Holder** | **Littelfuse 0FHM0003ZXJB** — MINI blade holder with cap, 16 AWG black GXL wire leads, about 3.68 inches per lead; 20 A holder rating | [DigiKey](https://www.digikey.com/en/products/detail/littelfuse-commercial-vehicle-products/0FHM0003ZXJB/3427032): **$8.73 each**, 15,277 in stock. [Littelfuse FHM datasheet](https://www.littelfuse.com/assetdocs/littelfuse-fuse-holder-mini-fhm-datasheet.pdf?assetguid=339fa35e-eabc-45c5-9093-8abceaa8a2cf) |
| **Fuse, provisional** | **Littelfuse 0297003.WXNV**, 3 A, 32 V DC, MINI blade | [DigiKey](https://www.digikey.com/en/products/detail/littelfuse-inc/0297003-WXNV/146575). Evaluation candidate, **not a finalized fuse rating**. |

Buy the holder and fuse separately. The fuse pushes into the holder; nothing is soldered to the replaceable fuse. The holder's 20 A rating is its capacity, **not an instruction to install a 20 A fuse**. Its voltage specification accommodates this nominal 24 V system; the selected 32 V fuse also requires the maximum circuit voltage to remain within that rating.

Place the holder in the positive supply lead, near the source and before the PCB input. Its two leads can be joined into the cable using correctly sized crimp splices, or soldered joints with insulation and mechanical support. Mark its black wires as positive. The return wire runs alongside it, without this fuse.

The final amperage must tolerate normal operation and startup while protecting the wiring, contacts and PCB. A stepper's phase-current setting is not the same as the PSU input current. Check the fuse time/current curve against the actual supply's current limiting; a hiccup-limited supply may never deliver enough sustained current to blow a particular fuse. This holder can stay the same while that decision is finished. See [Littelfuse's selection guide](https://www.littelfuse.com/assetdocs/fuseology-selection-guide?assetguid=fa4aa360-f6c4-4eec-88a6-3d7ec3fe57d5) and the [board power decisions](electrical-decisions.md).

## Pigtail connectors: choose one family for each connection

| Family | Best fit here | Assembly tradeoff |
|---|---|---|
| **TE DEUTSCH DT, two-pin** | External harness needing a positive latch and environmental sealing | Crimp contacts; needs suitable tooling or pre-crimped leads. Larger than XT60. |
| **Genuine AMASS XT60H-F + XT60H-M** | Compact power disconnect inside a dry enclosure | Solder-cup contacts with rear covers; friction fit, without a release latch or weather seal. |

### Deutsch DT parts for one complete mating pair

| Qty | Part | Purpose |
|---:|---|---|
| 1 | [DT06-2S](https://www.te.com/en/product-DT06-2S.html) | Housing for the two socket contacts; use on the powered/source side |
| 1 | [DT04-2P](https://www.te.com/en/product-DT04-2P.html) | Mating housing for the two pin contacts |
| 1 each | W2S and W2P | Matching contact-retention wedges |
| 2 | [0462-201-16141](https://www.te.com/en/product-0462-201-16141.html) | Solid socket contacts for 16–20 AWG wire |
| 2 | [0460-202-16141](https://www.te.com/en/product-0460-202-16141.html) | Matching solid pin contacts for 16–20 AWG wire |

These size-16 contacts have a 13 A nominal/maximum catalog rating under the specified conditions, with useful headroom over our 5 A target. Complete-connector derating still applies. The standard DT06-2S seal accepts **2.23–3.68 mm wire insulation diameter**: choose wire by insulation diameter as well as conductor gauge. Sealing requires the correct wire and full assembly/mating. The linked TE pages provide drawings and distributor options; compare a complete kit against the contents above.

The listed solid contacts use an indent crimp. Do not assume the JST crimper is suitable. A genuine pre-crimped harness can be more economical than buying a dedicated tool for a few connections. Proposed harness assignment: **cavity 1 = +24 V, cavity 2 = return**; verify cavity numbers on both mating halves.

### XT60H alternative

Buy one genuine AMASS male/female pair per disconnect. Sources include [Stevens Aeromodel's pair](https://www.stevensaero.com/product/xt60-connector-pair/) and [Lumenier's five-pair pack](https://www.lumenier.com/products/amass-xt60h-power-connectors-male-female-5-sets-10-pcs). These are sourcing options, not verified stock reservations. AMASS lists the family in its [connector catalog](https://www.china-amass.com/public/upload/20250319/41b7a7787d7c61edc3371469ba98f193.pdf).

Use the half with **recessed socket contacts on the powered side**, and follow the molded +/− markings. Solder the leads and fit the rear covers, or buy properly made pigtails. Provide cable support; the covers do not make the connector waterproof. Its high-current connector designation does not change the rating of the attached wire or PCB.

## How the harness fits the board

```text
PSU +24 V ── inline fuse ── chosen cable connector ── J1 pin 1
PSU return ─────────────── chosen cable connector ── J1 pin 2

PCB J7 pin 1 ── driver +V
PCB J7 pin 2 ── driver GND
```

J1/J7 remain the selected **Molex Micro-Fit PCB headers**. Deutsch/XT60 can terminate their pigtails where a detachable cable connection is useful; they need no additional PCB footprint. Short board-side leads start at 18 AWG copper with matching Micro-Fit contacts; longer cable gauge depends on length and voltage drop. Do not force the holder's thicker leads into contacts intended for smaller wire.

Also budget for mating Micro-Fit housings/contacts, wire, splice insulation, cable restraints, an enclosure and mounting hardware. For a short enclosed run, omit redundant intermediate connectors. Keep the motor winding cable separate from sensitive signal wiring according to the selected driver's installation guidance.

J6 is the separate **XIAO power jumper**, not a motor connector. Its removable 2.54 mm shunt remains a final-assembly accessory; see [parts-list.md](parts-list.md).
