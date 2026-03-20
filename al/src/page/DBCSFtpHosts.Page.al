page 50134 DBCSFtpHostsPTE
{
    Caption = 'Daves Sftp Hosts';
    PageType = List;
    SourceTable = DBCSFtpHostPTE;
    UsageCategory = None;
    CardPageId = DBCSFtpHostCardPTE;
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
