namespace SinclairSoftScotland.BCSimpleSFTP;

using System.IO;
using System.SFTPClient;
using System.Text;
using System.Utilities;

codeunit 58554 SSSSFtpMgtPTE
{
    var
        HostNameLbl: Label 'hostName', Locked = true;
        UserNameLbl: Label 'userName', Locked = true;
        PortLbl: Label 'port', Locked = true;

    internal procedure Connect(JSettings: JsonObject) Result: Text
    var
        SftpClient: Codeunit "SFTP Client";
        Host: Text;
        UserName: Text;
        Port: Integer;
        Pwd: SecretText;
        SslCert: SecretText;
        ConnectedMsg: Label 'Connected to %1 successfully.', Comment = '%1=hostname';
    begin
        this.ExtractAndInit(JSettings, SftpClient, Host, UserName, Port, Pwd, SslCert);
        Result := StrSubstNo(ConnectedMsg, Host);
        SftpClient.Disconnect();
    end;

    internal procedure GetFilesList(JSettings: JsonObject; FolderName: Text) Result: Text
    var
        SftpClient: Codeunit "SFTP Client";
        Host: Text;
        UserName: Text;
        Port: Integer;
        Pwd: SecretText;
        SslCert: SecretText;
        FileArray: JsonArray;
        ResultObj: JsonObject;
    begin
        this.ExtractAndInit(JSettings, SftpClient, Host, UserName, Port, Pwd, SslCert);
        this.BuildFileListRecursive(SftpClient, FolderName, FileArray);
        SftpClient.Disconnect();
        ResultObj.Add('fileList', FileArray);
        ResultObj.WriteTo(Result);
    end;

    internal procedure DownLoadFile(JSettings: JsonObject; FileName: Text) Result: Text
    var
        FtpHost: Record SSSSFtpHostPTE;
        SftpClient: Codeunit "SFTP Client";
        Resp: Codeunit "SFTP Operation Response";
        Base64Convert: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit SSSSFtpCryptoMgtPTE;
        HostMgt: Codeunit SSSSFtpHostMgtPTE;
        TempBlob: Codeunit "Temp Blob";
        DecryptedBlob: Codeunit "Temp Blob";
        Host: Text;
        UserName: Text;
        Port: Integer;
        Pwd: SecretText;
        AesKey: Text;
        SslCert: SecretText;
        FileInStream: InStream;
        WriteStream: OutStream;
        RawReadStream: InStream;
        FinalReadStream: InStream;
        DecWriteStream: OutStream;
        PeekText: Text;
        HostCode: Text;
        ResultObj: JsonObject;
    begin
        this.ExtractAndInit(JSettings, SftpClient, Host, UserName, Port, Pwd, SslCert);
        TempBlob.CreateOutStream(WriteStream);
        Resp := SftpClient.GetFileAsStream(FileName, FileInStream);
        if Resp.IsError() then
            Error(Resp.GetError());
        CopyStream(WriteStream, FileInStream);
        SftpClient.Disconnect();

        HostCode := HostMgt.GetHostCode(JSettings);
        TempBlob.CreateInStream(RawReadStream);
        if (HostCode <> '') and FtpHost.Get(HostCode)
            and (FtpHost."File Encryption Mode" = FtpHost."File Encryption Mode"::AES)
            and FtpHost."Auto Decrypt Download"
            and HostMgt.HasAesKey(HostCode)
        then begin
            RawReadStream.ReadText(PeekText, 4);
            if CryptoMgt.IsEncryptedContent(PeekText) then begin
                HostMgt.GetAesKey(HostCode, AesKey);
                TempBlob.CreateInStream(RawReadStream);  // fresh stream from start
                DecryptedBlob.CreateOutStream(DecWriteStream);
                CryptoMgt.DecryptStream(RawReadStream, AesKey, DecWriteStream);
                DecryptedBlob.CreateInStream(FinalReadStream);
            end else
                TempBlob.CreateInStream(FinalReadStream)
        end else
            TempBlob.CreateInStream(FinalReadStream);

        ResultObj.Add('fileContent', Base64Convert.ToBase64(FinalReadStream));
        ResultObj.WriteTo(Result);
    end;

    internal procedure DownLoadFolder(JSettings: JsonObject; FolderName: Text; var ZipBlob: Codeunit "Temp Blob")
    var
        SftpClient: Codeunit "SFTP Client";
        DataCompression: Codeunit "Data Compression";
        Host: Text;
        UserName: Text;
        Port: Integer;
        Pwd: SecretText;
        SslCert: SecretText;
        ZipWriteStream: OutStream;
    begin
        this.ExtractAndInit(JSettings, SftpClient, Host, UserName, Port, Pwd, SslCert);
        DataCompression.CreateZipArchive();
        this.AddFolderToZip(SftpClient, FolderName, DataCompression);
        SftpClient.Disconnect();
        ZipBlob.CreateOutStream(ZipWriteStream);
        DataCompression.SaveZipArchive(ZipWriteStream);
    end;

    [NonDebuggable]
    local procedure ExtractAndInit(JSettings: JsonObject; var SftpClient: Codeunit "SFTP Client"; var Host: Text; var UserName: Text; var Port: Integer; var Pwd: SecretText; var SslCert: SecretText)
    var
        FtpHost: Record SSSSFtpHostPTE;
        FtpHostMgt: Codeunit SSSSFtpHostMgtPTE;
        Resp: Codeunit "SFTP Operation Response";
        JToken: JsonToken;
        HostCode: Text;
    begin
        if JSettings.Get(this.HostNameLbl, JToken) then
            Host := JToken.AsValue().AsText();
        if JSettings.Get(this.UserNameLbl, JToken) then
            UserName := JToken.AsValue().AsText();
        if JSettings.Get(this.PortLbl, JToken) then
            Port := JToken.AsValue().AsInteger();
        if Port = 0 then
            Port := 22;

        HostCode := FtpHostMgt.GetHostCode(JSettings);
        if HostCode <> '' then
            FtpHostMgt.GetSecrets(HostCode, Pwd, SslCert);

        if FtpHost.Get(HostCode) and (FtpHost.FingerprintSHA256 <> '') then
            SftpClient.AddFingerprintSHA256(FtpHost.FingerprintSHA256);

        Resp := SftpClient.Initialize(Host, Port, UserName, Pwd);
        if Resp.IsError() then
            Error(Resp.GetError());
    end;

    local procedure BuildFileListRecursive(var SftpClient: Codeunit "SFTP Client"; Directory: Text; var FileArray: JsonArray)
    var
        TempSftpFolderContent: Record "SFTP Folder Content";
        Resp: Codeunit "SFTP Operation Response";
        FileObj: JsonObject;
        ParentPath: Text;
    begin
        Resp := SftpClient.ListFiles(Directory, TempSftpFolderContent);
        if Resp.IsError() then
            Error(Resp.GetError());
        if not TempSftpFolderContent.FindSet() then
            exit;
        repeat
            if not TempSftpFolderContent.Name.StartsWith('.') then begin
                Clear(FileObj);
                if TempSftpFolderContent."Is Directory" then begin
                    // foldername = parentFolder = own path triggers AddEntry special-case
                    // which strips the trailing segment to compute the real parent
                    FileObj.Add('foldername', TempSftpFolderContent."Full Name");
                    FileObj.Add('parentFolder', TempSftpFolderContent."Full Name");
                end else begin
                    ParentPath := this.GetParentPath(TempSftpFolderContent."Full Name");
                    FileObj.Add('foldername', ParentPath);
                    FileObj.Add('parentFolder', ParentPath);
                end;
                FileObj.Add('fullname', TempSftpFolderContent."Full Name");
                FileObj.Add('name', TempSftpFolderContent.Name);
                FileObj.Add('size', TempSftpFolderContent.Length);
                FileObj.Add('folder', TempSftpFolderContent."Is Directory");
                FileArray.Add(FileObj);
                if TempSftpFolderContent."Is Directory" then
                    this.BuildFileListRecursive(SftpClient, TempSftpFolderContent."Full Name", FileArray);
            end;
        until TempSftpFolderContent.Next() = 0;
    end;

    local procedure AddFolderToZip(var SftpClient: Codeunit "SFTP Client"; FolderPath: Text; var DataCompression: Codeunit "Data Compression")
    var
        TempSftpFolderContent: Record "SFTP Folder Content";
        Resp: Codeunit "SFTP Operation Response";
        FileTempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileWriteStream: OutStream;
        FileReadStream: InStream;
        FolderBaseName: Text;
    begin
        Resp := SftpClient.ListFiles(FolderPath, TempSftpFolderContent);
        if Resp.IsError() then
            Error(Resp.GetError());
        FolderBaseName := this.GetLastSegment(FolderPath);
        if not TempSftpFolderContent.FindSet() then
            exit;
        repeat
            if not TempSftpFolderContent.Name.StartsWith('.') and not TempSftpFolderContent."Is Directory" then begin
                Clear(FileTempBlob);
                FileTempBlob.CreateOutStream(FileWriteStream);
                Resp := SftpClient.GetFileAsStream(TempSftpFolderContent."Full Name", FileInStream);
                if not Resp.IsError() then begin
                    CopyStream(FileWriteStream, FileInStream);
                    FileTempBlob.CreateInStream(FileReadStream);
                    DataCompression.AddEntry(FileReadStream, FolderBaseName + '/' + TempSftpFolderContent.Name);
                end;
            end;
        until TempSftpFolderContent.Next() = 0;
    end;

    internal procedure UploadFiles(JSettings: JsonObject; TargetFolder: Text; Files: List of [FileUpload])
    var
        FtpHost: Record SSSSFtpHostPTE;
        SftpClient: Codeunit "SFTP Client";
        Resp: Codeunit "SFTP Operation Response";
        CryptoMgt: Codeunit SSSSFtpCryptoMgtPTE;
        HostMgt: Codeunit SSSSFtpHostMgtPTE;
        RawBlob: Codeunit "Temp Blob";
        EncBlob: Codeunit "Temp Blob";
        Host: Text;
        UserName: Text;
        HostCode: Text;
        Port: Integer;
        Pwd: SecretText;
        AesKey: Text;
        SslCert: SecretText;
        CurrentFile: FileUpload;
        TempInStream: InStream;
        RawOutStream: OutStream;
        RawInStream: InStream;
        EncOutStream: OutStream;
        EncInStream: InStream;
        TargetPath: Text;
        ShouldEncrypt: Boolean;
        FailedTB: TextBuilder;
        UploadFailedMsg: Label 'Failed to upload:\%1', Comment = '%1 = failed filenames';
    begin
        this.ExtractAndInit(JSettings, SftpClient, Host, UserName, Port, Pwd, SslCert);

        HostCode := HostMgt.GetHostCode(JSettings);
        if (HostCode <> '') and FtpHost.Get(HostCode)
            and (FtpHost."File Encryption Mode" = FtpHost."File Encryption Mode"::AES)
            and FtpHost."Auto Encrypt Upload"
            and HostMgt.HasAesKey(HostCode)
        then begin
            HostMgt.GetAesKey(HostCode, AesKey);
            ShouldEncrypt := true;
        end;

        foreach CurrentFile in Files do begin
            TargetPath := DelChr(TargetFolder, '>', '/') + '/' + CurrentFile.FileName;
            CurrentFile.CreateInStream(TempInStream);

            if ShouldEncrypt then begin
                Clear(RawBlob);
                Clear(EncBlob);
                RawBlob.CreateOutStream(RawOutStream);
                CopyStream(RawOutStream, TempInStream);
                RawBlob.CreateInStream(RawInStream);
                EncBlob.CreateOutStream(EncOutStream);
                CryptoMgt.EncryptStream(RawInStream, AesKey, EncOutStream);
                EncBlob.CreateInStream(EncInStream);
                Resp := SftpClient.PutFileStream(TargetPath, EncInStream);
            end else
                Resp := SftpClient.PutFileStream(TargetPath, TempInStream);

            if Resp.IsError() then
                FailedTB.AppendLine(CurrentFile.FileName + ': ' + Resp.GetError());
        end;
        SftpClient.Disconnect();
        if FailedTB.Length() > 0 then
            Error(UploadFailedMsg, FailedTB.ToText());
    end;

    local procedure GetParentPath(FullPath: Text): Text
    var
        i: Integer;
        LastSlash: Integer;
        Trimmed: Text;
    begin
        Trimmed := FullPath;
        if (StrLen(Trimmed) > 1) and (CopyStr(Trimmed, StrLen(Trimmed), 1) = '/') then
            Trimmed := CopyStr(Trimmed, 1, StrLen(Trimmed) - 1);
        for i := 1 to StrLen(Trimmed) do
            if CopyStr(Trimmed, i, 1) = '/' then
                LastSlash := i;
        if LastSlash <= 1 then
            exit('/');
        exit(CopyStr(Trimmed, 1, LastSlash - 1));
    end;

    local procedure GetLastSegment(Path: Text): Text
    var
        i: Integer;
        LastSlash: Integer;
        Trimmed: Text;
    begin
        Trimmed := Path;
        if (StrLen(Trimmed) > 1) and (CopyStr(Trimmed, StrLen(Trimmed), 1) = '/') then
            Trimmed := CopyStr(Trimmed, 1, StrLen(Trimmed) - 1);
        for i := 1 to StrLen(Trimmed) do
            if CopyStr(Trimmed, i, 1) = '/' then
                LastSlash := i;
        exit(CopyStr(Trimmed, LastSlash + 1, StrLen(Trimmed)));
    end;
}
