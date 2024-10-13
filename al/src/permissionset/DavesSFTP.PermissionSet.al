permissionset 50134 DavesSFTP
{
    Assignable = true;
    Caption = 'DavesBCSFtp ', MaxLength = 30;
    Permissions = table PTEBCFTPDownloadedFile = X,
        tabledata PTEBCFTPDownloadedFile = RMID,
        table PTEBCSFtpHost = X,
        tabledata PTEBCSFtpHost = RMID,
        tabledata PTEBCSftpSetup = RMID,
        codeunit PTEBCDSFtpMgt = X,
        codeunit PTEBCDSFtpHostMgt = X,
        codeunit PTEBCDSftpFileMgt = X,
        page PTEBCDSFtpHosts = X,
        page PTEBCDSFtpHostCard = X,
        page PTEBCDSFtpFileContent = X,
        page PTEBCDSFtpZipContents = X,
        page PTEBCDSftpDownloadedFiles = X,
        page PTEBCDSFtpClientFilesPart = X,
        page PTEBCDSftpClient = X,
        tabledata PTEBCSftpFileBuffer = RIMD,
        table PTEBCSftpFileBuffer = X,
        table PTEBCSftpSetup = X,
        page PTEBCDSftpSetup = X;
}