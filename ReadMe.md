# Business Central Azure Function sftp Demo

Demo of using SSH.NET Sftp Azure Function in Business Central.

Sftp Client

## Included

AL - Project for Business Central Sftp Client.

DavesBCSftp - C# Azure Function Project, can be published to Azure or ran in local container for testing.



## Functionality

Add, Edit and Delete hosts.

Download files and folders.
zu
Functionality provided to downloaded single | multiple files, and folders.

* Downloaded Files table allows the contents to be processed within Business Central.

* Downloaded folders are compressed to a zip format, and entries can be extracted and viewed via the client.

## Architecture Flow

```mermaid
sequenceDiagram
    actor User
    participant Page as BC Page<br/>(SftpClient / HostCard)
    participant FileMgt as DBCSftpFileMgt
    participant Mgt as DBCSFtpMgt
    participant HostMgt as DBCSFtpHostMgt
    participant IS as IsolatedStorage
    participant Func as Azure Function<br/>(BCSftp)
    participant SFTP as SFTP Server

    User->>Page: Select host / action
    Page->>HostMgt: GetHostDetails(hostCode)
    HostMgt->>IS: Read host JSON + password + SSL cert
    IS-->>HostMgt: credentials
    HostMgt-->>Page: JSettings (with hostCode stamped)

    Page->>FileMgt: GetFtpFolderFilesList / DownloadFiles / DownloadFolder
    FileMgt->>Mgt: GetFilesList / DownLoadFile / DownLoadFolder

    Mgt->>Mgt: AddToSettings(action, folderName/fileName, textTypes)
    Mgt->>HostMgt: GetHostCode(JSettings)
    HostMgt-->>Mgt: hostCode
    Mgt->>IS: GetSecrets(hostCode) → pwd, sslCert
    IS-->>Mgt: pwd, sslCert
    Mgt->>IS: GetFunctionKey() → x-functions-key
    IS-->>Mgt: functionKey

    Mgt->>Mgt: Build HttpRequestMessage (POST, body=JSettings JSON, headers: x-functions-key, x-sftp-password, x-sftp-sslcert)
    Mgt->>Func: HttpClient.Send(request)

    Func->>Func: Parse action from body/query
    Func->>SFTP: SftpClient.Connect(host, port, user, password)
    SFTP-->>Func: connected

    alt ListFiles
        Func->>SFTP: ListDirectory (recursive)
        SFTP-->>Func: file/folder entries
        Func-->>Mgt: { FileList, Count }
    else DownloadFile
        Func->>SFTP: ReadAllBytes / ReadAllText
        SFTP-->>Func: file bytes
        Func-->>Mgt: { fileContent (Base64), type }
    else DownloadFolder
        Func->>SFTP: ListDirectory → ReadAllBytes each file
        SFTP-->>Func: file bytes
        Func->>Func: Zip in-memory
        Func-->>Mgt: { fileContent (Base64 zip) }
    else RemoveFile / RemoveFolder
        Func->>SFTP: DeleteFileAsync / DeleteDirectory
        SFTP-->>Func: ok
        Func-->>Mgt: success message
    end

    Mgt-->>FileMgt: parsed result
    FileMgt->>FileMgt: Base64 decode → TempBlob
    FileMgt->>FileMgt: DBCFTPDownloadedFile.CreateEntry()
    FileMgt-->>Page: done
    Page-->>User: Updated file list / download stored
```

## Images

![Alt text](./images/SftpSetup.png?raw=true "Daves Sftp Setup")

![Alt text](./images/SftpHostCard.png?raw=true "Daves Sftp Host Card")

![Alt text](./images/SftpClient1.png?raw=true "Daves Sftp Client")

![Alt text](./images/SftpDownloadedFiles.png?raw=true "Daves Sftp Downloaded Files")

![Alt text](./images/SftpFileViewer1.png?raw=true "Daves Sftp Downloaded File Viewer")

![Alt text](./images/SftpFileViewer2.png?raw=true "Daves Sftp Downloaded Compressed Folder Viewer")

![Alt text](./images/SftpFileViewer3.png?raw=true "Daves Sftp Downloaded Compress Folder Extracted File Viewer")



### Author: Dave Sinclair (2024)
