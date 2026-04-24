namespace DaveSinclair.DavesBCSFTP;

page 50143 DBCSFtpPgpKeyInputPTE
{
    Caption = 'PGP Key';
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(KeyText; this.KeyText)
            {
                ApplicationArea = All;
                Caption = 'PGP Key (Armored)';
                ToolTip = 'Paste the PGP armored key block here.';
                MultiLine = true;
            }
        }
    }

    var
        KeyText: Text;

    internal procedure GetKeyText(var Value: Text)
    begin
        Value := this.KeyText;
    end;
}
