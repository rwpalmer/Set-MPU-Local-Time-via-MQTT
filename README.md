# Set-MPU-Local-Time-via-MQTT

## Concept:
---
### A Linux system runs a script that ...
* Looks up time-zone information based on the time-zone database that exists on its own file system.
* Format an MQTT message that contains the time-zone information IOT devices need to configure their own local time settings and to perform DST transitions when they are scheduled.
* Publishes the MQTT message with the 'retain' flag on.
* For the sake of this discussion, the MQTT topic is "time/zone".

### IOT MPUs would do the following ...
#### After each reboot:
* Subscribe to the "time/zone" topic. Since the 'retain' flag is on, the MQTT broker will send the latest message under this topic to the MPU each time it subscribes to the topic.

#### Whenever an MQTT message with the "time/zone" topic is received:
* Configure the MPU's local time settings based on the information in the 'time/zone' message
* Store DST transition information in RAM
#### When DST transitions occur
* Switch the MPU's setting between standard and daylight savings time based on the DST transition data stored in its RAM.
---

## Status: PROTOTYPING

#### Prototype 1:
* Linux script publishes the information Particle MPUs need to configure their time zone and DST offset to match the Linux system. The current year's DST transition times for the Linux systems's timezone is also included. 
* The MQTT message is in a *flat* JSON format. (no nesting, no arrays). This simplifies parsing. 
* MQTT code snippets include
     * Global Definition and Initialization
     * DST transition logic
     * MQTT callback logic (based on Particle MQTT library v0.4.29)
     * JSON parsing functions used by the callback log
---
#### Activity:
* 05 Mar 2019 - Prototype 1, Linux Code uploaded (documentation included in code)
* 06 Mar 2019 - Prototype 1, MPU code snippets uploaded.
* 07 Mar 2019 - Prototype 1, DST transition testing completed ... one minor fix posted to MPU snippets.
Prototype 1 proves that the concept is sound, and the code is relatively simple. The author is running this code on one of his Particle Xenon systems that already runs an MQTT client. Awaiting a March 10th DST transition ...
---
## Future Direction: TBD
* The Linux script used in Prototype 1 could be used to create data for any timezone, some timezones, or all timezones. 
* The Linux script could also generate a different data format, or multiple data formats
* If MPUs from other manufacturers need additional data, that data can be added to the existing data, or separate messages can be published based on the MPU manufacturer.







