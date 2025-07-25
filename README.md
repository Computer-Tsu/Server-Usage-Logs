# Analyzing Server Usage Logs

Microsoft Windows Server roles and services write activity usage to text logs. These scripts will scan and parse those logging files and output the client IP addresses.<br>The purpose is to identify devices and clients on your network that are still using your DNS, WINS, and other servers. Often when decommisioning a server, there will be devices that are hard coded, not well documented.<br>


---

### 🧾 **Windows Server Services with Text-Based Logs**

#### 🧮 **Name Services**

* **DNS Server** – debug logs (must be enabled), stored in a file like `dns.log`
* **WINS (Windows Internet Name Service)** – log file: `wins.log` (`%SystemRoot%\System32\Wins\`)

#### 📧 **Messaging & Email**

* **Microsoft Exchange Transport (SMTP)** – `SMTPReceive`, `SMTPSubmit`, etc. (`C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\`)
* **Exchange IMAP/POP** – protocol logs stored similarly to SMTP logs (`C:\Program Files\Microsoft\Exchange Server\V15\Logging\IMAP4\` and `..\POP3\`)

#### 🌐 **Web Services**

* **IIS (Internet Information Services)** – W3C logs typically at `C:\inetpub\logs\LogFiles\W3SVC1\`

#### 🔐 **Authentication & Network Access**

* **RRAS (Routing and Remote Access Service)** – logs VPN and dial-up connections (`%SystemRoot%\System32\LogFiles\` or `C:\Windows\System32\LogFiles\RRAS\`)
* **NPS (Network Policy Server)** – RADIUS logs in IAS format (`%SystemRoot%\System32\LogFiles`)

#### 📄 **Printing**

* **Print Server** – logs job events in binary, but textual logs may be enabled separately?

#### 🔒 **Remote Access / Terminal Services**

* **Remote Desktop Gateway / RDP logs** – Event Logs, but session logging can be enabled to log to text (custom setup)

#### 🖧 **DHCP Server**

* **DHCP Server** – logs stored at `%SystemRoot%\System32\Dhcp\DhcpSrvLog-*.log`

Last and quite least - Its quite challenging to think of a use case to look for client IPs in DHCP server logs.

---


[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
![Status](https://img.shields.io/badge/status-active-brightgreen)
![Repo Size](https://img.shields.io/github/repo-size/your-username/your-repo)
![Last Commit](https://img.shields.io/github/last-commit/your-username/your-repo)

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
