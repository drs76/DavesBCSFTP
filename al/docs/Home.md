# Daves BC SFTP — Wiki

A Business Central extension that provides full SFTP client functionality via an Azure Functions proxy. Browse remote servers, download files and folders, and view their contents without leaving Business Central.

---

## Features

- **Browse any SFTP server** — recursive folder navigation directly within BC
- **Multiple host support** — define and switch between as many SFTP hosts as needed
- **Download files and folders** — single files, multi-select, or entire folders (compressed to zip)
- **Built-in file viewer** — view files without downloading to your machine:
  - Text / code / JSON / XML / CSV (rendered as a table)
  - Images (PNG, JPG, GIF, SVG, WebP, BMP)
  - PDFs (embedded browser viewer)
  - Excel workbooks (XLSX / XLS) with sheet tabs
- **Zip explorer** — browse and extract individual entries from downloaded zip/folder archives
- **All credentials stored securely** in BC Isolated Storage — never in plain table fields

---

## Pages

| Page | Search term |
|---|---|
| Daves BC Sftp Setup | `BC Sftp Setup` |
| Daves Sftp Client | `BC FTP` |
| Daves Sftp Downloaded Files | via client or Role Centre |

---

## Wiki Contents

- [[Setup]] — Configure the Azure Function endpoint and function key
- [[SFTP-Hosts]] — Add and manage SFTP host connections
- [[SFTP-Client]] — Browse folders and download files
- [[Downloaded-Files]] — View and manage your download history
- [[File-Viewer]] — Supported file formats and the built-in viewer
- [[Azure-Function-Deployment]] — Deploy or run the Azure Function backend

---

> **Image note:** screenshots in this wiki are stored in the `images/` folder of the main repository. If you have cloned the wiki separately, copy that folder into the wiki repo or replace paths with full raw GitHub URLs.
