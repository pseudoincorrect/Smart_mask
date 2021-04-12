<p align="center"><img width=12.5% src="Support/Readme_Assets/Images/smart_mask_logo.png"></p>

<p align="center"><img width=100% src="Support/Readme_Assets/Images/flexySense_mask.png"></p>

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Contributions welcome](https://img.shields.io/badge/contributions-welcome-orange.svg)

<br>
FlexySense Mask is an embedded system connected to a mobile app to monitor the outputs of our custom printed sensors.

This System is divided into 3 parts:
- A Printed Circuit Board (PCB) for the embedded system, made with Altium Designer
- An embedded system firmware, written in C (Nordic SDK)
- A Flutter mobile application, for bluetooth connection, data storage and presentation

<br>
<p align="center">
<img align="center" width=30% src="Support/Readme_Assets/Images/mask_pcb_sensor.jpg">
&nbsp;&nbsp;&nbsp;------&nbsp;&nbsp;&nbsp;
<img align="center" width=10% src="Support/Readme_Assets/Images/bluetooth.png">
&nbsp;&nbsp;&nbsp;------&nbsp;&nbsp;&nbsp;
<img align="center"  width=20% src="Support/Readme_Assets/Images/app_analytics.png">
</p>
<br>

# Printed Circuit Board

The PCB is developped with Altium (started initially with Cadsoft Eagle).<br>
Sources and supportind documents are in  <a href="https://github.com/pseudoincorrect/smart_mask/tree/master/PCB">PCB/</a>.

<br>
<p align="center">
<img align="center" width=30% src="Support/Readme_Assets/Images/mask_pcb.jpg">
&nbsp;&nbsp;&nbsp;------&nbsp;&nbsp;&nbsp;
<img align="center" width=25% src="Support/Readme_Assets/Images/smart_mask_altium.png">
</p>
<br>

# Mobile Application

The Mobile app is developped with the Flutter SDK.<br>
Gather data and control the embedded system through bluetooth. <br>
Store on local Db and display. Filter and navigate data through analytic page  <br>
Sources and supportind documents are in <a href="https://github.com/pseudoincorrect/smart_mask/tree/master/Mobile_app/smart_mask">Mobile_app/</a>.

<br>
<p align="center">
<img align="center" width=20% src="Support/Readme_Assets/Images/app_graphs.png">
</p>
<br>

# Embedded System Software

Firmware for the central chip, a nrf52810 from Nordic Semiconductors.<br> The program is being developped with Nordic SDK on Segger Embedded Studio. <br>
Sources and supportind documents are in <a href="https://github.com/pseudoincorrect/smart_mask/tree/master/Embedded_system/smart_mask">Embedded_system/</a>.

<br>
<p align="center">
<img align="center" width=40% src="Support/Readme_Assets/Images/SES.jpg">
</p>
<br>
<br>

## Versatility
This project is quite general in the use of the sensor and can be adapted to any bluetooth sensor combined with mobile app. In such case, forking this repository and adapting to a new solution would be a wise strategy.
<br>

## Remarks
CAD files, embedded software and app are usually separated in different repositories. <br>
Here as the project is still simple enough and self-contained, all parts are kepts together.
<br>
