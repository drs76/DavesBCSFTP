# SFTP Hosts

SFTP hosts are managed from the **Daves Sftp Host Card**. Each host stores its connection details and credentials securely in BC Isolated Storage — no passwords are held in plain table fields.

Open the host list from the **Hosts** button in the [[SFTP-Client]], or navigate directly via the BC search.

![Daves Sftp Host Card](../../images/SftpHostCard.png)

---

## Host Card fields

### General

| Field | Description |
|---|---|
| **Name** | Unique identifier for this host (used as the host code throughout the extension) |
| **FTP Host** | Hostname or IP address of the SFTP server |
| **FTP User** | Username for the SFTP connection |
| **FTP Passwd** | Password — click the `...` assist button to enter or update. Stored in Isolated Storage, displayed as `●●●●●●●●` once set. |
| **FTP Root Folder** | Default root folder opened when connecting from the client, e.g. `/mnt/data/files`. Defaults to `/`. |
| **Enabled** | Only enabled hosts appear in the SFTP Client host dropdown |

### Options

| Field | Description |
|---|---|
| **Port** | SFTP port. `0` defaults to port 22. |
| **SSL** | SSL protocol version behaviour. `Default` prevents the OS from using TLS 1.0. `None` lets the OS choose the highest available protocol. |
| **Encryption** | `Auto` — connects in plaintext then upgrades to FTPS if supported. `Explicit` — upgrades to FTPS, throws if not supported. `Implicit` — connects directly in FTPS. |
| **Certificate Validation** | Controls how SSL certificates are validated. `ValidateAny` accepts any certificate from the server (useful for self-signed certs). |
| **Validate Certificate Revocation** | Whether to check the certificate revocation list during authentication. |
| **SSL Buffering** | Enables SSL buffering to speed up transfers. Disable if you experience random issues with FTPS file transfers. |
| **SSL Certificate** | Optional SSL client certificate for FTPS authentication. Click `...` to enter. |
| **XC509** | Enable if the SSL certificate is an XC509 P12 certificate. |

---

## Testing a connection

Click **Connect** on the host card action bar. BC will attempt to connect to the SFTP server and return a response message. This is useful for validating credentials and network connectivity before using the client.

---

## Adding a new host

1. Open the host list from the SFTP Client or BC search.
2. Click **New**.
3. Enter a **Name**, **FTP Host**, **FTP User**, and click the **FTP Passwd** assist button to set the password.
4. Set the **FTP Root Folder** to the directory you want to browse by default.
5. Toggle **Enabled** on.
6. Click **Connect** to verify the connection.
