page 50138 PTEBCDSFtpZipContents
{
    Caption = 'Ftp Zip File Contents';
    PromotedActionCategories = 'New,Zip Entry,''';
    PageType = List;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    UsageCategory = None;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Filename';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the file name.';
                    Style = Strong;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExtractView)
            {
                ApplicationArea = All;
                Caption = 'View';
                ToolTip = 'Extract and view selected file entry.';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                begin
                    this.PageDownLoadedFile.ExtractAndViewCompressedEntry(Rec.Name);
                end;
            }

            action(ExtractDownload)
            {
                ApplicationArea = All;
                Caption = 'Download';
                ToolTip = 'Extract and download selected file entry(s).';
                Image = Compress;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                begin
                    this.ExtractAndDownload();
                end;
            }
        }
    }

    var
        PageDownLoadedFile: Record PTEBCFTPDownloadedFile;


    /// <summary>
    /// SetFileList.
    /// </summary>
    /// <param name="FilesList">List of [Text].</param>
    /// <param name="DownloadedFile">Record PTEBCFTPDownloadedFile.</param>
    internal procedure SetFileList(FilesList: List of [Text]; DownloadedFile: Record PTEBCFTPDownloadedFile)
    var
        Filename: Text;
    begin
        this.PageDownLoadedFile := DownLoadedFile;

        Rec.Reset();
        Rec.DeleteAll();
        foreach Filename in FilesList do
            Rec.AddNewEntry(CopyStr(Filename, 1, MaxStrLen(Rec.Name)), Filename);
    end;

    local procedure ExtractAndDownload()
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
    begin
        TempNameValueBuffer.Copy(Rec, true);
        CurrPage.SetSelectionFilter(TempNameValueBuffer);
        if not TempNameValueBuffer.FindSet() then
            exit;

        repeat
            this.PageDownLoadedFile.ExtractAndDownloadCompressedEntry(Rec.Name);
        until TempNameValueBuffer.Next() = 0;
    end;
}
