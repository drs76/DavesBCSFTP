# Setup

The **Daves BC Sftp Setup** page is a single-record configuration card that connects Business Central to the Azure Function backend. Open it by searching for **BC Sftp Setup** in the BC search bar.

![Daves BC Sftp Setup](../../images/SftpSetup.png)

---

## Fields

### General

| Field | Description |
|---|---|
| **Azure Sftp Host** | Full URL of the deployed `BCSftp` Azure Function endpoint, e.g. `https://<app>.azurewebsites.net/api/BCSftp` |
| **Azure Sftp Port** | Not used by the current function — port is set per host on the Host Card |
| **Azure Sftp Username** | Not used by the current function — credentials are set per host on the Host Card |
| **Azure Function Key** | The function-level auth key copied from the Azure Portal. Stored securely in Isolated Storage and sent as the `x-functions-key` header on every request. Click the field and type the key — it will mask itself after saving. |

### Treat as text file types

| Field | Description |
|---|---|
| **Treat As Text** | Comma-separated list of file extensions that should be downloaded and stored as UTF-8 text rather than raw binary. The Azure Function uses this list to decide whether to call `ReadAllText` or `ReadAllBytes` on the remote file. Default: `.txt,.csv,.log,.json,.xml,.html,.al,.cs,.sh,.ps1` |

---

## First-time setup steps

1. Deploy the Azure Function (see [[Azure-Function-Deployment]]).
2. Copy the function endpoint URL from the Azure Portal and paste it into **Azure Sftp Host**.
3. Copy the function key from **Functions → BCSftp → Function Keys** and paste it into **Azure Function Key**.
4. Adjust **Treat As Text** if you work with additional plain-text formats.
5. Add at least one SFTP host (see [[SFTP-Hosts]]).
