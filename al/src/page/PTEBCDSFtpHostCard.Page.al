page 50135 PTEBCDSFtpHostCard
{
    Caption = 'Daves Sftp Host Card';
    PageType = Card;
    SourceTable = PTEBCSFtpHost;
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

                field(FtpPasswd; this.FtpPasswd)
                {
                    Caption = 'FTP Passwd';
                    ToolTip = 'Specifies the FTP Password.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        this.UpdateHostDetails();
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

            group(Options)
            {
                field(Port; Rec.Port)
                {
                    ApplicationArea = All;
                    ToolTip = 'The FTP port to connect to. 0: Auto (21 or 990 depending on FTPS config)';
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

                field(FtpSslCert; this.FtpSslCert)
                {
                    ApplicationArea = All;
                    Caption = 'SSL Certificate';
                    ToolTip = 'Specify the SSL Certifate to use for the connection FTPS. Paste raw certificate text, or assist edit to upload from files.';
                    ExtendedDatatype = Masked;
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        this.UpdateHostDetails();
                    end;

                    trigger OnAssistEdit()
                    var
                        ReadStream: InStream;
                        Filename: Text;
                        SelectFileMsg: Label 'Select Certificate file';
                        CertificateLoadedOkMsg: Label 'Certificate loaded ok.';
                    begin
                        UploadIntoStream(SelectFileMsg, '', '', Filename, ReadStream);
                        if ReadStream.Read(this.FtpSslCert) = 0 then
                            exit;

                        this.UpdateHostDetails();
                        Message(CertificateLoadedOkMsg);
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
                    FtpMgt: Codeunit PTEBCDSFtpMgt;
                    FtpHostMgt: Codeunit PTEBCDSFtpHostMgt;
                    FtpClientMgt: Codeunit PTEBCDSftpFileMgt;
                    JSettings: JsonObject;
                    ResponseTxt: Text;
                begin
                    FtpHostMgt.GetHostDetails(Rec.Name, JSettings);
                    FtpClientMgt.UpdateClientPageSettings(JSettings, Rec.RootFolder);
                    ResponseTxt := FtpMgt.Connect(JSettings);

                    Message(ResponseTxt);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        this.GetHostDetails();
    end;

    [NonDebuggable]
    local procedure GetHostDetails()
    begin
        this.FtpHostMgt.GetHostDetails(Rec.Name, this.FtpHost, this.FtpUser, this.FtpPasswd, this.FtpSslCert);
    end;

    [NonDebuggable]
    local procedure UpdateHostDetails()
    begin
        this.FtpHostMgt.UpdateHostDetails(Rec.Name, this.FtpHost, this.FtpUser, this.FtpPasswd, this.FtpSslCert);
    end;

    var
        [NonDebuggable]
        FtpHostMgt: Codeunit PTEBCDSFtpHostMgt;
        FtpHost: Text;
        FtpUser: Text;
        [NonDebuggable]
        FtpPasswd: Text;
        [NonDebuggable]
        FtpSslCert: Text;
}
