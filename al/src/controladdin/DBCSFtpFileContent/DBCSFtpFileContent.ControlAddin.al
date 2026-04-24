namespace DaveSinclair.DavesBCSFTP;

controladdin DBCSFtpFileContentPTE
{
    MinimumWidth = 250;
    MinimumHeight = 250;
    RequestedHeight = 600;
    RequestedWidth = 400;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'src/controladdin/DBCSFtpFileContent/fileContent.js';
    StartupScript = 'src/controladdin/DBCSFtpFileContent/fileContentStart.js';

    event ControlReady();

    procedure Init();

    procedure Load(data: Text; filename: Text);
}