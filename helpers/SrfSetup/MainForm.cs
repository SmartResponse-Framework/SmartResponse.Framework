using DarkUI.Forms;
using System;
using System.IO;
using System.Windows.Forms;
using System.Drawing;
using System.Management.Automation;

// using NipponAdvisor.DarkUIExt;

namespace SrfSetup
{
    public partial class MainForm : DarkForm
    {
        #region [ Properties ]
        protected PreferencesManager PrefManager { get; set; }
        private bool _dirty { get; set; }
        #endregion



        #region [ Constructor ]
        public MainForm()
        {
            InitializeComponent();
        }
        #endregion



        #region [ Load ]
        private void MainForm_Load(object sender, EventArgs e)
        {
            PrefManager = new PreferencesManager();
            PrefManager.Load();

            //// DataBindings
            //Check_SysMonHost.DataBindings.Add(
            //    "Checked", 
            //    PrefManager.Preferences, 
            //    "IsSysMonAgent",
            //    false,
            //    DataSourceUpdateMode.OnPropertyChanged
            //);
            //TxtBx_SysMonConfigDir.DataBindings.Add("Text", PrefManager.Preferences, "SysMonConfigDir");
            //// Specific element properties
            //TxtBx_SysMonConfigDir.Text = @"C:\Program Files\LogRhythm\System Monitor Agent\config\";
        }
        #endregion



        #region [ Button: Save Token ]
        private void Btn_SaveCredential_Click(object sender, EventArgs e)
        {
            // Validate Username / Password aren't empty.
            if (string.IsNullOrEmpty(TxtBx_Password.Text) ||
                string.IsNullOrEmpty(TxtBx_UserName.Text))
            {
                StatusStripLabel.Text = "Please enter a username and password";
                StatusStripLabel.ForeColor = Color.Red;
                return;
            }


            // Create a PSCredential from Token Label / API Token fields
            PSCredential cred = CredentialHelper.MakeCredential(
                TxtBx_UserName.Text,
                TxtBx_Password.Text
            );


            // Pop a save location
            Save_TokenDialog.FileName = "LrApiToken.xml";
            if (Save_TokenDialog.ShowDialog() == DialogResult.OK)
            {
                string path = Path.GetFullPath(Save_TokenDialog.FileName);
                // Set the path variable in SrfPreferences
                PrefManager.Preferences.LrDeployment.LrApiCredentialPath = path;
                if (Directory.Exists(Path.GetDirectoryName(path)))
                {
                    // Save to valid destination
                    CredentialHelper.ExportCliXml(cred, path);
                }
            }
        }

        private void Btn_SaveCredential_Leave(object sender, EventArgs e)
        {
            ResetStatusLabel();
        }
        #endregion



        private void ResetStatusLabel()
        {
            StatusStripLabel.Text = "Ready";
            StatusStripLabel.ForeColor = Color.FromArgb(220, 220, 220);
        }

        private void Table_ModuleStatus_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}