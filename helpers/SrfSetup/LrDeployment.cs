using System;
using System.Management.Automation;
namespace SrfSetup
{
    public class LrDeployment
    {
        #region [ Properties ]
        public Uri AdminApiBaseUrl { get; set; }
        public Uri CaseApiBaseUrl { get; set; }
        public Uri AieApiUrl { get; set; }
        public string LrApiCredentialPath { get; set; }
        public PSCredential LrApiCredential { get; set; }
        #endregion
    }
}
