namespace DaveSinclair.DavesBCSFTP;

page 50150 TestPasgePtePTE
{
    ApplicationArea = All;
    Caption = 'TestPasgePte';
    PageType = List;
    SourceTable = DBCSftpFileBufferPTE;
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the EntryNo field.', Comment = '%';
                }
                field(Extension; Rec.Extension)
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field(FileName; Rec.FileName)
                {
                    ToolTip = 'Specifies the file/folder name.';
                }
                field(FolderName; Rec.FolderName)
                {
                    ToolTip = 'Specifies the value of the Foldername field.', Comment = '%';
                }
                field(FullFileName; Rec.FullFileName)
                {
                    ToolTip = 'Specifies the value of the Full Filename field.', Comment = '%';
                }
                field(IsDirectory; Rec.IsDirectory)
                {
                    ToolTip = 'Specifies the value of the Folder field.', Comment = '%';
                }
                field(ParentFolderName; Rec.ParentFolderName)
                {
                    ToolTip = 'Specifies the value of the Parent Foldername field.', Comment = '%';
                }
                field(Size; Rec.Size)
                {
                    ToolTip = 'Specifies the file size.';
                }
                field(SortOrder; Rec.SortOrder)
                {
                    ToolTip = 'Specifies the value of the Sort Order field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
            }
        }
    }

    internal procedure SetRecs(var NewRecs: Record DBCSftpFileBufferPTE)
    begin
        Rec.Copy(NewRecs, true);
    end;

}
