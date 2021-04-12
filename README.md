<!-- <p align="center"><img width=12.5% src="https://github.com/pseudoincorrect/smart_mask/Support/Readme_Assets/Images/smart_mask_logo_3.png"></p> -->

<p align="center"><img width=12.5% src="Support/Readme_Assets/Images/smart_mask_logo.png"></p>

<p align="center" style="font-size:4em"><b>SMART MASK</b></p>

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Contributions welcome](https://img.shields.io/badge/contributions-welcome-orange.svg)

<br>
Smart Mask  is an embedded system connected to a mobile app to monitor the outputs of our custom printed sensors.

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
Sources and supportind documents are in the /PCB folder.

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
Sources and supportind documents are in the /Mobile_app folder.

<br>
<p align="center">
<img align="center" width=20% src="Support/Readme_Assets/Images/app_graphs.png">
</p>
<br>

# Embedded System Software

The central chip is a nrf52810 from Nordic Semiconductors. The program is being developped with Nordic SDK on Segger Embedded Studio. <br>
Sources and supportind documents are in the /Embedded_system folder.

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