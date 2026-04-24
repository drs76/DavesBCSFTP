namespace SinclairSoftScotland.BCSimpleSFTP;

codeunit 58557 SSSSftpParamsPTE
{

    var
        TempSFtpFileBuffer: Record SSSSftpFileBufferPTE;
        JSettings: JsonObject;
        RootFolder: Text[2048];
        CurrentFolder: Text[2048];


    internal procedure NavigateUpFolder(var TempPageRecord: Record SSSSftpFileBufferPTE temporary)
    begin
        if this.CurrentFolder = this.RootFolder then
            exit;
        this.NavigateToFolder(CopyStr(GetParentFolder(this.CurrentFolder), 1, 2048), TempPageRecord);
    end;

    internal procedure NavigateToFolder(NewFolder: Code[2048]; var TempPageRecord: Record SSSSftpFileBufferPTE temporary)
    begin
        this.CurrentFolder := NewFolder;
        this.TempSFtpFileBuffer.Reset();
        this.TempSFtpFileBuffer.SetFilter(ParentFolderName, NewFolder);
        TempPageRecord.Copy(this.TempSFtpFileBuffer, true);
    end;

    local procedure GetParentFolder(Path: Text): Text
    var
        i: Integer;
        LastSlash: Integer;
    begin
        // strip trailing slash
        if (StrLen(Path) > 1) and (CopyStr(Path, StrLen(Path), 1) = '/') then
            Path := CopyStr(Path, 1, StrLen(Path) - 1);

        LastSlash := 0;
        for i := 1 to StrLen(Path) do
            if CopyStr(Path, i, 1) = '/' then
                LastSlash := i;

        if LastSlash <= 1 then
            exit('/');

        exit(CopyStr(Path, 1, LastSlash - 1));
    end;

    internal procedure ClearFileBuffer()
    begin
        this.TempSFtpFileBuffer.Reset();
        this.TempSFtpFileBuffer.DeleteAll(true);
    end;

    internal procedure AddToFileBuffer(Id: Integer; FileObject: JsonObject)
    begin
        this.TempSFtpFileBuffer.AddEntry(Id, FileObject, GetRootFolder());
    end;

    internal procedure AddToFileBuffer(NewBuffer: Record SSSSftpFileBufferPTE)
    begin
        this.TempSFtpFileBuffer := NewBuffer;
        this.TempSFtpFileBuffer.Insert(true);
    end;

    internal procedure GetFileBuffer(var NewFileBuffer: Record SSSSftpFileBufferPTE) ReturnValue: Boolean
    begin
        NewFileBuffer.Reset();
        NewFileBuffer.DeleteAll(true);

        this.TempSFtpFileBuffer.Reset();
        NewFileBuffer.Copy(this.TempSFtpFileBuffer, true);

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

    internal procedure SetRootFolder(NewRoot: Code[2048])
    begin
        this.RootFolder := NewRoot;
        this.CurrentFolder := NewRoot;
    end;

    internal procedure GetRootFolder(): Code[2048]
    begin
        exit(this.RootFolder);
    end;

    internal procedure GetCurrentFolder(): Code[2048]
    begin
        exit(this.CurrentFolder);
    end;

}
