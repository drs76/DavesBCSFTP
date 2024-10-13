table 50136 PTEBCFTPDownloadedFile
{
    Caption = 'Daves Sftp Downloaded Files';
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(2; Filename; Text[2048])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }

        field(3; Compressed; Boolean)
        {
            Caption = 'Compressed';
            DataClassification = CustomerContent;
        }

        field(4; Size; Integer)
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }

        field(5; FtpHost; Code[250])
        {
            Caption = 'Ftp Host';
            DataClassification = CustomerContent;
        }

        field(6; FileContent; Media)
        {
            Caption = 'File Content';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }

        key(Host; FtpHost)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; Filename, Size, SystemModifiedAt)
        {
        }
    }

    var
        EmptyTxt: Label '';


    internal procedure CreateEntry(JSettings: JsonObject; BCSftpFileBuffer: Record PTEBCSftpFileBuffer; var TempBlob: Codeunit "Temp Blob"; IsCompressed: Boolean)
    var
        FtpDownloadedFiles: Record PTEBCFTPDownloadedFile;
        FtpClientMgt: Codeunit PTEBCDSftpFileMgt;
        FtpHostMgt: Codeunit PTEBCDSFtpHostMgt;
        ReadStream: InStream;
        NewFileName: Text;
    begin
        NewFileName := BCSftpFileBuffer.FullFileName;
        FtpClientMgt.TextToFromLastSlash(NewFileName, true);
        TempBlob.CreateInStream(ReadStream, TextEncoding::UTF8);

        FtpDownloadedFiles.Init();
        FtpDownloadedFiles.Filename := CopyStr(NewFileName, 1, MaxStrLen(FtpDownloadedFiles.Filename));
        FtpDownloadedFiles.Size := BCSftpFileBuffer.Size;
        FtpDownloadedFiles.FileContent.ImportStream(ReadStream, NewFileName);
        FtpDownloadedFiles.Compressed := IsCompressed;
        FtpDownloadedFiles.FtpHost := CopyStr(FtpHostMgt.GetHostCode(JSettings), 1, MaxStrLen(FtpDownloadedFiles.FtpHost));
        FtpDownloadedFiles.Insert(true);

        Rec := FtpDownloadedFiles;
    end;

    internal procedure DownloadFile()
    var
        TenantMedia: Record "Tenant Media";
        ReadStream: InStream;
        ToFileName: Text;
        DownloadLbl: Label 'Download Sftp File';
    begin
        if not this.GetTenantMedia(TenantMedia) then
            exit;

        TenantMedia.Content.CreateInStream(ReadStream, TextEncoding::UTF8);

        ToFileName := Rec.Filename;
        DownloadFromStream(ReadStream, DownloadLbl, this.EmptyTxt, this.EmptyTxt, ToFileName);
    end;

    internal procedure GetCompressedEntryList() ReturnValue: List of [Text]
    var
        DataCompression: Codeunit "Data Compression";
    begin
        this.OpenZipArchive(DataCompression);
        DataCompression.GetEntryList(ReturnValue);
        DataCompression.CloseZipArchive();
    end;

    internal procedure ExtractAndDownloadCompressedEntry(EntryFilename: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        ReadStream: InStream;
        ExtractLbl: Label 'Extract sftp file';
    begin
        this.ExtractZipEntry(EntryFilename, TempBlob);

        TempBlob.CreateInStream(ReadStream);
        DownloadFromStream(ReadStream, ExtractLbl, this.EmptyTxt, this.EmptyTxt, EntryFilename);
    end;

    internal procedure ExtractAndViewCompressedEntry(EntryFilename: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        ReadStream: InStream;
        FileContentToView: Text;
    begin
        this.ExtractZipEntry(EntryFilename, TempBlob);

        TempBlob.CreateInStream(ReadStream);
        if ReadStream.Read(FileContentToView) = 0 then
            exit;

        this.ViewFileContents(FileContentToView, EntryFilename);
    end;

    internal procedure ViewFileContents()
    var
        TenantMedia: Record "Tenant Media";
        ReadStream: InStream;
        FileContentToView: Text;
    begin
        if not this.GetTenantMedia(TenantMedia) then
            exit;

        TenantMedia.Content.CreateInStream(ReadStream, TextEncoding::UTF8);
        if ReadStream.Read(FileContentToView) = 0 then
            exit;

        this.ViewFileContents(FileContentToView, Rec.Filename);
    end;

    local procedure GetTenantMedia(var TenantMedia: Record "Tenant Media") ReturnValue: Boolean
    begin
        if not TenantMedia.Get(Rec.FileContent.MediaId) then
            exit;

        ReturnValue := TenantMedia.CalcFields(Content);
    end;

    local procedure OpenZipArchive(var DataCompression: Codeunit "Data Compression")
    var
        TenantMedia: Record "Tenant Media";
        ReadStream: InStream;
    begin
        if not this.GetTenantMedia(TenantMedia) then
            exit;

        TenantMedia.Content.CreateInStream(ReadStream);
        DataCompression.OpenZipArchive(ReadStream, false);
    end;

    local procedure ExtractZipEntry(EntryFilename: Text; var TempBlob: Codeunit "Temp Blob")
    var
        DataCompression: Codeunit "Data Compression";
        WriteStream: OutStream;
    begin
        this.OpenZipArchive(DataCompression);

        TempBlob.CreateOutStream(WriteStream);
        DataCompression.ExtractEntry(EntryFilename, WriteStream);
        DataCompression.CloseZipArchive();
    end;

    local procedure ViewFileContents(PageFileContent: Text; PageFilename: Text);
    var
        FileContents: Page PTEBCDSFtpFileContent;
        PageCaptionLbl: Label 'Contents of - %1', Comment = '%1 - Filename|Foldername';
    begin
        FileContents.Caption(StrSubstNo(PageCaptionLbl, PageFilename));
        FileContents.SetFileContent(PageFileContent, PageFilename);
        FileContents.RunModal();
    end;
}
