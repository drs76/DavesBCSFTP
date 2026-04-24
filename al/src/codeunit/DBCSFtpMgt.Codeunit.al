namespace DaveSinclair.DavesBCSFTP;

codeunit 50134 DBCSFtpMgtPTE
{
    var
        SFtpSetup: Record DBCSftpSetupPTE;
        HttpRequest: HttpRequestMessage;
        HttpClient: HttpClient;
        ConnectFtpTok: Label 'connectSFtp', Locked = true;
        GetFileListFtpTok: Label 'ListFiles', Locked = true;
        DownloadFileFtpTok: Label 'DownloadFile', Locked = true;
        DownloadFolderFtpTok: Label 'DownloadFolder', Locked = true;
        UploadFileFtpTok: Label 'UploadFile', Locked = true;
        EncryptFileFtpTok: Label 'EncryptFile', Locked = true;
        DecryptFileFtpTok: Label 'DecryptFile', Locked = true;
        ActionLbl: Label 'action', Locked = true;
        FolderNameTok: Label 'folderName', Locked = true;
        FileNameTok: Label 'fileName', Locked = true;
        FileContentLbl: Label 'fileContent', Locked = true;
        PgpPublicKeyLbl: Label 'pgpPublicKey', Locked = true;
        PgpPrivateKeyLbl: Label 'pgpPrivateKey', Locked = true;
        PgpPassphraseLbl: Label 'pgpPassphrase', Locked = true;
        ResponseLbl: Label 'response', Locked = true;
        HttpStatusLbl: Label 'httpStatus', Locked = true;
        HttpStatusOkLbl: Label 'httpStatusOk', Locked = true;
        TextTypesLbl: Label 'textTypes', Locked = true;
        FunctionsKeyHeaderTok: Label 'x-functions-key', Locked = true;
        SftpPasswordHeaderTok: Label 'x-sftp-password', Locked = true;
        SftpSslCertHeaderTok: Label 'x-sftp-sslcert', Locked = true;


    internal procedure Connect(JSettings: JsonObject) Result: Text
    begin
        this.AddToSettings(JSettings, this.ActionLbl, this.ConnectFtpTok);
        this.AddTextTypes(JSettings);
        this.BuildRequest(JSettings, this.ConnectFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure GetFilesList(JSettings: JsonObject; FolderName: Text) Result: Text
    begin
        this.AddToSettings(JSettings, this.FolderNameTok, FolderName);
        this.AddToSettings(JSettings, this.ActionLbl, this.GetFileListFtpTok);
        this.AddTextTypes(JSettings);
        this.BuildRequest(JSettings, this.GetFileListFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure DownLoadFile(JSettings: JsonObject; FileName: Text) Result: Text
    begin
        this.AddToSettings(JSettings, this.FileNameTok, FileName);
        this.AddToSettings(JSettings, this.ActionLbl, this.DownloadFileFtpTok);
        this.AddTextTypes(JSettings);
        this.BuildRequest(JSettings, this.DownloadFileFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure DownLoadFolder(JSettings: JsonObject; FolderName: Text) Result: Text
    begin
        this.AddToSettings(JSettings, this.FolderNameTok, FolderName);
        this.AddToSettings(JSettings, this.ActionLbl, this.DownloadFolderFtpTok);
        this.AddTextTypes(JSettings);
        this.BuildRequest(JSettings, this.DownloadFolderFtpTok);
        Result := this.SendRequest();
        Result := this.GetResult(Result);
    end;

    internal procedure UploadFile(JSettings: JsonObject; FileName: Text; FolderName: Text; FileContentBase64: Text)
    var
        UploadSettings: JsonObject;
        Result: Text;
    begin
        UploadSettings := JSettings;
        this.AddToSettings(UploadSettings, this.FileNameTok, FileName);
        this.AddToSettings(UploadSettings, this.FolderNameTok, FolderName);
        this.AddToSettings(UploadSettings, this.FileContentLbl, FileContentBase64);
        this.AddToSettings(UploadSettings, this.ActionLbl, this.UploadFileFtpTok);
        this.BuildRequest(UploadSettings, this.UploadFileFtpTok);
        Result := this.SendRequest();
        this.GetResult(Result);
    end;

    [NonDebuggable]
    internal procedure EncryptFile(JSettings: JsonObject; FileContentBase64: Text) EncryptedBase64: Text
    var
        FtpHostMgt: Codeunit DBCSFtpHostMgtPTE;
        CryptoBody: JsonObject;
        PubKey: Text;
        PrivKey: Text;
        Passphrase: Text;
        HostCode: Text;
        Result: Text;
    begin
        HostCode := FtpHostMgt.GetHostCode(JSettings);
        FtpHostMgt.GetPgpKeys(HostCode, PubKey, PrivKey, Passphrase);
        CryptoBody.Add(this.FileContentLbl, FileContentBase64);
        CryptoBody.Add(this.PgpPublicKeyLbl, PubKey);
        this.BuildCryptoRequest(CryptoBody, this.EncryptFileFtpTok);
        Result := this.SendRequest();
        EncryptedBase64 := this.ExtractFileContent(this.GetResult(Result));
    end;

    [NonDebuggable]
    internal procedure DecryptFile(JSettings: JsonObject; EncryptedBase64: Text) DecryptedBase64: Text
    var
        FtpHostMgt: Codeunit DBCSFtpHostMgtPTE;
        CryptoBody: JsonObject;
        PubKey: Text;
        PrivKey: Text;
        Passphrase: Text;
        HostCode: Text;
        Result: Text;
    begin
        HostCode := FtpHostMgt.GetHostCode(JSettings);
        FtpHostMgt.GetPgpKeys(HostCode, PubKey, PrivKey, Passphrase);
        CryptoBody.Add(this.FileContentLbl, EncryptedBase64);
        CryptoBody.Add(this.PgpPrivateKeyLbl, PrivKey);
        if Passphrase <> '' then
            CryptoBody.Add(this.PgpPassphraseLbl, Passphrase);
        this.BuildCryptoRequest(CryptoBody, this.DecryptFileFtpTok);
        Result := this.SendRequest();
        DecryptedBase64 := this.ExtractFileContent(this.GetResult(Result));
    end;

    local procedure AddTextTypes(var JSettings: JsonObject)
    begin
        this.SFtpSetup.GetRecordOnce();
        this.AddToSettings(JSettings, this.TextTypesLbl, this.SFtpSetup.TreatAsTextFiles);
    end;

    //[NonDebuggable]
    local procedure BuildRequest(JSettings: JsonObject; Function: Text)
    var
        BCSftpSetup: Record DBCSftpSetupPTE;
        FtpHostMgt: Codeunit DBCSFtpHostMgtPTE;
        RequestHeaders: HttpHeaders;
        FunctionKey: SecretText;
        Pwd: SecretText;
        SslCert: SecretText;
        HostCode: Text;
        SettingsString: Text;
        UrlTxt: Label '%1?action=%2', Locked = true;
    begin
        BCSftpSetup.Get();
        BCSftpSetup.TestField("Azure Sftp Host");

        HostCode := FtpHostMgt.GetHostCode(JSettings);
        if HostCode <> '' then
            FtpHostMgt.GetSecrets(HostCode, Pwd, SslCert);

        JSettings.WriteTo(SettingsString);

        Clear(this.HttpRequest);
        this.HttpRequest.Method := 'POST';
        this.HttpRequest.Content.WriteFrom(SettingsString);
        this.HttpRequest.SetRequestUri(StrSubstNo(UrlTxt, BCSftpSetup."Azure Sftp Host", Function));

        this.HttpRequest.GetHeaders(RequestHeaders);
        BCSftpSetup.GetFunctionKey(FunctionKey);
        if not FunctionKey.IsEmpty() then
            RequestHeaders.Add(this.FunctionsKeyHeaderTok, FunctionKey);
        if not Pwd.IsEmpty() then
            RequestHeaders.Add(this.SftpPasswordHeaderTok, Pwd);
        if not SslCert.IsEmpty() then
            RequestHeaders.Add(this.SftpSslCertHeaderTok, SslCert);
    end;

    local procedure SendRequest() ReturnValue: Text
    var
        HttpResponse: HttpResponseMessage;
        JObject: JsonObject;
    begin
        Clear(this.HttpClient);
        if not this.HttpClient.Send(this.HttpRequest, HttpResponse) then begin
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

    local procedure BuildCryptoRequest(JBody: JsonObject; Action: Text)
    var
        BCSftpSetup: Record DBCSftpSetupPTE;
        RequestHeaders: HttpHeaders;
        FunctionKey: SecretText;
        BodyString: Text;
        UrlTxt: Label '%1?action=%2', Locked = true;
    begin
        BCSftpSetup.Get();
        BCSftpSetup.TestField("Azure Sftp Host");

        JBody.WriteTo(BodyString);

        Clear(this.HttpRequest);
        this.HttpRequest.Method := 'POST';
        this.HttpRequest.Content.WriteFrom(BodyString);
        this.HttpRequest.SetRequestUri(StrSubstNo(UrlTxt, BCSftpSetup."Azure Sftp Host", Action));

        this.HttpRequest.GetHeaders(RequestHeaders);
        BCSftpSetup.GetFunctionKey(FunctionKey);
        if not FunctionKey.IsEmpty() then
            RequestHeaders.Add(this.FunctionsKeyHeaderTok, FunctionKey);
    end;

    local procedure ExtractFileContent(Response: Text) Content: Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.ReadFrom(Response) then
            if JObject.Get(this.FileContentLbl, JToken) then
                Content := JToken.AsValue().AsText();
    end;

    local procedure AddToSettings(var Settings: JsonObject; Prop: Text; Value: Text)
    begin
        if Settings.Keys().Contains(Prop) then
            Settings.Replace(Prop, Value)
        else
            Settings.Add(Prop, Value);
    end;
}
