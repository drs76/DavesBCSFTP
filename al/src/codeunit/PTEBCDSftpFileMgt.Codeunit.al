codeunit 50136 PTEBCDSftpFileMgt
{
    var
        ProgressWindow: Dialog;
        ProgressOpened: Boolean;
        FailuresMsg: Label 'Failed to download the folowing file(s).\%1', Comment = '%1 = List of files failed to download.';
        ProgressFilesMsg: Label 'Filename: #1############################\Progress: #2############################', Comment = '#1 = Filename, #2=Progress Message.';
        ProgressFolderMsg: Label 'Foldername #1############################\Progress: #2############################', Comment = '#1 = Filename, #2=Progress Message.';
        DownloadLbl: Label 'Downloading..';


    internal procedure DownloadFiles(JSettings: JsonObject; var BCSftpBuffer: Record PTEBCSftpFileBuffer)
    var
        TempBlob: Codeunit "Temp Blob";
        FailedTB: TextBuilder;
    begin
        if not BCSftpBuffer.FindSet() then
            exit;

        this.OpenProgress(ProgressFilesMsg);

        repeat
            this.UpdateProgress(1, BCSftpBuffer.FileName);
            this.UpdateProgress(2, DownloadLbl);

            if this.DownloadFtpFile(JSettings, BCSftpBuffer, TempBlob) then
                this.StoreDownloadFtpFile(JSettings, BCSftpBuffer, TempBlob, false)
            else
                FailedTB.AppendLine(BCSftpBuffer.FileName);
        until BCSftpBuffer.Next() = 0;

        if not GuiAllowed then
            exit;

        this.CloseProgress();
        if GuiAllowed then
            if FailedTB.Length() > 0 then
                Message(StrSubstNo(FailuresMsg, FailedTB.ToText()));
    end;

    internal procedure DownloadFolder(JSettings: JsonObject; BCSftpFileBuffer: Record PTEBCSftpFileBuffer)
    var
        BCFtpMgt: Codeunit PTEBCDSFtpMgt;
        TempBlob: Codeunit "Temp Blob";
        Base64: Codeunit "Base64 Convert";
        WriteStream: OutStream;
        ReadStream: InStream;
        JToken: JsonToken;
        Response: Text;
        Filename: Text;
        NewZipNameLbl: Label '%1.zip', Comment = '%1 = Base filename';
    begin
        //TODO Add params
        if not BCSftpFileBuffer.IsDirectory then
            exit;

        this.OpenProgress(ProgressFolderMsg);
        this.UpdateProgress(1, BCSftpFileBuffer.FileName);
        this.UpdateProgress(2, DownloadLbl);

        Response := BCFtpMgt.DownLoadFolder(JSettings, BCSftpFileBuffer.FullFileName);
        JToken := GetFileContents(Response);

        TempBlob.CreateOutStream(WriteStream);
        Base64.FromBase64(JToken.AsValue().AsText(), WriteStream);
        TempBlob.CreateInStream(ReadStream);

        Filename := StrSubStno(NewZipNameLbl, BCSftpFileBuffer.FileName);
        BCSftpFileBuffer.FileName := CopyStr(Filename, 1, MaxStrLen(BCSftpFileBuffer.FileName));

        this.StoreDownloadFtpFile(JSettings, BCSftpFileBuffer, TempBlob, true);

        this.CloseProgress();
    end;

    internal procedure UpdateClientPageSettings(var JSettings: JsonObject; FtpFolder: Text)
    var
        RootFolderLbl: Label 'rootFolder';
    begin
        if JSettings.Contains(RootFolderLbl) then
            JSettings.Replace(rootFolderLbl, FtpFolder)
        else
            JSettings.Add(rootFolderLbl, FtpFolder);
    end;

    internal procedure GetFtpFolderFilesList(JSettings: JsonObject; FtpFolder: Text) ReturnValue: JsonArray
    var
        BCFtpMgt: Codeunit PTEBCDSFtpMgt;
        JObject: JsonToken;
        JToken: JsonToken;
        Result: Text;
        FileListLbl: Label 'fileList';
    begin
        Result := BCFtpMgt.GetFilesList(JSettings, FtpFolder);
        if not JObject.ReadFrom(Result) then
            Error(Result);

        JObject.SelectToken(FileListLbl, JToken);
        ReturnValue := JToken.AsArray();
    end;

    internal procedure TextToFromLastSlash(var ReturnValue: Text; From: Boolean)
    var
        TempRegExMatches: Record Matches temporary;
        RegExp: Codeunit Regex;
        RegExpToLbl: Label '^(.*[\\\/])';
        RegExpFromLbl: Label '([^\\\/]+$)';
    begin
        if From then
            RegExp.Match(ReturnValue, RegExpFromLbl, TempRegExMatches)
        else
            RegExp.Match(ReturnValue, RegExpToLbl, TempRegExMatches);
        if TempRegExMatches.IsEmpty() then
            exit;

        TempRegExMatches.FindFirst();
        ReturnValue := TempRegExMatches.ReadValue();
        if CopyStr(ReturnValue, StrLen(ReturnValue), 1) = '/' then
            ReturnValue := CopyStr(ReturnValue, 1, StrLen(ReturnValue) - 1);
    end;

    internal procedure SetFtpFilesSource(var SftpParams: Codeunit PTEBCDSftpParams; NewSource: JsonArray)
    var
        JToken: JsonToken;
    begin
        SftpParams.ClearFileBuffer();
        foreach JToken in NewSource do
            SftpParams.AddToFileBuffer(NewSource.IndexOf(JToken) + 1, JToken.AsObject());
    end;

    local procedure DownloadFtpFile(var JSettings: JsonObject; var BCFtpFileBuffer: Record PTEBCSftpFileBuffer; var TempBlob: Codeunit "Temp Blob") ReturnValue: Boolean
    var
        BCFtpMgt: Codeunit PTEBCDSFtpMgt;
        Base64Convert: Codeunit "Base64 Convert";
        WriteStream: OutStream;
        JToken: JsonToken;
        FileContent: Text;
    begin
        FileContent := BCFtpMgt.DownLoadFile(JSettings, BCFtpFileBuffer.FullFileName);
        if StrLen(FileContent) = 0 then
            exit;

        JToken := this.GetFileContents(FileContent);
        TempBlob.CreateOutStream(WriteStream, TextEncoding::UTF8);
        WriteStream.WriteText(Base64Convert.FromBase64(JToken.AsValue().AsText()));

        ReturnValue := true;
    end;

    local procedure GetFileContents(FileContent: Text) ReturnValue: JsonToken
    var
        FileObject: JsonObject;
        FileContentsLbl: Label 'fileContent';
    begin
        FileObject.ReadFrom(FileContent);
        FileObject.Get(FileContentsLbl, ReturnValue);
    end;

    local procedure StoreDownloadFtpFile(JSettings: JsonObject; BCFtpFIleBuffer: Record PTEBCSftpFileBuffer; var TempBlob: Codeunit "Temp Blob"; IsCompressed: Boolean)
    var
        FtpDownloadedFiles: Record PTEBCFTPDownloadedFile;
        StoringLbl: Label 'Storing to Ftp Downloads table..';
    begin
        if GuiAllowed then
            this.ProgressWindow.Update(2, StoringLbl);

        FtpDownloadedFiles.CreateEntry(JSettings, BCFtpFIleBuffer, TempBlob, IsCompressed);
    end;

    local procedure OpenProgress(Msg: Text)
    begin
        if not GuiAllowed then
            exit;

        if this.ProgressOpened then
            this.ProgressWindow.Close();

        this.ProgressWindow.Open(Msg);
        this.ProgressOpened := true;
    end;

    local procedure UpdateProgress(Item: Integer; Value: Variant)
    begin
        if not this.ProgressOpened then
            exit;

        this.ProgressWindow.Update(Item, Value);
    end;

    local procedure CloseProgress()
    begin
        if this.ProgressOpened then
            this.ProgressWindow.Close();

        Clear(this.ProgressOpened);
    end;

}