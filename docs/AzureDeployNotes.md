# Azure Deployment Notes

## Project

**Function App:** Daves BC SFTP
**Runtime:** .NET 9 (Isolated Worker)
**Azure Functions Version:** v4

---

## Prerequisites

Ensure the following are installed before deploying:

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)

---

## Option A — Azure Functions Core Tools (recommended)

**1. Build the project**

```bash
cd davesbcsftp
dotnet publish -c Release -o ./publish
```

**2. Log in to Azure**

```bash
az login
```

**3. Deploy**

```bash
func azure functionapp publish <your-function-app-name> --dotnet-isolated
```

Replace `<your-function-app-name>` with the name of your Function App as it appears in the Azure portal.

---

## Option B — Azure CLI zip deploy

**1. Build and publish**

```bash
cd davesbcsftp
dotnet publish -c Release -o ./publish
```

**2. Zip the output**

```bash
cd publish
zip -r ../deploy.zip .
cd ..
```

**3. Deploy via zip**

```bash
az functionapp deployment source config-zip \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --src deploy.zip
```

---

## Option C — Visual Studio / VS Code (GUI)

- **Visual Studio:** Right-click the project > **Publish** > select your Azure subscription and Function App
- **VS Code:** Install the [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions), then use the Azure panel to deploy

---

## After Deploying — Retrieve the Function Key

The function uses `AuthorizationLevel.Function`, so callers must supply a function key in the `x-functions-key` request header.

To get the key:

1. Open the [Azure Portal](https://portal.azure.com)
2. Navigate to your Function App
3. Go to **Functions** > **BCSftp** > **Function Keys**
4. Copy the key and configure it in the BC SFTP setup page

---

## Request Headers

The function expects the following custom headers on each request:

| Header | Description |
|---|---|
| `x-functions-key` | Azure Function auth key |
| `x-sftp-password` | SFTP password for the target host |
| `x-sftp-sslcert` | SSL certificate (if required) |
