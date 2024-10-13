page 50139 PTEBCDSFtpFileContent
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
            usercontrol(fileContent; PTEBCDSFtpFileContent)
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    CurrPage.fileContent.Init();
                    CurrPage.fileContent.Load(this.FileContent);
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
