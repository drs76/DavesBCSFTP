codeunit 50135 PTEBCDSFtpHostMgt
{
    var
        HostnameLbl: Label 'hostName';
        UsernameLbl: Label 'userName';
        PasswdLbl: Label 'password';
        SSLCertLbl: Label 'sslCert';


    internal procedure UpdateHostDetails(FtpName: Text; Host: Text; Usr: Text; Pwd: Text; SslCert: Text)
    var
        JObject: JsonObject;
    begin
        if StrLen(FtpName) = 0 then
            exit;

        this.UpdateObject(JObject, this.HostnameLbl, Host);
        this.UpdateObject(JObject, this.UsernameLbl, Usr);
        this.UpdateObject(JObject, this.PasswdLbl, Pwd);
        this.UpdateObject(JObject, this.SSLCertLbl, SslCert);

        this.SaveInIsolatedStorage(FtpName, JObject);
    end;

    internal procedure GetHostDetails(FtpName: Text; var Host: Text; var Usr: Text; var Pwd: Text; var SslCert: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        KeyValue: Text;
    begin
        if not IsolatedStorage.Contains(FtpName, DataScope::Company) then
            exit;

        IsolatedStorage.Get(FtpName, DataScope::Company, KeyValue);
        JObject.ReadFrom(KeyValue);

        if JObject.Get(this.HostnameLbl, JToken) then
            Host := JToken.AsValue().AsText();

        if JObject.Get(this.UsernameLbl, JToken) then
            Usr := JToken.AsValue().AsText();

        if JObject.Get(this.PasswdLbl, JToken) then
            Pwd := JToken.AsValue().AsText();

        if JObject.Get(this.SSLCertLbl, JToken) then
            SslCert := JToken.AsValue().AsText();
    end;

    internal procedure GetHostDetails(FtpName: Text; var JObject: JsonObject)
    var
        KeyValue: Text;
    begin
        if not IsolatedStorage.Contains(FtpName, DataScope::Company) then
            exit;

        IsolatedStorage.Get(FtpName, DataScope::Company, KeyValue);
        JObject.ReadFrom(KeyValue);
    end;

    internal procedure DeleteHostDetails(FtpName: Text)
    begin
        if IsolatedStorage.Contains(FtpName, DataScope::Company) then
            IsolatedStorage.Delete(FtpName, DataScope::Company);
    end;

    internal procedure GetHostCode(JSettings: JsonObject): Text
    var
        JToken: JsonToken;
        HostCodeLbl: Label 'hostCode';
    begin
        if JSettings.Contains(HostCodeLbl) then
            JSettings.Get(HostCodeLbl, JToken)
        else
            if JSettings.Contains(this.HostnameLbl) then
                JSettings.Get(this.HostnameLbl, JToken)
            else
                exit;

        exit(JToken.AsValue().AsText());
    end;


    local procedure UpdateObject(var JObject: JsonObject; Name: Text; Value: Variant)
    var
        JObjectToStore: JsonObject;
    begin
        if Value.IsText() then
            this.UpdateObject(JObject, Name, Format(Value));

        if Value.IsJsonObject() then begin
            JObjectToStore := Value;
            this.UpdateObject(JObject, name, JObjectToStore);
        end;
    end;

    internal procedure UpdateSslCert(FtpName: Text; Host: Text; Usr: Text; Pwd: Text)
    var
        JObject: JsonObject;
    begin
        this.UpdateObject(JObject, this.HostnameLbl, Host);
        this.UpdateObject(JObject, this.UsernameLbl, Usr);
        this.UpdateObject(JObject, this.PasswdLbl, Pwd);

        this.SaveInIsolatedStorage(FtpName, JObject);
    end;

    local procedure UpdateObject(var JObject: JsonObject; Name: Text; Value: Text)
    var
    begin
        if JObject.Contains(Name) then
            JObject.Replace(Name, Value)
        else
            JObject.Add(Name, Value);
    end;

    local procedure SaveInIsolatedStorage(FtpName: Text; JObject: JsonObject)
    var
        KeyValue: Text;
    begin
        JObject.WriteTo(KeyValue);
        IsolatedStorage.Set(FtpName, KeyValue, DataScope::Company);
    end;
}
