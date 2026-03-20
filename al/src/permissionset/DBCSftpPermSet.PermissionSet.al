permissionset 50000 DBCSftpPermSetPTE
{
    Assignable = true;
    Caption = 'DavesSftp', MaxLength = 30;
    Permissions =
        table DBCSFtpHostPTE = X,
        tabledata DBCSFtpHostPTE = RMID,
        table DBCSftpFileBufferPTE = X,
        tabledata DBCSftpFileBufferPTE = RMID,
        table DBCSftpSetupPTE = X,
        tabledata DBCSftpSetupPTE = RMID,
        table DBCFTPDownloadedFilePTE = X,
        tabledata DBCFTPDownloadedFilePTE = RMID,
        page DBCSFtpFileContentPTE = X,
        page DBCSftpDownloadedFilesPTE = X,
        page DBCSFtpClientFilesPartPTE = X,
        page DBCSFtpHostCardPTE = X,
        page DBCSFtpHostsPTE = X,
        page DBCSftpClientPTE = X,
        page DBCSftpSecretInputPTE = X,
        page DBCSftpSetupPTE = X,
        page DBCSFtpZipContentsPTE = X,
        codeunit DBCSFtpHostMgtPTE = X,
        codeunit DBCSftpFileMgtPTE = X,
        codeunit DBCSftpParamsPTE = X,
        codeunit DBCSFtpMgtPTE = X;
}
