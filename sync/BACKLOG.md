# Future improvements

## Battery and connection status indicator

Requested 2026-10-22. Future firmware/hardware work; not implemented.

Give battery-powered nodes a visible health indicator so a powered-looking but
disconnected assembly can be diagnosed without USB or the dashboard.

- Indicate firmware alive, Wi-Fi connecting/disconnected, and MQTT connected
  using distinct LED blink patterns. Use an existing controllable LED where
  possible; consider an external RGB LED if color indication is useful.
- Show an approximate battery state of charge, using colors or flash counts,
  ideally at startup and with a distinct low-battery warning. An estimate is
  sufficient; do not imply a precise fuel-gauge measurement.
- First verify the actual battery chemistry, power/regulator path, and whether
  each board can measure battery voltage. If not, plan suitable voltage-sensing
  hardware and ADC protection before implementing an estimate. A power LED
  alone cannot measure charge; do not assume the XIAO has a usable battery ADC.
- Account for voltage sag under motor load and avoid flickering between charge
  bands. Keep connection status distinguishable from battery status.
- Consider reporting battery voltage/estimated charge and reset reason to the
  dashboard as well, to help distinguish low power, brownouts, and reconnect
  failures. Indicator handling must not block motion or local stop/limit logic.

### Incident motivating this

DC A (`1CDBD45CFDF0`) disappeared from MQTT and stopped responding at its last
LAN address while the Pi and broker remained healthy. Unplugging and
reconnecting the LiPo pack **did not** restore operation. Connecting an external
USB-C charger **did** restore operation, with the battery clip still connected.
The user left the pack attached expecting it to charge; the actual charging
path/wiring has not been verified here. The cause is **not confirmed**: this
points toward battery-side power availability, but does not distinguish a
discharged pack, voltage sag/protection cutoff, or a battery-path connection or
regulator problem. Capture voltage and reset/reconnect diagnostics in a future
investigation. Do not record a battery-only power cycle as a successful fix.
