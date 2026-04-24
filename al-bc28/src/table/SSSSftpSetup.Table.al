namespace SinclairSoftScotland.BCSimpleSFTP;

table 58552 SSSSftpSetupPTE
{
    Caption = 'BC Simple SFTP Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[1])
        {
            Caption = 'PrimaryKey';
        }
        field(6; TreatAsTextFiles; Text[2048])
        {
            Caption = 'Treat As Text';
            InitValue = '.txt,.csv,.log,.json,.xml,.html,.al,.cs,.sh,.ps1';
        }
    }
    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce()
    begin
        if this.RecordHasBeenRead then
            exit;
        Rec.Get();
        this.RecordHasBeenRead := true;
    end;
}
