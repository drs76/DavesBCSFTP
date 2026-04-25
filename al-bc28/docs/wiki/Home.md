# BC Simple SFTP — Wiki

A Business Central 28 extension that provides full SFTP client functionality using the native BC SFTP Client (codeunit 9762). Browse remote servers, download files and folders, and view their contents without leaving Business Central — no Azure Function required.

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
- **Host key pinning** — SHA256 fingerprint verification for SSH host trust
- **All credentials stored securely** in BC Isolated Storage — never in plain table fields

---

## Requirements

- Business Central 28 (platform 28.0.0.0, runtime 17.0)
- App: **BC Simple SFTP** by Dave Sinclair

---

## Pages

| Page | Search term |
|---|---|
| BC Simple SFTP Setup | `BC Sftp Setup` |
| Daves Sftp Client | `BC FTP` |
| Daves Sftp Downloaded Files | via client or Role Centre |

---

## Wiki Contents

- [[Setup]] — Configure text file type handling
- [[SFTP-Hosts]] — Add and manage SFTP host connections
- [[SFTP-Client]] — Browse folders and download files
- [[Downloaded-Files]] — View and manage your download history
- [[File-Viewer]] — Supported file formats and the built-in viewer

---

