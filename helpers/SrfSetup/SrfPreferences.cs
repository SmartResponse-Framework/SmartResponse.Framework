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



        private bool _isSysMonAgent;
        public bool IsSysMonAgent
        {
            get { return _isSysMonAgent; }
            set
            {
                if (Equals(value, _isSysMonAgent)) return;
                _isSysMonAgent = value;
                OnPropertyChanged();
            }
        }


        private string _sysMonConfigDir;
        public string SysMonConfigDir
        {
            get { return _sysMonConfigDir; }
            set
            {
                if (Equals(value, _sysMonConfigDir)) return;
                _sysMonConfigDir = value;
                OnPropertyChanged();
            }
        }


        private string _srfLogsDir;
        public string SrfLogsDir
        {
            get { return _srfLogsDir; }
            set
            {
                if (Equals(value, _srfLogsDir)) return;
                _srfLogsDir = value;
                OnPropertyChanged();

            }
        }


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