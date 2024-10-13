controladdin PTEBCDSFtpFileContent
{
    MinimumWidth = 250;
    MinimumHeight = 250;
    RequestedHeight = 600;
    RequestedWidth = 400;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'src/controladdins/filecontent/scripts/fileContent.js';
    StartupScript = 'src/controladdins/filecontent/scripts/fileContentStart.js';

    event ControlReady();

    procedure Init();

    procedure Load(data: Text);
}