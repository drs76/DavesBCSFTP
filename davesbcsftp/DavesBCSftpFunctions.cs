using System.IO.Compression;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Newtonsoft.Json;
using Renci.SshNet;
using Renci.SshNet.Sftp;

namespace davesbcsftp;

public class DavesBCSftpFunctions()
{
    private const string FwdSlash = "/";
    const string ConstRemoveFolder = "RemoveFolder";
    const string ConstRemoveFile = "RemoveFile";
    const string ConstDownloadFolder = "DownloadFolder";
    const string ConstDownloadFile = "DownloadFile";
    const string ConstListFiles = "ListFiles";
    private const string InvalidAction = "Invalid action";
    private const string FileContentType = "application/octet-stream";

    private record struct FtpFile(
        string? Foldername,
        string? ParentFolder,
        string? Fullname,
        string? Name,
        string? Modified,
        bool Folder,
        long Size);

    [Function("BCSftp")]
    public static async Task<IActionResult> BCSftp([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
    {
        string? action = req.Query["action"];

        string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic ftpSetup = JsonConvert.DeserializeObject(requestBody) ?? string.Empty;
        action ??= ftpSetup?.action;

        if (action == null)
            return new BadRequestObjectResult("Please pass a name on the query string or in the request body");

        string password = req.Headers["x-sftp-password"].ToString();
        string sslCert = req.Headers["x-sftp-sslcert"].ToString();

        using CancellationTokenSource tokenSource = new();
        CancellationToken cancellationToken = tokenSource.Token;
        using var client = GetClient(ftpSetup, password);
        try
        {
            return action switch
            {
                ConstListFiles => await ListFiles(client, ftpSetup, cancellationToken),
                ConstDownloadFile => await DownloadFileAsync(client, ftpSetup, cancellationToken),
                ConstDownloadFolder => await DownloadFolderAsync(client, ftpSetup, cancellationToken),
                ConstRemoveFile => await RemoveFile(client, ftpSetup),
                ConstRemoveFolder => await RemoveFolder(client, ftpSetup),
                _ => new BadRequestObjectResult(InvalidAction),
            };
        }
        catch (Exception ex)
        {
            return new BadRequestObjectResult(ex.Message);
        }
        finally
        {
            client.Disconnect();
        }
    }

    private static SftpClient GetClient(dynamic ftpSetup, string password)
    {
        int port = (int?)ftpSetup?.port ?? 0;
        if (port == 0) port = 22;
        string hostName = ftpSetup?.hostName?.ToString() ?? throw new InvalidOperationException("hostName is required");
        string userName = ftpSetup?.userName?.ToString() ?? throw new InvalidOperationException("userName is required");
        var client = new SftpClient(new PasswordConnectionInfo(hostName, port, userName, password))
        {
            KeepAliveInterval = TimeSpan.FromMinutes(1)
        };
        client.Connect();
        return client;
    }

    private static async Task<IActionResult> ListFiles(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
    {
        var files = await GetFilesAsync(client, ftpSetup.folderName.ToString(), ftpSetup, cancellationToken);
        return new OkObjectResult(new { FileList = files, Count = files.Count });
    }

    private static Task<List<FtpFile>> GetFilesAsync(SftpClient sftpClient, string directory, dynamic ftpSetup, CancellationToken cancellationToken)
        => Task.FromResult(GetFiles(sftpClient, directory, ftpSetup, cancellationToken));

    private static List<FtpFile> GetFiles(SftpClient sftpClient, string directory, dynamic ftpSetup, CancellationToken cancellationToken)
    {
        string currentFolder = directory;
        string parentFolder = directory.Equals(ftpSetup.rootFolder.ToString()) ? directory : directory.Remove(directory.LastIndexOf(FwdSlash));
        List<FtpFile> files = [];
        foreach (var sftpFile in sftpClient.ListDirectory(directory))
        {
            if (cancellationToken.IsCancellationRequested)
                throw new TaskCanceledException();

            if (sftpFile.Name.StartsWith('.'))
                continue;

            if (!sftpFile.IsDirectory && !sftpFile.IsRegularFile)
                continue;

            if (sftpFile.IsDirectory)
            {
                currentFolder = sftpFile.FullName;
                parentFolder = currentFolder.Remove(currentFolder.LastIndexOf(FwdSlash));
                AddFtpFileEntry(currentFolder, parentFolder, files, (SftpFile)sftpFile);
            }
            else
            {
                currentFolder = sftpFile.FullName.Remove(sftpFile.FullName.LastIndexOf(FwdSlash));
                AddFtpFileEntry(currentFolder, currentFolder, files, (SftpFile)sftpFile);
            }

            if (sftpFile.IsDirectory && sftpFile.FullName != directory)
                files.AddRange(GetFiles(sftpClient, sftpFile.FullName, ftpSetup, cancellationToken));
        }
        return files;
    }

    private static void AddFtpFileEntry(string currentFolder, string parentFolder, List<FtpFile> files, SftpFile sftpFile)
    {
        var name = Path.GetFileNameWithoutExtension(sftpFile.FullName);
        files.Add(new FtpFile(currentFolder, parentFolder, sftpFile.FullName, name, sftpFile.LastWriteTime.ToShortDateString(), sftpFile.IsDirectory, sftpFile.Length));
    }

    private static Task<IActionResult> DownloadFileAsync(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        => Task.FromResult<IActionResult>(DownloadFile(client, ftpSetup, cancellationToken));

    private static OkObjectResult DownloadFile(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        string fileName = ftpSetup.fileName.ToString();
        if (ftpSetup.textTypes.ToString().Contains(Path.GetExtension(fileName)))
        {
            var bytes = Encoding.UTF8.GetBytes(client.ReadAllText(fileName));
            return new OkObjectResult(new { fileContent = Convert.ToBase64String(bytes), type = FileContentType });
        }

        byte[] fileBytes = client.ReadAllBytes(fileName);
        return new OkObjectResult(new { fileContent = Convert.ToBase64String(fileBytes), type = FileContentType });
    }

    private static async Task<IActionResult> RemoveFile(SftpClient client, dynamic ftpSetup)
    {
        string fileName = ftpSetup.fileName.ToString();
        if (!client.Exists(fileName))
            return new NotFoundObjectResult($"File {fileName} not found.");

        using CancellationTokenSource cts = new();
        await client.DeleteFileAsync(fileName, cts.Token);
        return new OkObjectResult($"File {fileName} deleted successfully.");
    }

    private static async Task<IActionResult> DownloadFolderAsync(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        => await DownloadFolder(client, ftpSetup, cancellationToken);

    private static async Task<OkObjectResult> DownloadFolder(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
    {
        string root = Path.GetFileName(ftpSetup.folderName.ToString()) + "/";

        using MemoryStream zipStream = new();
        using (ZipArchive zipArchive = new(zipStream, ZipArchiveMode.Create, true))
        {
            foreach (var sftpFile in client.ListDirectory(ftpSetup.folderName.ToString()))
            {
                if (cancellationToken.IsCancellationRequested)
                    throw new TaskCanceledException();

                if (sftpFile.Name.StartsWith('.') || !sftpFile.IsRegularFile)
                    continue;

                var entry = zipArchive.CreateEntry(Path.Combine(root, sftpFile.Name), CompressionLevel.Optimal);
                using Stream entryStream = entry.Open();
                await entryStream.WriteAsync(client.ReadAllBytes(sftpFile.FullName), cancellationToken);
            }
        }

        zipStream.Seek(0, SeekOrigin.Begin);
        return new OkObjectResult(new { fileContent = Convert.ToBase64String(zipStream.ToArray()) });
    }

    private static async Task<IActionResult> RemoveFolder(SftpClient client, dynamic ftpSetup)
    {
        string folderName = ftpSetup.folderName.ToString();
        if (!client.Exists(folderName))
            return new NotFoundObjectResult($"Folder {folderName} not found.");

        using CancellationTokenSource cts = new();
        foreach (var file in client.ListDirectory(folderName))
        {
            if (!file.IsDirectory)
                await client.DeleteFileAsync(file.FullName, cts.Token);
        }
        client.DeleteDirectory(folderName);
        return new OkObjectResult($"Folder {folderName} deleted successfully.");
    }
}
