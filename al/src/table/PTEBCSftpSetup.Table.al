table 50137 PTEBCSftpSetup
{
    //TODO: secure password
    Caption = 'Daves Sftp Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[1])
        {
            Caption = 'PrimaryKey';
        }
        field(2; "Azure Sftp Host"; Text[2048])
        {
            Caption = 'Azure Sftp Host';
            ExtendedDatatype = URL;
        }
        field(3; "Azure Sftp Port"; Integer)
        {
            Caption = 'Azure Sftp Port';
        }
        field(4; "Axure Sftp Username"; Text[250])
        {
            Caption = 'Axure Sftp Username';
        }
        field(5; "Azure Sftp Password"; Text[2048])
        {
            Caption = 'Azure Sftp Password';
            ExtendedDatatype = Masked;
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
