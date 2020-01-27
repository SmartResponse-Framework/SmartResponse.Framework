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

// using NipponAdvisor.DarkUIExt;

namespace SrfSetup
{
    public partial class MainForm : DarkForm
    {
        #region [ Properties ]
        protected PreferencesManager PrefManager { get; set; }
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
        }
        #endregion

        private void Btn_SaveCredential_Click(object sender, EventArgs e)
        {
            // PrefManager.Save();
        }

        private void Btn_PopFolderBrowser_Click(object sender, EventArgs e)
        {
            if (FolderBrowser_SysMonConfigDir.ShowDialog() == DialogResult.OK)
            {
                TxtBx_SysMonConfigDir.Text = FolderBrowser_SysMonConfigDir.SelectedPath;
            }

        }

        private void Check_SysMonHost_CheckedChanged(object sender, EventArgs e)
        {
            if (Check_SysMonHost.Checked)
            {
                TxtBx_SysMonConfigDir.Enabled = true;
                Btn_PopFolderBrowser.Enabled = true;
                StatusStripLabel.Text = "SysMon Host Enabled";
                return;
            }
            TxtBx_SysMonConfigDir.Enabled = false;
            Btn_PopFolderBrowser.Enabled = false;
            StatusStripLabel.Text = "SysMon Host Disabled";
        }

        private void SysMonConfigDir_Validate(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (! Directory.Exists(TxtBx_SysMonConfigDir.Text))
            {
                StatusStripLabel.Text = "Directory does not exist.";
                StatusStripLabel.ForeColor = Color.Red;
                TxtBx_SysMonConfigDir.Focus();
                TxtBx_SysMonConfigDir.SelectAll();
                return;
            }
            StatusStripLabel.Text = "Ready";
            StatusStripLabel.ForeColor = Color.FromArgb(220, 220, 220);
        }
    }
}