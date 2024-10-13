page 50134 PTEBCDSFtpHosts
{
    Caption = 'Daves Sftp Hosts';
    PageType = List;
    SourceTable = PTEBCSFtpHost;
    UsageCategory = None;
    CardPageId = PTEBCDSFtpHostCard;
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
