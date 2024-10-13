codeunit 50134 PTEBCDSFtpMgt
{
    var
        SFtpSetup: Record PTEBCSftpSetup;
        HttpRequest: HttpRequestMessage;
        HttpClient: HttpClient;
        ConnectFtpTok: Label 'connectSFtp', Locked = true;
        GetFileListFtpTok: Label 'ListFiles', Locked = true;
        DownloadFileFtpTok: Label 'DownloadFile', Locked = true;
        DownloadFolderFtpTok: Label 'DownloadFolder', Locked = true;
        ActionLbl: Label 'action', Locked = true;
        FolderNameTok: Label 'folderName', Locked = true;
        FileNameTok: Label 'fileName', Locked = true;
        ResponseLbl: Label 'response', Locked = true;
        HttpStatusLbl: Label 'httpStatus', Locked = true;
        HttpStatusOkLbl: Label 'httpStatusOk', Locked = true;
        TextTypesLbl: Label 'textTypes', Locked = true;


    internal procedure Connect(JSettings: JsonObject) Result: Text
    var
        SettingsString: Text;
    begin
        this.AddToSettings(JSettings, this.ActionLbl, this.ConnectFtpTok);
        JSettings.WriteTo(SettingsString);
        this.AddTextTypes(JSettings);
        this.BuildRequest(SettingsString, this.ConnectFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure GetFilesList(JSettings: JsonObject; FolderName: Text) Result: Text
    var
        SettingsString: Text;
    begin
        this.AddToSettings(JSettings, this.FolderNameTok, FolderName);
        this.AddToSettings(JSettings, this.ActionLbl, this.GetFileListFtpTok);
        this.AddTextTypes(JSettings);
        JSettings.WriteTo(SettingsString);
        this.BuildRequest(SettingsString, this.GetFileListFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure DownLoadFile(JSettings: JsonObject; FileName: Text) Result: Text
    var
        SettingsString: Text;
    begin
        this.AddToSettings(JSettings, this.FileNameTok, FileName);
        this.AddToSettings(JSettings, this.ActionLbl, this.DownloadFileFtpTok);
        this.AddTextTypes(JSettings);
        JSettings.WriteTo(SettingsString);
        this.BuildRequest(SettingsString, this.DownloadFileFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure DownLoadFolder(JSettings: JsonObject; FolderName: Text) Result: Text
    var
        SettingsString: Text;
    begin
        this.AddToSettings(JSettings, this.FolderNameTok, FolderName);
        this.AddToSettings(JSettings, this.ActionLbl, this.DownloadFolderFtpTok);
        this.AddTextTypes(JSettings);
        JSettings.WriteTo(SettingsString);
        this.BuildRequest(SettingsString, this.DownloadFolderFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    local procedure AddTextTypes(var JSettings: JsonObject)
    begin
        this.SFtpSetup.GetRecordOnce();
        this.AddToSettings(JSettings, this.TextTypesLbl, this.SFtpSetup.TreatAsTextFiles);
    end;

    local procedure BuildRequest(SettingsString: Text; Function: Text)
    var
        BCSftpSetup: Record PTEBCSftpSetup;
        UrlTxt: Label '%1?action=%2';
    begin
        BCSftpSetup.Get();
        BCSftpSetup.TestField("Azure Sftp Host");

        Clear(this.HttpRequest);
        this.HttpRequest.Method := 'POST';
        this.HttpRequest.Content.WriteFrom(SettingsString);
        this.HttpRequest.SetRequestUri(StrSubstNo(UrlTxt, BCSftpSetup."Azure Sftp Host", Function));
    end;

    local procedure SendRequest() ReturnValue: Text
    var
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        JObject: JsonObject;
    begin
        Clear(this.HttpClient);
        HttpContent := this.HttpRequest.Content();
        if not this.HttpClient.Post(this.HttpRequest.GetRequestUri(), HttpContent, HttpResponse) then begin
            JObject.Add(this.HttpStatusLbl, HttpResponse.HttpStatusCode());
            JObject.Add(this.HttpStatusOkLbl, false);
            JObject.Add(this.ResponseLbl, GetLastErrorText());
        end else begin
            JObject.Add(this.HttpStatusLbl, HttpResponse.HttpStatusCode());
            JObject.Add(this.HttpStatusOkLbl, HttpResponse.IsSuccessStatusCode());
            HttpResponse.Content().ReadAs(ReturnValue);
            JObject.Add(this.ResponseLbl, ReturnValue);
        end;
        JObject.WriteTo(ReturnValue);
    end;


    local procedure GetResult(JsonResult: Text) Result: Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        ValueLbl: Label 'value';
    begin
        JObject.ReadFrom(JsonResult);

        // check for error first
        if JObject.Get(this.HttpStatusOkLbl, JToken) then
            if JToken.AsValue().AsBoolean() = false then
                if JObject.Get(this.ResponseLbl, JToken) then
                    if JToken.IsValue() then
                        Error(JToken.AsValue().AsText())
                    else
                        if JToken.AsObject().Get(ValueLbl, JToken) then
                            Error(JToken.AsValue().AsText());

        if not JObject.Get(this.ResponseLbl, JToken) then
            exit;

        if JToken.IsArray() then
            JToken.WriteTo(Result);

        if JToken.IsObject() then
            JToken.WriteTo(Result);

        if JToken.IsObject() then
            JToken.WriteTo(Result);

        if JToken.IsValue() then
            exit(JToken.AsValue().AsText());
    end;

    local procedure AddToSettings(var Settings: JsonObject; Prop: Text; Value: Text)
    begin
        if Settings.Keys().Contains(Prop) then
            Settings.Replace(Prop, Value)
        else
            Settings.Add(Prop, Value);
    end;
}
