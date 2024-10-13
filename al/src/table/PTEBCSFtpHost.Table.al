table 50135 PTEBCSFtpHost
{
    Caption = 'Daves Sftp Host';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Name; Code[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(2; RootFolder; Text[2048])
        {
            Caption = 'Root Folder';
            DataClassification = CustomerContent;
            InitValue = '/';
        }

        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }

        field(4; SSLSetting; Enum PTEBCFTPSSLSetttings)
        {
            Caption = 'SSL';
            DataClassification = CustomerContent;
            InitValue = Default;
        }

        field(5; Encryption; Enum PTEBCFTPEncryptionSettings)
        {
            Caption = 'Encryption';
            DataClassification = CustomerContent;
            InitValue = Auto;
        }

        field(6; ValidationCertificate; Enum PTEBCFTPValidationCertificate)
        {
            Caption = 'Certificate Validation';
            DataClassification = CustomerContent;
            InitValue = ValidateAnyCertificate;
        }

        field(7; ValidateCertificateRevocation; Boolean)
        {
            Caption = 'Validate Certificate Revocation';
            DataClassification = CustomerContent;
            InitValue = false;
        }

        field(8; SSLBuffering; Boolean)
        {
            Caption = 'SSL Buffering';
            DataClassification = CustomerContent;
            InitValue = true;
        }

        field(9; Port; Integer)
        {
            Caption = 'Port';
            DataClassification = CustomerContent;
            InitValue = 0;
        }

        field(10; XC509Cert; Boolean)
        {
            Caption = 'XC509';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }

        key(Enabled; Enabled)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; Name, RootFolder)
        {
        }
    }

    trigger OnDelete()
    var
        HostMgt: Codeunit PTEBCDSFtpHostMgt;
    begin
        HostMgt.DeleteHostDetails(Rec.Name);
    end;
}
