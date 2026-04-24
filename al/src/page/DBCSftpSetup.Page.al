namespace DaveSinclair.DavesBCSFTP;

page 50140 DBCSftpSetupPTE
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'BC Sftp,Daves,Setup,Ftp';
    Caption = 'Daves BC Sftp Setup';
    PageType = Card;
    SourceTable = DBCSftpSetupPTE;
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
                field("Axure Sftp Username"; Rec."Azure Sftp Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Axure Sftp Username field.', Comment = '%';
                }
                field(AzureFunctionKey; this.FunctionKey)
                {
                    ApplicationArea = All;
                    Caption = 'Azure Function Key';
                    ToolTip = 'Specifies the Azure Function Key used to authenticate with the Azure Function endpoint.';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        this.SaveSecrets();
                    end;
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

    trigger OnOpenPage()
    begin
        this.LoadSecrets();
    end;

    [NonDebuggable]
    local procedure LoadSecrets()
    var
        SecretKey: SecretText;
    begin
        Rec.GetFunctionKey(SecretKey);
        if not SecretKey.IsEmpty() then
            this.FunctionKey := this.SecretIsSetTok;
    end;

    [NonDebuggable]
    local procedure SaveSecrets()
    var
        SecretKey: SecretText;
    begin
        if (this.FunctionKey = '') or (this.FunctionKey = this.SecretIsSetTok) then
            exit;
        SecretKey := this.FunctionKey;
        Rec.SetFunctionKey(SecretKey);
        this.FunctionKey := this.SecretIsSetTok;
    end;

    var
        FunctionKey: Text;
        SecretIsSetTok: Label '●●●●●●●●', Locked = true;
}
