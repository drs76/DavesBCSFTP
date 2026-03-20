using System.IO.Compression;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Newtonsoft.Json;
using Renci.SshNet;
using Renci.SshNet.Sftp;

namespace davesbcsftp
{
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
        private struct FtpFile
        {
            public string? Foldername { get; set; }
            public string? ParentFolder { get; set; }
            public string? Fullname { get; set; }
            public string? Name { get; set; }
            public string? Modified { get; set; }
            public bool Folder { get; set; }
            public long Size { get; set; }
        }

        [Function("BCSftp")]
        public static async Task<IActionResult> BCSftp([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
        {
            string? action = req.Query["action"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic ftpSetup = JsonConvert.DeserializeObject(requestBody) ?? string.Empty;
            action ??= ftpSetup?.action;

            if (action == null)
                return new BadRequestObjectResult("Please pass a name on the query string or in the request body");

            using CancellationTokenSource TokenSource = new();
            CancellationToken cancellationToken = TokenSource.Token;
            using var client = GetClient(ftpSetup);
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

        private static SftpClient GetClient(dynamic ftpSetup)
        {
            int port = (int?)ftpSetup?.port ?? 0;
            if (port == 0) port = 22;
            var connectionInfo = new PasswordConnectionInfo(ftpSetup.hostName.ToString(), port, ftpSetup.userName.ToString(), ftpSetup.password.ToString());
            var client = new SftpClient(connectionInfo)
            {
                KeepAliveInterval = TimeSpan.FromMinutes(1)
            };
            client.Connect();
            return client;
        }

        private static async Task<IActionResult> ListFiles(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            List<FtpFile> files;
            files = await GetFilesAsync(client, ftpSetup.folderName.ToString(), ftpSetup, cancellationToken);
            return new OkObjectResult(new { FileList = files, Count = files.Count });
        }

        private static Task<List<FtpFile>> GetFilesAsync(SftpClient sftpClient, string directory, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            return Task.FromResult(GetFiles(sftpClient, directory, ftpSetup, cancellationToken));
        }

        private static List<FtpFile> GetFiles(SftpClient sftpClient, string directory, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            string currentFolder = directory;
            string parentFolder = directory.Equals(ftpSetup.rootFolder.ToString()) ? directory : directory.Remove(directory.LastIndexOf(FwdSlash));
            List<FtpFile> files = [];
            foreach (var sftpFile in sftpClient.ListDirectory(directory))
            {
                if (cancellationToken.IsCancellationRequested)
                    throw new TaskCanceledException();

                if (sftpFile.Name.StartsWith('.')) { continue; }

                if (!sftpFile.IsDirectory && !sftpFile.IsRegularFile)
                {
                    continue;
                }
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
                {
                    var files2 = GetFiles(sftpClient, sftpFile.FullName, ftpSetup, cancellationToken);
                    files.AddRange(files2);
                }
            }
            return files;
        }

        private static void AddFtpFileEntry(string currentFolder, string parentFolder, List<FtpFile> files, SftpFile sftpFile)
        {
            var name = Path.GetFileNameWithoutExtension(sftpFile.FullName);
            files.Add(new FtpFile() { Foldername = currentFolder, ParentFolder = parentFolder, Fullname = sftpFile.FullName, Name = name, Modified = sftpFile.LastWriteTime.ToShortDateString().ToString(), Folder = sftpFile.IsDirectory, Size = sftpFile.Length });
        }

        private static Task<IActionResult> DownloadFileAsync(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            return Task.FromResult<IActionResult>(DownloadFile(client, ftpSetup, cancellationToken));
        }

        private static OkObjectResult DownloadFile(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            if (cancellationToken.IsCancellationRequested)
                throw new TaskCanceledException();

            if (ftpSetup.textTypes.ToString().Contains(Path.GetExtension(ftpSetup.fileName.ToString())))
            {
                string fileString = client.ReadAllText(ftpSetup.fileName.ToString());
                var bytes = Encoding.UTF8.GetBytes(fileString);
                return new OkObjectResult(new
                {
                    fileContent = Convert.ToBase64String(bytes),
                    type = FileContentType
                });
            }

            byte[] fileBytes = client.ReadAllBytes(ftpSetup.fileName.ToString());

            return new OkObjectResult(new
            {
                fileContent = Convert.ToBase64String(fileBytes),
                type = FileContentType
            });
        }

        private static async Task<IActionResult> RemoveFile(SftpClient client, dynamic ftpSetup)
        {
            if (client.Exists(ftpSetup.fileName.ToString()))
            {
                CancellationTokenSource cancellationTokenSource = new();
                CancellationToken cancellationToken = cancellationTokenSource.Token;
                await client.DeleteFileAsync(ftpSetup.fileName.ToString(), cancellationToken);
                return new OkObjectResult($"File {ftpSetup.fileName.ToString()} deleted successfully.");
            }
            else
            {
                return new NotFoundObjectResult($"File {ftpSetup.fileName.ToString()} not found.");
            }
        }

        private static async Task<IActionResult> DownloadFolderAsync(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            var folderZip = await DownloadFolder(client, ftpSetup, cancellationToken);
            return folderZip;
        }

        private static async Task<OkObjectResult> DownloadFolder(SftpClient client, dynamic ftpSetup, CancellationToken cancellationToken)
        {
            string root = Path.GetFileName(ftpSetup.folderName.ToString()) + "/";
            byte[] ftpFile;

            using (MemoryStream zipStream = new())
            {
                using (ZipArchive zipArchive = new(zipStream, ZipArchiveMode.Create, true))
                {
                    foreach (var sftpFile in client.ListDirectory(ftpSetup.folderName.ToString()))
                    {
                        if (cancellationToken.IsCancellationRequested)
                            throw new TaskCanceledException();

                        if (sftpFile.Name.StartsWith('.'))
                            continue;

                        if (!sftpFile.IsRegularFile)
                            continue;

                        var entry = zipArchive.CreateEntry(Path.Combine(root, sftpFile.Name), CompressionLevel.Optimal);
                        using Stream entryStream = entry.Open();
                        byte[] bytes = client.ReadAllBytes(sftpFile.FullName);
                        await entryStream.WriteAsync(bytes, 0, bytes.Length, cancellationToken);
                    }
                }

                zipStream.Seek(0, SeekOrigin.Begin);
                ftpFile = zipStream.ToArray();
            }

            return new OkObjectResult(new
            {
                fileContent = Convert.ToBase64String(ftpFile)
            });
        }

        private static async Task<IActionResult> RemoveFolder(SftpClient client, dynamic ftpSetup)
        {
            CancellationTokenSource cancellationTokenSource = new();
            CancellationToken cancellationToken = cancellationTokenSource.Token;
            if (client.Exists(ftpSetup.folderName.ToString()))
            {
                foreach (var file in client.ListDirectory(ftpSetup.folderName.ToString()))
                {
                    if (!file.IsDirectory)
                        await client.DeleteFileAsync(file.FullName.ToString(), cancellationToken);
                }
                client.DeleteDirectory(ftpSetup.folderName.ToString());
                return new OkObjectResult($"Folder {ftpSetup.folderName.ToString()} deleted successfully.");
            }
            else
            {
                return new NotFoundObjectResult($"Folder {ftpSetup.folderName.ToString()} not found.");
            }
        }
    }
}
