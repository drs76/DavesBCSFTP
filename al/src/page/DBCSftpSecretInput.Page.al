page 50141 DBCSftpSecretInputPTE
{
    Caption = 'Enter Secret Value';
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(SecretValue; this.SecretValue)
            {
                ApplicationArea = All;
                Caption = 'Value';
                ToolTip = 'Enter the secret value.';
                ExtendedDatatype = Masked;
            }
        }
    }

    [NonDebuggable]
    internal procedure GetSecret(var Value: SecretText)
    begin
        Value := this.SecretValue;
    end;

    var
        SecretValue: Text;
}
