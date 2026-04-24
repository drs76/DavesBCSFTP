namespace SinclairSoftScotland.BCSimpleSFTP;

page 58562 SSSSFtpHostsPTE
{
    Caption = 'Simple Sftp Hosts';
    AdditionalSearchTerms = 'Simple,Host,ftp,sftp,transfer';
    PageType = List;
    SourceTable = SSSSFtpHostPTE;
    UsageCategory = None;
    CardPageId = SSSSFtpHostCardPTE;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Editable = false;

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled fields.';
                }
            }
        }
    }
}
