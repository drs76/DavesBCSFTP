page 50136 PTEBCDSftpClient
{
    Caption = 'Daves Sftp Client';
    AdditionalSearchTerms = 'BC FTP';
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Document;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Ftp';

    layout
    {
        area(Content)
        {
            group(Server)
            {
                Caption = 'Server';

                field(FtpHost; this.FtpHost)
                {
                    Caption = 'FTP Host';
                    ToolTip = 'Specifies the FTP Host to connect with.';
                    ApplicationArea = All;
                    TableRelation = PTEBCSFtpHost where(Enabled = const(true));

                    trigger OnValidate()
                    begin
                        this.OnValidateHost();
                    end;
                }

                field(FtpFolder; this.FtpFolder)
                {
                    Caption = 'FTP Folder';
                    ToolTip = 'Specifies the FTP Host Folder as the root folder.';
                    ApplicationArea = All;
                }
            }

            part(BCFtpFiles; PTEBCDSFtpClientFilesPart)
            {
                Editable = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Hosts)
            {
                Caption = 'Hosts';
                action(HostList)
                {
                    Caption = 'Hosts';
                    ToolTip = 'Maintain Ftp Host entries.';
                    ApplicationArea = All;
                    Image = Web;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    RunObject = Page PTEBCDSFtpHosts;
                }
            }

            group(Ftp)
            {
                Caption = 'Ftp';
                action(Connect)
                {
                    ApplicationArea = All;
                    Caption = 'Connect';
                    ToolTip = 'Connect to the selected FTP Host and list root folder.';
                    Image = Continue;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        if StrLen(this.FtpHost) = 0 then
                            exit;

                        this.GetFilesList();
                    end;
                }
            }

            action(Files)
            {
                Caption = 'Downloaded Files';
                ToolTip = 'View files downloaded by the ftp client. View pre-filtered to current Ftp Host.';
                ApplicationArea = All;
                Image = Documents;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    DownloadedFiles: Record PTEBCFTPDownloadedFile;
                begin
                    DownloadedFiles.Reset();
                    DownloadedFiles.SetRange(FtpHost, this.FtpHost);
                    Page.RunModal(Page::PTEBCDSftpDownloadedFiles, DownloadedFiles);
                end;
            }
        }
    }

    var
        BCFtpClientMgt: Codeunit PTEBCDSftpFileMgt;
        JSettings: JsonObject;
        FtpHost: Text;
        FtpFolder: Text;


    local procedure UpdateSettings()
    var
        HostCodeLbl: Label 'hostCode';
    begin
        this.BCFtpClientMgt.UpdateClientPageSettings(this.JSettings, this.FtpFolder);
        if this.JSettings.Contains(HostCodeLbl) then
            this.JSettings.Replace(HostCodeLbl, this.FtpHost)
        else
            this.JSettings.Add(HostCodeLbl, this.FtpHost);

        CurrPage.BCFtpFiles.Page.SetSettings(this.JSettings);
    end;

    local procedure OnValidateHost()
    var
        BCFtpHost: Record PTEBCSFtpHost;
        FtpHostMgt: Codeunit PTEBCDSFtpHostMgt;
    begin
        Clear(this.JSettings);
        Clear(this.FtpFolder);
        if BCFtpHost.Get(this.FtpHost) then begin
            FtpHostMgt.GetHostDetails(this.FtpHost, this.JSettings);
            this.FtpFolder := BCFtpHost.RootFolder;
            this.UpdateSettings();
        end;
        CurrPage.Update(false);
    end;

    local procedure GetFilesList()
    var
        Source: JsonArray;
    begin
        Source := this.BCFtpClientMgt.GetFtpFolderFilesList(this.JSettings, this.FtpFolder);
        CurrPage.BCFtpFiles.Page.SetSource(Source);
        CurrPage.Update(false);
    end;

}