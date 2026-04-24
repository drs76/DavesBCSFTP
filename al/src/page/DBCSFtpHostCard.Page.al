namespace DaveSinclair.DavesBCSFTP;

page 50135 DBCSFtpHostCardPTE
{
    Caption = 'Daves Sftp Host Card';
    PageType = Card;
    SourceTable = DBCSFtpHostPTE;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the Name of the FTP Host.';
                    ApplicationArea = All;
                    NotBlank = true;
                }

                field(FtpHost; this.FtpHost)
                {
                    Caption = 'FTP Host';
                    ToolTip = 'Specifies the address of the FTP Host.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        this.UpdateHostDetails();
                    end;
                }

                field(FtpUser; this.FtpUser)
                {
                    Caption = 'FTP User';
                    ToolTip = 'Specifies the FTP Username.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        this.UpdateHostDetails();
                    end;
                }

                field(FtpPasswdDisplay; this.FtpPasswdDisplay)
                {
                    Caption = 'FTP Passwd';
                    ToolTip = 'Specifies the FTP Password. Click the assist button to set or update.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        this.EnterPassword();
                    end;
                }

                field(RootFolder; Rec.RootFolder)
                {
                    Caption = 'FTP Root Folder';
                    ToolTip = 'Specifies the default FTP Host Root Folder. This can case sensitive for *nix hosted Ftp servers.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        this.UpdateHostDetails();
                    end;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if Host is enabled.';
                }
            }

            group(EncryptionGrp)
            {
                Caption = 'File Encryption';

                field("File Encryption Mode"; Rec."File Encryption Mode")
                {
                    ApplicationArea = All;
                    Caption = 'Mode';
                    ToolTip = 'Select PGP to encrypt uploads and decrypt downloads for this host.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Auto Encrypt Upload"; Rec."Auto Encrypt Upload")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically PGP-encrypt files before uploading to this host.';
                    Enabled = Rec."File Encryption Mode" = Rec."File Encryption Mode"::PGP;
                }
                field("Auto Decrypt Download"; Rec."Auto Decrypt Download")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically PGP-decrypt downloaded files when a private key is configured.';
                    Enabled = Rec."File Encryption Mode" = Rec."File Encryption Mode"::PGP;
                }
                field(PgpPublicKeyDisplay; this.PgpPublicKeyDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'Public Key';
                    ToolTip = 'PGP public key status. Use the Set Public Key action to configure.';
                    Editable = false;
                }
                field(PgpPrivateKeyDisplay; this.PgpPrivateKeyDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'Private Key';
                    ToolTip = 'PGP private key status. Use the Set Private Key action to configure.';
                    Editable = false;
                }
            }

            group(Options)
            {
                field(Port; Rec.Port)
                {
                    ApplicationArea = All;
                    ToolTip = 'The FTP port to connect to. 0: Auto (21 or 990 depending on FTPS config)';

                    trigger OnValidate()
                    begin
                        this.UpdateHostDetails();
                    end;
                }

                field(SSLSetting; Rec.SSLSetting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value for SSL. Default: Prevent the OS from using TLS 1.0 which has issues in .NET Framework. None: Let the OS pick the highest and most relevant TLS protocol.';
                }

                field(Encryption; Rec.Encryption)
                {
                    ApplicationArea = All;
                    ToolTip = 'Auto: connects in plaintext FTP and then attempts to upgrade to FTPS (TLS) if supported by the server, Explicit: (TLS) connects in FTP and upgrades to FTPS, throws an exception if encryption is not supported., Implicit: (SSL) directly connects in FTPS assuming the control connection is encrypted, one uses plaintext FTP.';
                }

                field(CertificateValidation; Rec.ValidationCertificate)
                {
                    ApplicationArea = All;
                    ToolTip = 'X509: XC509 client certificates to be used in SSL authentication process. Validate: An event is fired to validate SSL certificates, if this event is not handled and there are errors validating the certificate the connection will be aborted. ValidateAny: Accept any SSL certificate received from the server and skip performing the validation using the ValidateCertificate callback.';
                }

                field(ValidateCertificateRevocation; Rec.ValidateCertificateRevocation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if the certificate revocation list is checked during authentication. Useful when you need to maintain the certificate chain validation, but skip the certificate revocation check.';
                }

                field(SSLBuffering; Rec.SSLBuffering)
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether to use SSL Buffering to speed up data transfer during FTP operations. Turn this off if you are having random issues with FTPS/SSL file transfer';
                }

                field(FtpSslCertDisplay; this.FtpSslCertDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'SSL Certificate';
                    ToolTip = 'Specifies the SSL Certificate for the FTPS connection. Click the assist button to set or update.';
                    ExtendedDatatype = Masked;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        this.EnterSslCert();
                    end;
                }

                field(XC509Cert; Rec.XC509Cert)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the SSL certificate being used is XC509 P12.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetPgpPublicKey)
            {
                ApplicationArea = All;
                Caption = 'Set Public Key';
                ToolTip = 'Paste the PGP public key used to encrypt uploads.';
                Image = Certificate;
                Enabled = Rec."File Encryption Mode" = Rec."File Encryption Mode"::PGP;

                trigger OnAction()
                begin
                    this.EnterPgpPublicKey();
                end;
            }

            action(SetPgpPrivateKey)
            {
                ApplicationArea = All;
                Caption = 'Set Private Key';
                ToolTip = 'Paste the PGP private key used to decrypt downloads.';
                Image = Certificate;
                Enabled = Rec."File Encryption Mode" = Rec."File Encryption Mode"::PGP;

                trigger OnAction()
                begin
                    this.EnterPgpPrivateKey();
                end;
            }

            action(SetPgpPassphrase)
            {
                ApplicationArea = All;
                Caption = 'Set Passphrase';
                ToolTip = 'Set the passphrase for the PGP private key (leave blank if none).';
                Enabled = Rec."File Encryption Mode" = Rec."File Encryption Mode"::PGP;
                Image = Info;

                trigger OnAction()
                begin
                    this.EnterPgpPassphrase();
                end;
            }

            action(ClearPgpKeys)
            {
                ApplicationArea = All;
                Caption = 'Clear PGP Keys';
                ToolTip = 'Remove all stored PGP keys for this host.';
                Image = Delete;
                Enabled = Rec."File Encryption Mode" = Rec."File Encryption Mode"::PGP;

                trigger OnAction()
                begin
                    this.FtpHostMgt.DeletePgpKeys(Rec.Name);
                    this.PgpPublicKeyDisplay := this.NotSetTok;
                    this.PgpPrivateKeyDisplay := this.NotSetTok;
                end;
            }

            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Connect';
                ToolTip = 'Test Ftp connection.';
                Image = Web;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    FtpMgt: Codeunit DBCSFtpMgtPTE;
                    FtpHostMgt: Codeunit DBCSFtpHostMgtPTE;
                    FtpClientMgt: Codeunit DBCSftpFileMgtPTE;
                    JSettings: JsonObject;
                    ResponseTxt: Text;
                    Pwd: SecretText;
                    SslCert: SecretText;
                begin
                    FtpHostMgt.GetHostDetails(Rec.Name, JSettings, Pwd, SslCert);
                    FtpClientMgt.UpdateClientPageSettings(JSettings, Rec.RootFolder);
                    ResponseTxt := FtpMgt.Connect(JSettings);

                    Message(ResponseTxt);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        this.LoadHostDetails();
    end;

    [NonDebuggable]
    local procedure LoadHostDetails()
    var
        HasPwd: Boolean;
        HasSslCert: Boolean;
        HasPublic: Boolean;
        HasPrivate: Boolean;
    begin
        this.FtpHostMgt.GetHostDetails(Rec.Name, this.FtpHost, this.FtpUser, this.FtpPasswd, this.FtpSslCert);
        this.FtpHostMgt.HasSecrets(Rec.Name, HasPwd, HasSslCert);
        if HasPwd then
            this.FtpPasswdDisplay := this.SecretIsSetTok;
        if HasSslCert then
            this.FtpSslCertDisplay := this.SecretIsSetTok;

        this.FtpHostMgt.HasPgpKeys(Rec.Name, HasPublic, HasPrivate);
        if HasPublic then
            this.PgpPublicKeyDisplay := this.SecretIsSetTok
        else
            this.PgpPublicKeyDisplay := this.NotSetTok;
        if HasPrivate then
            this.PgpPrivateKeyDisplay := this.SecretIsSetTok
        else
            this.PgpPrivateKeyDisplay := this.NotSetTok;
    end;

    [NonDebuggable]
    local procedure UpdateHostDetails()
    begin
        this.FtpHostMgt.UpdateHostDetails(Rec.Name, this.FtpHost, this.FtpUser, this.FtpPasswd, this.FtpSslCert, Rec.Port);
    end;

    [NonDebuggable]
    local procedure EnterPassword()
    var
        SecretInput: Page DBCSftpSecretInputPTE;
        NewSecret: SecretText;
    begin
        if SecretInput.RunModal() = Action::OK then begin
            SecretInput.GetSecret(NewSecret);
            if not NewSecret.IsEmpty() then begin
                this.FtpPasswd := NewSecret;
                this.FtpPasswdDisplay := this.SecretIsSetTok;
                this.UpdateHostDetails();
            end;
        end;
    end;

    [NonDebuggable]
    local procedure EnterSslCert()
    var
        SecretInput: Page DBCSftpSecretInputPTE;
        NewSecret: SecretText;
    begin
        if SecretInput.RunModal() = Action::OK then begin
            SecretInput.GetSecret(NewSecret);
            if not NewSecret.IsEmpty() then begin
                this.FtpSslCert := NewSecret;
                this.FtpSslCertDisplay := this.SecretIsSetTok;
                this.UpdateHostDetails();
            end;
        end;
    end;

    [NonDebuggable]
    local procedure EnterPgpPublicKey()
    var
        KeyInput: Page DBCSFtpPgpKeyInputPTE;
        KeyText: Text;
        EmptyText: Text;
    begin
        KeyInput.Caption := 'PGP Public Key';
        if KeyInput.RunModal() = Action::OK then begin
            KeyInput.GetKeyText(KeyText);
            if KeyText <> '' then begin
                this.FtpHostMgt.UpdatePgpKeys(Rec.Name, KeyText, EmptyText, EmptyText);
                this.PgpPublicKeyDisplay := this.SecretIsSetTok;
            end;
        end;
    end;

    [NonDebuggable]
    local procedure EnterPgpPrivateKey()
    var
        KeyInput: Page DBCSFtpPgpKeyInputPTE;
        KeyText: Text;
        EmptyText: Text;
    begin
        KeyInput.Caption := 'PGP Private Key';
        if KeyInput.RunModal() = Action::OK then begin
            KeyInput.GetKeyText(KeyText);
            if KeyText <> '' then begin
                this.FtpHostMgt.UpdatePgpKeys(Rec.Name, EmptyText, KeyText, EmptyText);
                this.PgpPrivateKeyDisplay := this.SecretIsSetTok;
            end;
        end;
    end;

    [NonDebuggable]
    local procedure EnterPgpPassphrase()
    var
        KeyInput: Page DBCSFtpPgpKeyInputPTE;
        PassText: Text;
        EmptyText: Text;
    begin
        KeyInput.Caption := 'PGP Passphrase';
        if KeyInput.RunModal() = Action::OK then begin
            KeyInput.GetKeyText(PassText);
            if PassText <> '' then
                this.FtpHostMgt.UpdatePgpKeys(Rec.Name, EmptyText, EmptyText, PassText);
        end;
    end;

    var
        [NonDebuggable]
        FtpHostMgt: Codeunit DBCSFtpHostMgtPTE;
        FtpHost: Text;
        FtpUser: Text;
        [NonDebuggable]
        FtpPasswd: SecretText;
        FtpPasswdDisplay: Text;
        [NonDebuggable]
        FtpSslCert: SecretText;
        FtpSslCertDisplay: Text;
        PgpPublicKeyDisplay: Text;
        PgpPrivateKeyDisplay: Text;
        SecretIsSetTok: Label '●●●●●●●●', Locked = true;
        NotSetTok: Label '(not set)', Locked = true;
}
