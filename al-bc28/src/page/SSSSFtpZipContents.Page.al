namespace SinclairSoftScotland.BCSimpleSFTP;

using Microsoft.Utilities;

page 58566 SSSSFtpZipContentsPTE
{
    ApplicationArea = All;
    Caption = 'Sftp Zip File Contents';
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
                Scope = Repeater;

                trigger OnAction()
                begin
                    this.ExtractAndDownload();
                end;
            }
        }

        area(Promoted)
        {
            actionref(ExtractView_Promoted; ExtractView) { }
            actionref(ExtractDownload_Promoted; ExtractDownload) { }
        }
    }

    var
        PageDownLoadedFile: Record SSSFTPDownloadedFilePTE;


    /// <summary>
    /// SetFileList.
    /// </summary>
    /// <param name="FilesList">List of [Text].</param>
    /// <param name="DownloadedFile">Record PTEBCFTPDownloadedFile.</param>
    internal procedure SetFileList(FilesList: List of [Text]; DownloadedFile: Record SSSFTPDownloadedFilePTE)
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
