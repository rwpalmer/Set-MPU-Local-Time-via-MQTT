# Set-MPU-Local-Time-via-MQTT

## Concept:
---
### A local Linux system publishes an MQTT message:
* Each year, on January 1st, with the retain flag set
* Containing the information needed for MPU's to configure their local time settings to match the Linux system's settings
* Under an MQTT topic ( 'time/zone' for this discussion)
### MPUs
#### After each reboot
* MPU subscribes to the 'time/zone' topic
* Since Linux published its message with the retain flag set, the MQTT broker will send the latest message to the MPU.
#### When a 'time/zone' message is received
* Configure the MPU's local time settings based on the information in the 'time/zone' message
* Store DST transition information in RAM
#### When DST transitions occur
* Switch the MPU's setting between standard and daylight savings time based on the DST transition data stored in RAM
---

## Status: PROTOTYPING
---
03 Mar 2019 - Linux Script Prototype 1 uploaded (documentation included in code)

