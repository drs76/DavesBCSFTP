namespace SinclairSoftScotland.BCSimpleSFTP;

controladdin SSSSFtpFileContentPTE
{
    MinimumWidth = 250;
    MinimumHeight = 250;
    RequestedHeight = 600;
    RequestedWidth = 400;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'src/controladdin/SSSSFtpFileContent/fileContent.js';
    StartupScript = 'src/controladdin/SSSSFtpFileContent/fileContentStart.js';

    event ControlReady();

    procedure Init();

    procedure Load(data: Text; filename: Text);
}