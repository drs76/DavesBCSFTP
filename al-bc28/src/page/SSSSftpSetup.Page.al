namespace SinclairSoftScotland.BCSimpleSFTP;

page 58568 SSSSftpSetupPTE
{
    ApplicationArea = All;
    Caption = 'Simple SFTP Setup';
    PageType = Card;
    SourceTable = SSSSftpSetupPTE;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(TreatAsText)
            {
                Caption = 'Treat as text file types';

                field(TreatAsTextFiles; Rec.TreatAsTextFiles)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Treat As Text field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Init();
    end;
}
