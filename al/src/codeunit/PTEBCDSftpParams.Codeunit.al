codeunit 50137 PTEBCDSftpParams
{

    var
        SFtpFileBuffer: Record PTEBCSftpFileBuffer;
        SftpClientMgt: Codeunit PTEBCDSftpFileMgt;
        JSettings: JsonObject;
        CurrentFolder: Code[2048];
        ParentFolder: Code[2048];
        RootFolder: Code[2048];
        UpFolderLbl: Label 'UPFOLDER';


    internal procedure NavigateUpFolder()
    begin
        if this.CurrentFolder = this.RootFolder then
            exit;

        this.NavigateToFolder(this.ParentFolder);
    end;

    internal procedure NavigateToFolder(NewFolder: Code[2048])
    begin
        this.SetCurrentParent(NewFolder);
        this.SFtpFileBuffer.Reset();
        this.SFtpFileBuffer.SetFilter(ParentFolderName, '%1|%2', this.CurrentFolder, this.UpFolderLbl);
    end;

    local procedure SetCurrentParent(NewFolder: Code[2048])
    var
        Parent: Text;
    begin
        Parent := NewFolder;
        this.CurrentFolder := NewFolder;
        if NewFolder = this.RootFolder then
            exit;

        this.SftpClientMgt.TextToFromLastSlash(Parent, false);
        this.ParentFolder := CopyStr(Parent, 1, MaxStrLen(this.ParentFolder));
    end;

    internal procedure ClearFileBuffer()
    begin
        this.SFtpFileBuffer.Reset();
        this.SFtpFileBuffer.DeleteAll(true);
    end;

    internal procedure AddToFileBuffer(Id: Integer; FileObject: JsonObject)
    begin
        this.SFtpFileBuffer.AddEntry(Id, FileObject);
    end;

    internal procedure AddToFileBuffer(NewBuffer: Record PTEBCSftpFileBuffer)
    begin
        this.SFtpFileBuffer := NewBuffer;
        this.SFtpFileBuffer.Insert(true);
    end;

    internal procedure GetFileBuffer(var NewFileBuffer: Record PTEBCSftpFileBuffer) ReturnValue: Boolean
    var
        NewFileBuffer2: Record PTEBCSftpFileBuffer;
    begin
        NewFileBuffer.Reset();
        NewFileBuffer.DeleteAll(true);
        if this.SFtpFileBuffer.FindSet() then
            repeat
                NewFileBuffer2 := this.SFtpFileBuffer;
                NewFileBuffer2.Insert(true);
            until this.SFtpFileBuffer.Next() = 0;
        ReturnValue := NewFileBuffer2.FindFirst();
        if ReturnValue then
            NewFileBuffer.Copy(NewFileBuffer2, true);

        NewFileBuffer.SetCurrentKey(SortOrder);
    end;

    internal procedure SetSettings(NewSettings: JsonObject)
    begin
        this.JSettings := NewSettings;
    end;

    internal procedure GetSettings(): JsonObject
    begin
        exit(this.JSettings);
    end;

    internal procedure SetCurrentFolder(NewFolder: Code[2048])
    begin
        this.CurrentFolder := NewFolder;
    end;

    internal procedure GetCurrentFolder(): Code[2048]
    begin
        exit(this.CurrentFolder);
    end;

    internal procedure SetParentFolder(NewFolder: Code[2048])
    begin
        this.ParentFolder := NewFolder;
    end;

    internal procedure GetParentFolder(): Code[2048]
    begin
        exit(this.ParentFolder);
    end;

    internal procedure SetRootFolder(NewRoot: Code[2048])
    begin
        this.RootFolder := NewRoot;
    end;

    internal procedure GetRootFolder(): Code[2048]
    begin
        exit(this.RootFolder);
    end;

}
