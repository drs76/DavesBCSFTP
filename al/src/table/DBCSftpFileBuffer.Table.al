table 50138 DBCSftpFileBufferPTE
{
    Caption = 'Sftp File Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'EntryNo';
            DataClassification = CustomerContent;
        }
        field(2; FolderName; Code[2048])
        {
            Caption = 'Foldername';
            DataClassification = CustomerContent;
        }
        field(3; ParentFolderName; Code[2048])
        {
            Caption = 'Parent Foldername';
            DataClassification = CustomerContent;
        }
        field(4; FileName; Text[2048])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(5; FullFileName; Text[2048])
        {
            Caption = 'Full Filename';
            DataClassification = CustomerContent;
        }
        field(6; Size; Integer)
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }
        field(7; IsDirectory; Boolean)
        {
            Caption = 'Folder';
            DataClassification = CustomerContent;
        }
        field(8; SortOrder; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; Extension; Text[10])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Editable = false;
            InitValue = 'Folder';
        }
    }
    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
        key(Folder; ParentFolderName, FolderName)
        {
        }
        key(Sort; SortOrder)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; FullFileName, Extension, Size, SystemModifiedAt)
        {
        }
    }

    internal procedure AddEntry(Id: Integer; FtpFile: JsonObject; RootFolder: Text)
    var
        FileMgt: Codeunit "File Management";
        SftpFileMgt: Codeunit DBCSftpFileMgtPTE;
        JToken: JsonToken;
        Parent: Text;
        FoldernameLbl: Label 'foldername';
        ParentFoldernameLbl: Label 'parentFolder';
        FullnameLbl: Label 'fullname';
        NameLbl: Label 'name';
        SizeLbl: Label 'size';
        FolderLbl: Label 'folder';
    begin
        Rec.Init();
        Rec.EntryNo := Id;
        FtpFile.Get(FoldernameLbl, JToken);
        Rec.FolderName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Rec.FolderName));
        if StrLen(Rec.FolderName) = 0 then
            Rec.FolderName := CopyStr(RootFolder, 1, MaxStrLen(Rec.FolderName));

        FtpFile.Get(ParentFoldernameLbl, JToken);
        Rec.ParentFolderName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Rec.ParentFolderName));

        FtpFile.Get(FullnameLbl, JToken);
        Rec.FullFileName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Rec.FullFileName));
        FtpFile.Get(NameLbl, JToken);
        Rec.FileName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Rec.FileName));
        FtpFile.Get(SizeLbl, JToken);
        Rec.Size := Jtoken.AsValue().AsInteger();
        FtpFile.Get(FolderLbl, JToken);
        Rec.IsDirectory := Jtoken.AsValue().AsBoolean();
        if Rec.IsDirectory then
            if Rec.ParentFolderName = Rec.FolderName then begin
                Parent := Rec.ParentFolderName;
                SftpFileMgt.TextToFromLastSlash(Parent, false);
                Rec.ParentFolderName := CopyStr(Parent, 1, MaxStrLen(Rec.ParentFolderName));
            end;
        if StrLen(Rec.ParentFolderName) = 0 then
            Rec.ParentFolderName := CopyStr(RootFolder, 1, MaxStrLen(Rec.ParentFolderName));

        if not Rec.IsDirectory then begin
            Rec.SortOrder := 10;
            Rec.Extension := CopyStr(FileMgt.GetExtension(Rec.FullFileName), 1, MaxStrLen(Rec.Extension));
        end;
        Rec.Insert(true);
    end;
}
