page 50137 PTEBCDSftpDownloadedFiles
{
    ApplicationArea = All;
    Caption = 'Daves Sftp Downloaded Files';
    PageType = List;
    SourceTable = PTEBCFTPDownloadedFile;
    UsageCategory = Administration;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Editable = false;

                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';

                    trigger OnDrillDown()
                    begin
                        this.DownloadDrillDown();
                    end;
                }

                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';

                    trigger OnDrillDown()
                    begin
                        this.DownloadDrillDown();
                    end;
                }

                field(FtpHost; Rec.FtpHost)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ftp Host field.';

                    trigger OnDrillDown()
                    begin
                        this.DownloadDrillDown();
                    end;
                }

                field(Filename; Rec.Filename)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename field.';

                    trigger OnDrillDown()
                    begin
                        this.DownloadDrillDown();
                    end;
                }

                field(Size; Rec.Size)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Size field.';

                    trigger OnDrillDown()
                    begin
                        this.DownloadDrillDown();
                    end;
                }

                field(Compressed; Rec.Compressed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Compressed field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(View)
            {
                Caption = 'View';
                ToolTip = 'View file contents.';
                ApplicationArea = All;
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.ViewFileContents();
                end;
            }

            action(Download)
            {
                Caption = 'Download File';
                ToolTip = 'Download selected file(s).';
                ApplicationArea = All;
                Image = Download;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.DownloadFile();
                end;
            }

            action(Delete)
            {
                Caption = 'Delete Download';
                ToolTip = 'Deleted the selected download file(s).';
                ApplicationArea = All;
                Image = Download;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                begin
                    this.DeleteRecs();
                end;
            }
        }
    }

    local procedure DownloadDrillDown()
    var
        FtpZipFileContents: Page PTEBCDSFtpZipContents;
        NewCaptionLbl: Label 'Contents of %1', Comment = '%1 - Foldername/Zip-Filename';
    begin
        if not Rec.Compressed then begin
            Rec.ViewFileContents();
            exit;
        end;

        FtpZipFileContents.Caption(StrSubStno(NewCaptionLbl, Rec.Filename));
        FtpZipFileContents.SetFileList(Rec.GetCompressedEntryList(), Rec);
        FtpZipFileContents.RunModal();
    end;

    local procedure DeleteRecs()
    var
        DownloadFiles: Record PTEBCFTPDownloadedFile;
    begin
        CurrPage.SetSelectionFilter(DownloadFiles);
        if not DownloadFiles.IsEmpty() then
            DownloadFiles.DeleteAll(true);
    end;

}
