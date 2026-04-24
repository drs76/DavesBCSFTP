namespace SinclairSoftScotland.BCSimpleSFTP;

codeunit 58555 SSSSFtpHostMgtPTE
{
    var
        HostnameLbl: Label 'hostName';
        UsernameLbl: Label 'userName';
        PortLbl: Label 'port';
        HostCodeLbl: Label 'hostCode', Locked = true;
        PwdKeyTok: Label '%1|pwd', Locked = true;
        SslCertKeyTok: Label '%1|sslcert', Locked = true;
        AesKeyTok: Label '%1|aeskey', Locked = true;


    [NonDebuggable]
    internal procedure UpdateHostDetails(FtpName: Text; Host: Text; Usr: Text; Pwd: SecretText; SslCert: SecretText; Port: Integer)
    var
        JObject: JsonObject;
    begin
        if StrLen(FtpName) = 0 then
            exit;

        this.UpdateObject(JObject, this.HostnameLbl, Host);
        this.UpdateObject(JObject, this.UsernameLbl, Usr);
        this.UpdateObject(JObject, this.PortLbl, Format(Port));
        this.SaveInIsolatedStorage(FtpName, JObject);

        IsolatedStorage.Set(StrSubstNo(this.PwdKeyTok, FtpName), Pwd, DataScope::Company);
        IsolatedStorage.Set(StrSubstNo(this.SslCertKeyTok, FtpName), SslCert, DataScope::Company);
    end;

    [NonDebuggable]
    internal procedure GetHostDetails(FtpName: Text; var Host: Text; var Usr: Text; var Pwd: SecretText; var SslCert: SecretText)
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

        if IsolatedStorage.Contains(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company, Pwd);

        if IsolatedStorage.Contains(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company, SslCert);
    end;

    [NonDebuggable]
    internal procedure GetHostDetails(FtpName: Text; var JObject: JsonObject; var Pwd: SecretText; var SslCert: SecretText)
    var
        KeyValue: Text;
    begin
        if not IsolatedStorage.Contains(FtpName, DataScope::Company) then
            exit;

        IsolatedStorage.Get(FtpName, DataScope::Company, KeyValue);
        JObject.ReadFrom(KeyValue);

        // Stamp hostCode so BuildRequest can retrieve secrets at send time
        this.UpdateObject(JObject, this.HostCodeLbl, FtpName);

        if IsolatedStorage.Contains(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company, Pwd);

        if IsolatedStorage.Contains(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company, SslCert);
    end;

    [NonDebuggable]
    internal procedure GetSecrets(FtpName: Text; var Pwd: SecretText; var SslCert: SecretText)
    begin
        if IsolatedStorage.Contains(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company, Pwd);

        if IsolatedStorage.Contains(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company, SslCert);
    end;

    internal procedure HasSecrets(FtpName: Text; var HasPwd: Boolean; var HasSslCert: Boolean)
    begin
        HasPwd := IsolatedStorage.Contains(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company);
        HasSslCert := IsolatedStorage.Contains(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company);
    end;

    internal procedure DeleteHostDetails(FtpName: Text)
    begin
        if IsolatedStorage.Contains(FtpName, DataScope::Company) then
            IsolatedStorage.Delete(FtpName, DataScope::Company);
        if IsolatedStorage.Contains(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Delete(StrSubstNo(this.PwdKeyTok, FtpName), DataScope::Company);
        if IsolatedStorage.Contains(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Delete(StrSubstNo(this.SslCertKeyTok, FtpName), DataScope::Company);
        this.DeleteAesKey(FtpName);
    end;

    [NonDebuggable]
    internal procedure GenerateAndStoreAesKey(FtpName: Text)
    var
        AesKey: Text;
    begin
        AesKey := DelChr(CreateGuid(), '=', '{}-');
        IsolatedStorage.Set(StrSubstNo(this.AesKeyTok, FtpName), AesKey, DataScope::Company);
    end;

    [NonDebuggable]
    internal procedure GetAesKey(FtpName: Text; var AesKey: Text)
    begin
        if IsolatedStorage.Contains(StrSubstNo(this.AesKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Get(StrSubstNo(this.AesKeyTok, FtpName), DataScope::Company, AesKey);
    end;

    internal procedure HasAesKey(FtpName: Text): Boolean
    begin
        exit(IsolatedStorage.Contains(StrSubstNo(this.AesKeyTok, FtpName), DataScope::Company));
    end;

    internal procedure DeleteAesKey(FtpName: Text)
    begin
        if IsolatedStorage.Contains(StrSubstNo(this.AesKeyTok, FtpName), DataScope::Company) then
            IsolatedStorage.Delete(StrSubstNo(this.AesKeyTok, FtpName), DataScope::Company);
    end;

    internal procedure GetHostCode(JSettings: JsonObject): Text
    var
        JToken: JsonToken;
    begin
        if JSettings.Contains(this.HostCodeLbl) then
            JSettings.Get(this.HostCodeLbl, JToken)
        else
            if JSettings.Contains(this.HostnameLbl) then
                JSettings.Get(this.HostnameLbl, JToken)
            else
                exit;

        exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    internal procedure UpdateSslCert(FtpName: Text; Host: Text; Usr: Text; Pwd: SecretText; Port: Integer)
    var
        JObject: JsonObject;
    begin
        this.UpdateObject(JObject, this.HostnameLbl, Host);
        this.UpdateObject(JObject, this.UsernameLbl, Usr);
        this.UpdateObject(JObject, this.PortLbl, Format(Port));
        this.SaveInIsolatedStorage(FtpName, JObject);

        IsolatedStorage.Set(StrSubstNo(this.PwdKeyTok, FtpName), Pwd, DataScope::Company);
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

    local procedure UpdateObject(var JObject: JsonObject; Name: Text; Value: Text)
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
