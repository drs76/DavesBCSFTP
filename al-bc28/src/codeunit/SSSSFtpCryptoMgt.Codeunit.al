namespace SinclairSoftScotland.BCSimpleSFTP;

using System.Security.Encryption;
using System.Text;

codeunit 58573 SSSSFtpCryptoMgtPTE
{
    // Encrypted file format on SFTP: AES:{IV_Base64}:{Encrypted_Base64}
    // IV is random per file. Encrypted content is AES-CBC of the Base64 representation of the original bytes.
    // This allows binary files (images, PDFs, etc.) to survive the Text-based Rijndael codeunit.

    [NonDebuggable]
    internal procedure EncryptStream(var PlainInStream: InStream; AesKey: Text; var EncOutStream: OutStream)
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        Base64Convert: Codeunit "Base64 Convert";
        FileBase64: Text;
        IV: Text;
        IVBase64: Text;
        Encrypted: Text;
        Result: Text;
    begin
        FileBase64 := Base64Convert.ToBase64(PlainInStream);
        IV := CopyStr(DelChr(CreateGuid(), '=', '{}-'), 1, 16);
        IVBase64 := Base64Convert.ToBase64(IV);

        RijndaelCryptography.SetEncryptionData(Base64Convert.ToBase64(AesKey), IVBase64);
        RijndaelCryptography.SetBlockSize(128);
        RijndaelCryptography.SetCipherMode('CBC');
        Encrypted := RijndaelCryptography.Encrypt(FileBase64);

        Result := 'AES:' + IVBase64 + ':' + Encrypted;
        EncOutStream.WriteText(Result);
    end;

    [NonDebuggable]
    internal procedure DecryptStream(var EncInStream: InStream; AesKey: Text; var PlainOutStream: OutStream)
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        Base64Convert: Codeunit "Base64 Convert";
        EncContent: Text;
        IVBase64: Text;
        Encrypted: Text;
        FileBase64: Text;
        FirstColon: Integer;
        SecondColon: Integer;
        i: Integer;
        NotEncryptedErr: Label 'File does not contain AES-encrypted content. Expected format: AES:{IV}:{data}';
    begin
        EncInStream.ReadText(EncContent);

        if CopyStr(EncContent, 1, 4) <> 'AES:' then
            Error(NotEncryptedErr);

        // Find the two colons separating AES : IV : encrypted
        Clear(FirstColon);
        for i := 5 to StrLen(EncContent) do
            if CopyStr(EncContent, i, 1) = ':' then
                if FirstColon = 0 then
                    FirstColon := i
                else begin
                    SecondColon := i;
                    break;
                end;

        IVBase64 := CopyStr(EncContent, 5, FirstColon - 5);
        Encrypted := CopyStr(EncContent, SecondColon + 1, StrLen(EncContent));

        RijndaelCryptography.SetEncryptionData(Base64Convert.ToBase64(AesKey), IVBase64);
        RijndaelCryptography.SetBlockSize(128);
        RijndaelCryptography.SetCipherMode('CBC');
        FileBase64 := RijndaelCryptography.Decrypt(Encrypted);

        Base64Convert.FromBase64(FileBase64, PlainOutStream);
    end;

    internal procedure IsEncryptedContent(ContentStart: Text): Boolean
    begin
        exit(CopyStr(ContentStart, 1, 4) = 'AES:');
    end;
}
