using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace SrfSetup
{
    public class SrfPreferences : INotifyPropertyChanged
    {

        #region [ INotifyPropertyChanged ]
        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
        #endregion


        private LrDeployment _lrDeployment;
        public LrDeployment LrDeployment
        {
            get { return _lrDeployment; }
            set
            {
                if (Equals(value, _lrDeployment)) return;
                _lrDeployment = value;
                OnPropertyChanged();
            }
        }


        private bool _certPolicyEnabled;
        public bool CertPolicyEnabled
        {
            get { return _certPolicyEnabled; }
            set
            {
                if (Equals(value, _certPolicyEnabled)) return;
                _certPolicyEnabled = value;
                OnPropertyChanged();
            }
        }


        private bool _apiHelperLoaded;
        public bool ApiHelperLoaded
        {
            get { return _apiHelperLoaded; }
            set
            {
                if (Equals(value, _apiHelperLoaded)) return;
                _apiHelperLoaded = value;
                OnPropertyChanged();
            }
        }

    }
}