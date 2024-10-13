page 50133 PTEBCDSFtpClientFilesPart
{
    Caption = 'Ftp Files';
    PageType = ListPart;
    SourceTable = PTEBCSftpFileBuffer;
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(SortOrder; Rec.SortOrder)
                {
                    ApplicationArea = All;
                    HideValue = true;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sort Order field.';
                }
                field(FileName; Rec.FileName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the file/folder name.';
                    Caption = 'Name';
                    Editable = false;
                    DrillDown = true;
                    StyleExpr = StyleTxt;

                    trigger OnDrillDown()
                    begin
                        this.OnDrillDownName();
                    end;
                }
                field(Extension; Rec.Extension)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }

                field(Size; Rec.Size)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the file size.';
                    Caption = 'Size';
                    HideValue = Rec.IsDirectory;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NavigateUpAction)
            {
                Caption = 'Up';
                ToolTip = 'Navigate folder up.';
                ApplicationArea = All;
                Image = MoveUp;
                Scope = Repeater;

                trigger OnAction()
                begin
                    this.NavigateUp();
                end;
            }

            group(Download)
            {
                ShowAs = SplitButton;

                action(DownloadFile)
                {
                    Caption = 'Download';
                    ToolTip = 'Download selected file(s).';
                    ApplicationArea = All;
                    Image = Download;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        this.DownloadFiles();
                    end;
                }
                action(DownloadDirectory)
                {
                    Caption = 'Download Folder';
                    ToolTip = 'Download selected folder and its contents. The folder contents will be compressed into a single file.';
                    ApplicationArea = All;
                    Image = Download;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        this.DownloadFolder();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        this.SetStyle();
    end;

    trigger OnAfterGetRecord()
    begin
        this.SetStyle();
    end;


    var
        BCFtpClientMgt: Codeunit PTEBCDSftpFileMgt;
        SftpParams: Codeunit PTEBCDSftpParams;
        JSettings: JsonObject;
        StyleTxt: Text;
        UpLevelLbl: Label '..';


    internal procedure SetSettings(NewJSettings: JsonObject)
    var
        JToken: JsonToken;
        RootFolderLbl: Label 'rootFolder';
    begin
        this.SftpParams.SetSettings(NewJSettings);
        this.JSettings := NewJSettings;
        if NewJSettings.Get(RootFolderLbl, JToken) then begin
            this.SftpParams.SetRootFolder(CopyStr(JToken.AsValue().AsText().ToUpper(), 1, 2048));
            this.SftpParams.SetCurrentFolder(CopyStr(JToken.AsValue().AsText().ToUpper(), 1, 2048));
        end else
            Error('No root defined');
    end;

    internal procedure SetSource(NewSource: JsonArray)
    begin
        Rec.Reset();
        this.BCFtpClientMgt.SetFtpFilesSource(this.SftpParams, NewSource);
        this.SftpParams.GetFileBuffer(Rec);
        Rec.SetFilter(ParentFoldername, this.SftpParams.GetRootFolder());
        CurrPage.Update(false);
    end;

    internal procedure DownloadFolder()
    begin
        this.BCFtpClientMgt.DownloadFolder(this.JSettings, Rec);
    end;

    internal procedure DownloadFiles()
    var
        BCSftpFileBuffer: Record PTEBCSftpFileBuffer;
    begin
        if Rec.IsDirectory or (Rec.FileName = this.UpLevelLbl) then
            exit;

        BCSftpFileBuffer.Copy(Rec, true);

        CurrPage.SetSelectionFilter(BCSftpFileBuffer);
        this.BCFtpClientMgt.DownloadFiles(this.JSettings, BCSftpFileBuffer);
    end;

    local procedure NavigateUp()
    begin
        this.SftpParams.NavigateUpFolder();
        this.SftpParams.GetFileBuffer(Rec);
        CurrPage.Update(false);
    end;

    local procedure NavigateDown()
    begin
        this.SftpParams.NavigateToFolder(Rec.FullFileName);
        this.SftpParams.GetFileBuffer(Rec);
        CurrPage.Update(false);
    end;

    local procedure SetStyle()
    var
        StrongLbl: Label 'StrongAccent';
        SubordinateLbl: Label 'Subordinate';
    begin
        Clear(this.StyleTxt);
        this.StyleTxt := SubordinateLbl;
        if Rec.IsDirectory then
            this.StyleTxt := StrongLbl;
    end;

    local procedure OnDrillDownName()
    begin
        if not Rec.IsDirectory then
            exit;

        if Rec.FileName = this.UpLevelLbl then
            NavigateUp()
        else
            this.NavigateDown();
    end;
}