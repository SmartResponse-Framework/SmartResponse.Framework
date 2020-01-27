using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SrfSetup
{
    public class SrfPreferences
    {
        public bool IsSysMonAgent { get; set; }
        public string SysMonConfigDir { get; set; }
        public string SrfLogsDir { get; set; }

        public LrDeployment LrDeployment { get; set; }

        public bool CertPolicyEnabled { get; set; }
        public bool ApiHelperLoaded { get; set; }
    }
}
