using System;
using System.IO;
using Newtonsoft.Json;

namespace ApiHelper
{
    public class AuthContext
    {
        public string Name { get; }
        public Guid TenantId { get; }
        public int SecretId { get; }
        public Uri OAuth2Uri { get; }
        public Uri ResourceUri { get; }

        public AuthContext(
            string name,
            string tenantId,
            string secretId,
            string oAuth2Uri,
            string resourceUri)
        {
            // Name
            if (!string.IsNullOrEmpty(name))
                Name = name;
            else
                throw new ArgumentException("Invalid AuthContext Name (string)");

            // TenantId
            Guid _t = Guid.Empty;
            if (Guid.TryParse(tenantId, out _t))
                TenantId = _t;
            else
                throw new ArgumentException("Invalid TenantId (Guid)");

            // SecretId
            int _s = 0;
            if (int.TryParse(secretId, out _s))
                SecretId = _s;
            else
                throw new ArgumentException("Invalid SecretId (int)");

            // OAuth2Uri
            string _os = oAuth2Uri.Replace(@"[TenantId]", _t.ToString());
            Uri _o = new Uri("http://chrobinson.com");
            if (Uri.TryCreate(_os, UriKind.Absolute, out _o))
                OAuth2Uri = _o;
            else
                throw new ArgumentException("Invalid OAuth2Uri (Uri)");

            // ResourceUri
            Uri _r = new Uri("http://chrobinson.com");
            if (Uri.TryCreate(resourceUri, UriKind.Absolute, out _r))
                ResourceUri = _r;
            else
                throw new ArgumentException("Invalid ResourceUri (Uri)");
        }


        public static AuthContext FromJson(string json)
        {
            try
            {
                return JsonConvert.DeserializeObject<AuthContext>(json);
            }
            catch (Exception)
            {
                throw;
            }
            
        }
    }
}
