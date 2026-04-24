namespace SinclairSoftScotland.BCSimpleSFTP;

permissionset 58571 SSSSftpPermSetPTE
{
    Assignable = true;
    Caption = 'SimpleSftpPTE', MaxLength = 30;
    Permissions =
        table SSSSFtpHostPTE = X,
        tabledata SSSSFtpHostPTE = RMID,
        table SSSSftpFileBufferPTE = X,
        tabledata SSSSftpFileBufferPTE = RMID,
        table SSSSftpSetupPTE = X,
        tabledata SSSSftpSetupPTE = RMID,
        table SSSFTPDownloadedFilePTE = X,
        tabledata SSSFTPDownloadedFilePTE = RMID,
        page SSSSFtpFileContentPTE = X,
        page SSSSftpDownloadedFilesPTE = X,
        page SSSSFtpClientFilesPartPTE = X,
        page SSSSFtpHostCardPTE = X,
        page SSSSFtpHostsPTE = X,
        page SSSSftpClientPTE = X,
        page SSSSftpSecretInputPTE = X,
        page SSSSftpSetupPTE = X,
        page SSSSFtpZipContentsPTE = X,
        codeunit SSSSFtpHostMgtPTE = X,
        codeunit SSSSftpFileMgtPTE = X,
        codeunit SSSSftpParamsPTE = X,
        codeunit SSSSFtpMgtPTE = X;
}
