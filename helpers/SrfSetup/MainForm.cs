using DarkUI.Docking;
using DarkUI.Forms;
using DarkUI.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
// using NipponAdvisor.Forms.Docks;
using System.Drawing;
using System.Diagnostics;
using Newtonsoft.Json;
using System.Reflection;
using System.Security;
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

            // DataBindings
            Check_SysMonHost.DataBindings.Add(
                "Checked", 
                PrefManager.Preferences, 
                "IsSysMonAgent",
                false,
                DataSourceUpdateMode.OnPropertyChanged
            );
            TxtBx_SysMonConfigDir.DataBindings.Add("Text", PrefManager.Preferences, "SysMonConfigDir");
            // Specific element properties
            TxtBx_SysMonConfigDir.Text = @"C:\Program Files\LogRhythm\System Monitor Agent\config\";
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



        #region [ SysMon Host Settings ]
        private void Btn_PopFolderBrowser_Click(object sender, EventArgs e)
        {
            if (FolderBrowser_SysMonConfigDir.ShowDialog() == DialogResult.OK)
            {
                TxtBx_SysMonConfigDir.Text = FolderBrowser_SysMonConfigDir.SelectedPath;
            }

        }

        private void Check_SysMonHost_CheckedChanged(object sender, EventArgs e)
        {
            // Start with a Status Label reset
            ResetStatusLabel();

            if (Check_SysMonHost.Checked)
            {
                // Enable Folder Selection
                TxtBx_SysMonConfigDir.Enabled = true;
                Btn_PopFolderBrowser.Enabled = true;

                // Status Label
                StatusStripLabel.ForeColor = Color.Green;
                StatusStripLabel.Text = "SysMon Host Enabled";

                // Only set a default folder the first time / or if blank
                if (! _dirty || string.IsNullOrEmpty(TxtBx_SysMonConfigDir.Text))
                {
                    TxtBx_SysMonConfigDir.Text = @"C:\Program Files\LogRhythm\System Monitor Agent\config";
                }
                return;
            }

            TxtBx_SysMonConfigDir.Enabled = false;
            Btn_PopFolderBrowser.Enabled = false;
            StatusStripLabel.Text = "SysMon Host Disabled";

        }

        private void SysMonConfigDir_Validate(object sender, System.ComponentModel.CancelEventArgs e)
        {
            //TODO: Bug - Status message incorrectly displays "Directory does not exist"
            // at the wrong time (as soon as mouse goes down) may need to switch to a
            // different validation method.
            _dirty = true;
            if (! Directory.Exists(TxtBx_SysMonConfigDir.Text))
            {
                StatusStripLabel.Text = "Directory does not exist.";
                StatusStripLabel.ForeColor = Color.Red;
                TxtBx_SysMonConfigDir.Focus();
                TxtBx_SysMonConfigDir.SelectAll();
                return;
            }
            ResetStatusLabel();
        }


        private void Check_SysMonHost_Leave(object sender, EventArgs e)
        {
            ResetStatusLabel();
        }
        #endregion




        private void ResetStatusLabel()
        {
            StatusStripLabel.Text = "Ready";
            StatusStripLabel.ForeColor = Color.FromArgb(220, 220, 220);
        }


    }
}