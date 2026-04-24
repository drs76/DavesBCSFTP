namespace DaveSinclair.DavesBCSFTP;

using System.Utilities;

page 50139 DBCSFtpFileContentPTE
{
    Caption = 'Daves Sftp File Content';
    PageType = NavigatePage;
    SourceTable = Integer;
    SourceTableView = sorting(Number) where(Number = const(1));
    UsageCategory = None;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            usercontrol(fileContent; DBCSFtpFileContentPTE)
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    CurrPage.fileContent.Init();
                    CurrPage.fileContent.Load(this.FileContent, this.Filename);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        FileContent: Text;
        Filename: Text;


    internal procedure SetFileContent(NewFileContent: Text; NewFilename: Text)
    begin
        this.FileContent := NewFileContent;
        this.Filename := NewFilename;
    end;
}
