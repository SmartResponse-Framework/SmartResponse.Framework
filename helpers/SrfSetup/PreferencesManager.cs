using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace SrfSetup
{
    public class PreferencesManager
    {
        #region [ Properties ]
        public SrfPreferences Preferences { get; set; }
        public string Path_SrfPreferences { get; private set; }
        #endregion


        #region [ Constructor ]
        public PreferencesManager()
        {
            // Assembly should always be in the SmartResponse.Framework project root.
            string _cwd = (new FileInfo(Assembly.GetExecutingAssembly().Location)).Directory.FullName;

            // The path to SrfPreferences.json is .\src\Includes\SrfPreferences.json
            // The sub-path can be set in resx file, in case it changes.
            Path_SrfPreferences = Path.Combine(_cwd, SrfResources.SrfPreferencesPath);
        }
        #endregion



        #region [ Load / Save ]
        public void Load()
        {
            // Validate SrfPreferences.json exists
            if (!File.Exists(Path_SrfPreferences))
            {
                throw new FileNotFoundException
                    ($"Unable to load SrfPreferences.json file. Path: {Path_SrfPreferences}");
            }

            // Deserialize
            using (StreamReader file = File.OpenText(Path_SrfPreferences))
            {
                JsonSerializer serializer = new JsonSerializer();
                Preferences = (SrfPreferences)serializer.Deserialize(file, typeof(SrfPreferences));
            }
        }


        public void Save()
        {
            // These are run-time preferences, and should be written as false, always.
            Preferences.CertPolicyEnabled = false;
            Preferences.ApiHelperLoaded = false;
            // LrApiCredential is for cached / loaded credentials only.
            Preferences.LrDeployment.LrApiCredential = "";

            if (IsValid())
            {
                string _json = JsonConvert.SerializeObject(Preferences, Formatting.Indented);
                File.WriteAllText(Path_SrfPreferences, _json);
            }
        }
        #endregion


        #region [ Validate Preferences ]
        private bool IsValid()
        {
            bool _isValid = true;

            //TODO: This is a placeholder - need more elegant solution.
            if (! ValidUrl(Preferences.LrDeployment.AdminApiBaseUrl.ToString()))
            {
                _isValid = false;
            }
            if (!ValidUrl(Preferences.LrDeployment.CaseApiBaseUrl.ToString()))
            {
                _isValid = false;
            }
            if (!ValidUrl(Preferences.LrDeployment.AieApiUrl.ToString()))
            {
                _isValid = false;
            }

            // if LrApiCredentialPath is not null, validate path exists
            if (! string.IsNullOrEmpty(Preferences.LrDeployment.LrApiCredentialPath))
            {
                if (! File.Exists(Preferences.LrDeployment.LrApiCredentialPath))
                {
                    _isValid = false;
                }
            }

            return _isValid;
        }


        /// <summary>
        /// Validate that Uri is an absolute http/s URL.
        /// </summary>
        /// <param name="url">Url to validate</param>
        /// <returns></returns>
        private bool ValidUrl(string url)
        {
            if (Uri.TryCreate(url, UriKind.Absolute, out Uri validatedUri))
            {
                //If true: validatedUri contains a valid Uri. Check for the scheme in addition.
                return (validatedUri.Scheme == Uri.UriSchemeHttp || validatedUri.Scheme == Uri.UriSchemeHttps);
            }
            return false;
        }
        #endregion
    }
}
