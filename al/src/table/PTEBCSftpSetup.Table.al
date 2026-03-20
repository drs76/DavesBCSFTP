table 50137 PTEBCSftpSetup
{
    Caption = 'Daves Sftp Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[1])
        {
            Caption = 'PrimaryKey';
        }
        field(2; "Azure Sftp Host"; Text[2048])
        {
            Caption = 'Azure Sftp Host';
            ExtendedDatatype = URL;
        }
        field(3; "Azure Sftp Port"; Integer)
        {
            Caption = 'Azure Sftp Port';
        }
        field(4; "Azure Sftp Username"; Text[250])
        {
            Caption = 'Azure Sftp Username';
        }
        field(6; TreatAsTextFiles; Text[2048])
        {
            Caption = 'Treat As Text';
            InitValue = '.txt,.csv,.log,.json,.xml,.html,.al,.cs,.sh,.ps1';
        }
    }
    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;
        StorageKeyTok: Label 'PTEBCSftpSetupSecrets', Locked = true;
        FunctionKeyTok: Label 'functionKey', Locked = true;

    procedure GetRecordOnce()
    begin
        if this.RecordHasBeenRead then
            exit;
        Rec.Get();
        this.RecordHasBeenRead := true;
    end;

    [NonDebuggable]
    procedure SetFunctionKey(NewKey: SecretText)
    var
        JObject: JsonObject;
        KeyValue: Text;
    begin
        if IsolatedStorage.Contains(this.StorageKeyTok, DataScope::Company) then begin
            IsolatedStorage.Get(this.StorageKeyTok, DataScope::Company, KeyValue);
            JObject.ReadFrom(KeyValue);
        end;

        if JObject.Contains(this.FunctionKeyTok) then
            JObject.Replace(this.FunctionKeyTok, NewKey.Unwrap())
        else
            JObject.Add(this.FunctionKeyTok, NewKey.Unwrap());

        JObject.WriteTo(KeyValue);
        IsolatedStorage.Set(this.StorageKeyTok, KeyValue, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetFunctionKey(var FunctionKey: SecretText)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        KeyValue: Text;
    begin
        if not IsolatedStorage.Contains(this.StorageKeyTok, DataScope::Company) then
            exit;

        IsolatedStorage.Get(this.StorageKeyTok, DataScope::Company, KeyValue);
        JObject.ReadFrom(KeyValue);

        if JObject.Get(this.FunctionKeyTok, JToken) then
            FunctionKey := JToken.AsValue().AsText();
    end;

    procedure DeleteSecrets()
    begin
        if IsolatedStorage.Contains(this.StorageKeyTok, DataScope::Company) then
            IsolatedStorage.Delete(this.StorageKeyTok, DataScope::Company);
    end;
}
