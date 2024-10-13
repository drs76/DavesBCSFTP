page 50140 PTEBCDSftpSetup
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'BC Sftp,Daves,Setup,Ftp';
    Caption = 'Daves BC Sftp Setup';
    PageType = Card;
    SourceTable = PTEBCSftpSetup;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Azure Sftp Host"; Rec."Azure Sftp Host")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Azure Sftp Host field.', Comment = '%';
                }
                field("Azure Sftp Port"; Rec."Azure Sftp Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Azure Sftp Port field.', Comment = '%';
                }
                field("Axure Sftp Username"; Rec."Axure Sftp Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Axure Sftp Username field.', Comment = '%';
                }
                field("Azure Sftp Password"; Rec."Azure Sftp Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Azure Sftp Password field.', Comment = '%';
                }
            }
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
}
