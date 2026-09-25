using System.Web;

namespace davesbcsftp;

public class Security
{

    /// <summary>
    /// Returns true if <paramref name="path"/> contains a directory traversal attempt in any plain-string or URL encoded form. 
    /// Callers should reject the request if directory traversal attempts are present as it could be from malicious actors. 
    /// </summary>
    public static bool DirectoryTraversalIsPresent(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
            return false;

        //Collapse urlencoded paths to the normal form and normalise \ into /
        string decoded = DecodeFully(path);
        string normalised = decoded.Replace('\\', '/');

        //Apparently a null byte is a truncation trick. Treat as hostile. 
        if (normalised.IndexOf('\0') >= 0)
            return true; 

        foreach(var segment in normalised.Split('/'))
        {
            if (segment == "..")
                return true;
        }

        //all good
        return false;
    } 

    private static string DecodeFully(string value)
    {
        //infinite loop protection
        const int maxPasses = 99;
        string current = value;

        for (int pass = 0; pass < maxPasses; pass++)
        {
            string next = HttpUtility.UrlDecode(current);
            if (string.Equals(next, current, StringComparison.Ordinal))
                break;

            current = next;
        }

        return current;
    }
}