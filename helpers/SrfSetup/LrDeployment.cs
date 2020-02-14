using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;


namespace SrfSetup
{
    public class LrDeployment : INotifyPropertyChanged
    {
        #region [ INotifyPropertyChanged ]
        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
        #endregion


        #region [ Properties ]

        private Uri _adminApiBaseUrl;
        public Uri AdminApiBaseUrl
        {
            get { return _adminApiBaseUrl; }
            set
            {
                if (Equals(value, _adminApiBaseUrl)) return;
                _adminApiBaseUrl = value;
                OnPropertyChanged();
            }
        }


        private Uri _caseApiBaseUrl;
        public Uri CaseApiBaseUrl
        {
            get { return _caseApiBaseUrl; }
            set
            {
                if (Equals(value, _caseApiBaseUrl)) return;
                _caseApiBaseUrl = value;
                OnPropertyChanged();
            }
        }


        private Uri _aieApiUrl;
        public Uri AieApiUrl
        {
            get { return _aieApiUrl; }
            set
            {
                if (Equals(value, _aieApiUrl)) return;
                _aieApiUrl = value;
                OnPropertyChanged();
            }
        }


        private string _lrApiCredentialPath;
        public string LrApiCredentialPath
        {
            get { return _lrApiCredentialPath; }
            set
            {
                if (Equals(value, _lrApiCredentialPath)) return;
                _lrApiCredentialPath = value;
                OnPropertyChanged();
            }
        }


        // Note: Property not used in the context of this
        // application.  This should always be blank until
        // the PS module has loaded.
        private string _lrApiCredential;
        public string LrApiCredential
        {
            get { return _lrApiCredential; }
            set
            {
                if (Equals(value, _lrApiCredential)) return;
                _lrApiCredential = value;
                OnPropertyChanged();
            }
        }

        #endregion
    }
}
