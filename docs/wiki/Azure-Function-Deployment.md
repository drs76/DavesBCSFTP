# Azure Function Deployment

The `davesbcsftp` project is a .NET 9 Azure Functions v4 app (Isolated Worker model) that acts as an SFTP proxy between Business Central and the remote server. It must be deployed before the BC extension can be used.

---

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)

---

## Option A — Azure Functions Core Tools (recommended)

```bash
cd davesbcsftp
dotnet publish -c Release -o ./publish
az login
func azure functionapp publish <your-function-app-name> --dotnet-isolated
```

Replace `<your-function-app-name>` with the name of your Function App as it appears in the Azure Portal.

---

## Option B — Azure CLI zip deploy

```bash
cd davesbcsftp
dotnet publish -c Release -o ./publish
cd publish
zip -r ../deploy.zip .
cd ..
az functionapp deployment source config-zip \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --src deploy.zip
```

---

## Option C — Visual Studio / VS Code

- **Visual Studio:** Right-click the project → **Publish** → select your Azure subscription and Function App.
- **VS Code:** Install the [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions), then use the Azure panel to deploy.

---

## Running locally for testing

```bash
cd davesbcsftp
dotnet build
func host start
```

The function starts on `http://localhost:7071`. Point the **Azure Sftp Host** field in the BC [[Setup]] page to your local endpoint while testing.

In VS Code, the **build (functions)** task followed by the `func host start` task automates this.

---

## After deploying — retrieve the function key

The function uses `AuthorizationLevel.Function`, so every request must include the function key in the `x-functions-key` header. BC handles this automatically once configured in [[Setup]].

To retrieve the key:

1. Open the [Azure Portal](https://portal.azure.com)
2. Navigate to your Function App
3. Go to **Functions → BCSftp → Function Keys**
4. Copy the default key and paste it into the **Azure Function Key** field on the [[Setup]] page

---

## Request reference

All requests are HTTP POST to the function URL with an optional `?action=` query parameter. The body is a JSON object containing connection and operation parameters. The following headers are required:

| Header | Description |
|---|---|
| `x-functions-key` | Azure Function auth key |
| `x-sftp-password` | SFTP password for the target host |
| `x-sftp-sslcert` | SSL certificate (if required by the host) |

### Supported actions

| Action | Description |
|---|---|
| `ListFiles` | Returns a recursive listing of files and folders under `folderName` |
| `DownloadFile` | Returns the file at `fileName` as Base64 |
| `DownloadFolder` | Returns all files in `folderName` as a Base64-encoded zip |
| `RemoveFile` | Deletes the file at `fileName` |
| `RemoveFolder` | Deletes all files in `folderName` then removes the folder |
