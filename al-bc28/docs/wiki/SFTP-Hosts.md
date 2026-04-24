# SFTP Hosts

SFTP hosts are managed from the **BC Simple SFTP Host Card**. Each host stores its connection details and credentials securely in BC Isolated Storage — no passwords are held in plain table fields.

Open the host list from the **Hosts** button in the [[SFTP-Client]], or navigate directly via the BC search.

![SFTP Host Card](images/SftpHostCard.png)
<!-- TODO: screenshot of the Host Card -->

---

## Host Card fields

### General

| Field | Description |
|---|---|
| **Name** | Unique identifier for this host (used as the host code throughout the extension) |
| **FTP Host** | Hostname or IP address of the SFTP server |
| **FTP User** | Username for the SFTP connection |
| **FTP Passwd** | Password — click the `...` assist button to enter or update. Stored in Isolated Storage, displayed as `●●●●●●●●` once set. |
| **FTP Root Folder** | Default folder opened when connecting from the client, e.g. `/mnt/data/files`. Defaults to `/`. |
| **Enabled** | Only enabled hosts appear in the SFTP Client host dropdown |

### Options

| Field | Description |
|---|---|
| **Port** | SFTP port. `0` defaults to port 22. |
| **Host Fingerprint (SHA256)** | SHA256 fingerprint of the server's SSH host key. When set, the connection is rejected if the server presents a different key. Leave blank to skip fingerprint verification. See [Fingerprint pinning](#fingerprint-pinning) below. |

> **Note:** The SSL/Encryption/Certificate fields visible on the host card are not used by the native BC28 SFTP Client, which communicates over SSH (not FTPS). They are present for compatibility and may be removed in a future version.

---

## Fingerprint pinning

When you first connect to an unknown SFTP server, BC raises an error:

> *The server's host key fingerprint `<fingerprint>` is not trusted*

Copy the fingerprint from the error message and paste it into the **Host Fingerprint (SHA256)** field on the host card. On subsequent connections, BC verifies the server presents the same key and rejects any mismatch — protecting against server impersonation.

![Fingerprint field on host card](images/SftpHostFingerprint.png)
<!-- TODO: screenshot highlighting the fingerprint field -->

---

## Testing a connection

Click **Connect** on the host card action bar. BC connects to the SFTP server and returns a success message, or an error describing the failure. Use this to validate credentials and network connectivity before using the client.

---

## Adding a new host

1. Open the host list from the SFTP Client or BC search.
2. Click **New**.
3. Enter a **Name**, **FTP Host**, and **FTP User**.
4. Click the **FTP Passwd** assist button (`...`) to set the password.
5. Set **FTP Root Folder** to the directory you want to browse by default.
6. Toggle **Enabled** on.
7. Click **Connect** to verify. If you receive a fingerprint trust error, copy the fingerprint into **Host Fingerprint (SHA256)** and try again.
