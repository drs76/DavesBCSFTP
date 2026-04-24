namespace SinclairSoftScotland.BCSimpleSFTP;

page 58564 SSSSftpClientPTE
{
    Caption = 'Simple Sftp Client';
    AdditionalSearchTerms = 'Simple,Sinclair Soft Scotland,Transfer';
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Document;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

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
                    TableRelation = SSSSFtpHostPTE where(Enabled = const(true));

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

            part(BCFtpFiles; SSSSFtpClientFilesPartPTE)
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

                    RunObject = Page SSSSFtpHostsPTE;
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

                trigger OnAction()
                var
                    DownloadedFiles: Record SSSFTPDownloadedFilePTE;
                begin
                    DownloadedFiles.Reset();
                    DownloadedFiles.SetRange(FtpHost, this.FtpHost);
                    Page.RunModal(Page::SSSSftpDownloadedFilesPTE, DownloadedFiles);
                end;
            }
        }

        area(Promoted)
        {
            actionref(HostList_Promoted; HostList) { }
            actionref(Connect_Promoted; Connect) { }
            actionref(Files_Promoted; Files) { }
        }
    }

    var
        BCFtpClientMgt: Codeunit SSSSftpFileMgtPTE;
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
        BCFtpHost: Record SSSSFtpHostPTE;
        FtpHostMgt: Codeunit SSSSFtpHostMgtPTE;
        Pwd: SecretText;
        SslCert: SecretText;
    begin
        Clear(this.JSettings);
        Clear(this.FtpFolder);
        if BCFtpHost.Get(this.FtpHost) then begin
            FtpHostMgt.GetHostDetails(this.FtpHost, this.JSettings, Pwd, SslCert);
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
