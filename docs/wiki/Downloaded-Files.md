# Downloaded Files

The **Daves Sftp Downloaded Files** list is a persistent store of everything downloaded during SFTP sessions. Files are stored as binary blobs in BC — no temporary files are written to disk on the server.

![Daves Sftp Downloaded Files](../../images/SftpDownloadedFiles.png)

---

## Columns

| Column | Description |
|---|---|
| **Entry No.** | Auto-incremented entry identifier |
| **Created At** | Timestamp of when the file was downloaded |
| **Ftp Host** | The host the file was downloaded from |
| **Filename** | Name of the downloaded file or folder archive |
| **Size** | File size in bytes as reported by the SFTP server |
| **Compressed** | Checked when the entry is a folder downloaded as a zip archive |

---

## Actions

### View
Opens the built-in [[File-Viewer]] for the selected entry.

- For regular files — the viewer opens immediately displaying the file content.
- For compressed (zip) entries — the zip entry list opens first (see below), from which you can view or download individual files within the archive.

> Clicking the **Entry No.**, **Created At**, **Ftp Host**, or **Filename** columns also triggers View/open behaviour as a drill-down shortcut.

### Download File
Saves the selected file to your local machine via the standard BC browser download dialog.

### Delete Download
Permanently removes the selected entry (or entries) from BC storage. Multi-select is supported.

---

## Zip / folder archives

When you download a folder from the SFTP Client it is stored as a zip archive. Clicking **View** or drilling down on a compressed entry opens the **Ftp Zip File Contents** list:

![Zip contents list](../../images/SftpFileViewer2.png)

From here you can:

| Action | Description |
|---|---|
| **View** | Extracts the selected file from the zip and opens it in the [[File-Viewer]] |
| **Download** | Extracts the selected file(s) and saves them to your local machine |

![Viewing a file extracted from a zip](../../images/SftpFileViewer3.png)
