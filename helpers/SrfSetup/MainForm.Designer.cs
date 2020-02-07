namespace SrfSetup
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.Btn_SaveCredential = new DarkUI.Controls.DarkButton();
            this.StatusStrip = new DarkUI.Controls.DarkStatusStrip();
            this.StatusStripLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.SectionPanel_ApiToken = new DarkUI.Controls.DarkSectionPanel();
            this.Panel_ApiToken = new System.Windows.Forms.Panel();
            this.TxtBx_Password = new DarkUI.Controls.DarkTextBox();
            this.Title_Password = new DarkUI.Controls.DarkTitle();
            this.darkLabel1 = new DarkUI.Controls.DarkLabel();
            this.TxtBx_UserName = new DarkUI.Controls.DarkTextBox();
            this.Title_UserName = new DarkUI.Controls.DarkTitle();
            this.SectionPanel_Preferences = new DarkUI.Controls.DarkSectionPanel();
            this.Panel_Preferences_Left = new System.Windows.Forms.Panel();
            this.Panel_Buffer = new System.Windows.Forms.Panel();
            this.Panel_SysMonConfigDir = new System.Windows.Forms.Panel();
            this.TxtBx_SysMonConfigDir = new DarkUI.Controls.DarkTextBox();
            this.Btn_PopFolderBrowser = new System.Windows.Forms.Button();
            this.darkTitle1 = new DarkUI.Controls.DarkTitle();
            this.Check_SysMonHost = new DarkUI.Controls.DarkCheckBox();
            this.FolderBrowser_SysMonConfigDir = new System.Windows.Forms.FolderBrowserDialog();
            this.Save_TokenDialog = new System.Windows.Forms.SaveFileDialog();
            this.StatusStrip.SuspendLayout();
            this.SectionPanel_ApiToken.SuspendLayout();
            this.Panel_ApiToken.SuspendLayout();
            this.SectionPanel_Preferences.SuspendLayout();
            this.Panel_Preferences_Left.SuspendLayout();
            this.Panel_SysMonConfigDir.SuspendLayout();
            this.SuspendLayout();
            // 
            // Btn_SaveCredential
            // 
            this.Btn_SaveCredential.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.Btn_SaveCredential.Location = new System.Drawing.Point(1, 346);
            this.Btn_SaveCredential.Name = "Btn_SaveCredential";
            this.Btn_SaveCredential.Padding = new System.Windows.Forms.Padding(5);
            this.Btn_SaveCredential.Size = new System.Drawing.Size(178, 23);
            this.Btn_SaveCredential.TabIndex = 0;
            this.Btn_SaveCredential.Text = "Save Token";
            this.Btn_SaveCredential.Click += new System.EventHandler(this.Btn_SaveCredential_Click);
            this.Btn_SaveCredential.Leave += new System.EventHandler(this.Btn_SaveCredential_Leave);
            // 
            // StatusStrip
            // 
            this.StatusStrip.AutoSize = false;
            this.StatusStrip.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(60)))), ((int)(((byte)(63)))), ((int)(((byte)(65)))));
            this.StatusStrip.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.StatusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.StatusStripLabel});
            this.StatusStrip.Location = new System.Drawing.Point(0, 370);
            this.StatusStrip.Name = "StatusStrip";
            this.StatusStrip.Padding = new System.Windows.Forms.Padding(0, 5, 0, 3);
            this.StatusStrip.Size = new System.Drawing.Size(696, 24);
            this.StatusStrip.SizingGrip = false;
            this.StatusStrip.TabIndex = 1;
            this.StatusStrip.Text = "Test";
            // 
            // StatusStripLabel
            // 
            this.StatusStripLabel.Font = new System.Drawing.Font("Segoe UI", 8F);
            this.StatusStripLabel.Margin = new System.Windows.Forms.Padding(1, 0, 50, 0);
            this.StatusStripLabel.Name = "StatusStripLabel";
            this.StatusStripLabel.Size = new System.Drawing.Size(38, 16);
            this.StatusStripLabel.Text = "Ready";
            // 
            // SectionPanel_ApiToken
            // 
            this.SectionPanel_ApiToken.Controls.Add(this.Panel_ApiToken);
            this.SectionPanel_ApiToken.Controls.Add(this.Btn_SaveCredential);
            this.SectionPanel_ApiToken.Dock = System.Windows.Forms.DockStyle.Left;
            this.SectionPanel_ApiToken.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.SectionPanel_ApiToken.Location = new System.Drawing.Point(0, 0);
            this.SectionPanel_ApiToken.Name = "SectionPanel_ApiToken";
            this.SectionPanel_ApiToken.SectionHeader = "LogRhythm API Token";
            this.SectionPanel_ApiToken.Size = new System.Drawing.Size(180, 370);
            this.SectionPanel_ApiToken.TabIndex = 2;
            // 
            // Panel_ApiToken
            // 
            this.Panel_ApiToken.Controls.Add(this.TxtBx_Password);
            this.Panel_ApiToken.Controls.Add(this.Title_Password);
            this.Panel_ApiToken.Controls.Add(this.darkLabel1);
            this.Panel_ApiToken.Controls.Add(this.TxtBx_UserName);
            this.Panel_ApiToken.Controls.Add(this.Title_UserName);
            this.Panel_ApiToken.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Panel_ApiToken.Location = new System.Drawing.Point(1, 25);
            this.Panel_ApiToken.Name = "Panel_ApiToken";
            this.Panel_ApiToken.Padding = new System.Windows.Forms.Padding(10);
            this.Panel_ApiToken.Size = new System.Drawing.Size(178, 321);
            this.Panel_ApiToken.TabIndex = 3;
            // 
            // TxtBx_Password
            // 
            this.TxtBx_Password.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(69)))), ((int)(((byte)(73)))), ((int)(((byte)(74)))));
            this.TxtBx_Password.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.TxtBx_Password.Dock = System.Windows.Forms.DockStyle.Top;
            this.TxtBx_Password.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtBx_Password.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.TxtBx_Password.Location = new System.Drawing.Point(10, 76);
            this.TxtBx_Password.Multiline = true;
            this.TxtBx_Password.Name = "TxtBx_Password";
            this.TxtBx_Password.Size = new System.Drawing.Size(158, 179);
            this.TxtBx_Password.TabIndex = 6;
            // 
            // Title_Password
            // 
            this.Title_Password.Dock = System.Windows.Forms.DockStyle.Top;
            this.Title_Password.Location = new System.Drawing.Point(10, 58);
            this.Title_Password.Margin = new System.Windows.Forms.Padding(3, 0, 3, 12);
            this.Title_Password.Name = "Title_Password";
            this.Title_Password.Size = new System.Drawing.Size(158, 18);
            this.Title_Password.TabIndex = 5;
            this.Title_Password.Text = "Token";
            // 
            // darkLabel1
            // 
            this.darkLabel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.darkLabel1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.darkLabel1.Location = new System.Drawing.Point(10, 48);
            this.darkLabel1.Name = "darkLabel1";
            this.darkLabel1.Size = new System.Drawing.Size(158, 10);
            this.darkLabel1.TabIndex = 4;
            // 
            // TxtBx_UserName
            // 
            this.TxtBx_UserName.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(69)))), ((int)(((byte)(73)))), ((int)(((byte)(74)))));
            this.TxtBx_UserName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.TxtBx_UserName.Dock = System.Windows.Forms.DockStyle.Top;
            this.TxtBx_UserName.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtBx_UserName.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.TxtBx_UserName.Location = new System.Drawing.Point(10, 28);
            this.TxtBx_UserName.Name = "TxtBx_UserName";
            this.TxtBx_UserName.Size = new System.Drawing.Size(158, 20);
            this.TxtBx_UserName.TabIndex = 3;
            // 
            // Title_UserName
            // 
            this.Title_UserName.Dock = System.Windows.Forms.DockStyle.Top;
            this.Title_UserName.Location = new System.Drawing.Point(10, 10);
            this.Title_UserName.Margin = new System.Windows.Forms.Padding(3, 0, 3, 12);
            this.Title_UserName.Name = "Title_UserName";
            this.Title_UserName.Size = new System.Drawing.Size(158, 18);
            this.Title_UserName.TabIndex = 0;
            this.Title_UserName.Text = "Label";
            // 
            // SectionPanel_Preferences
            // 
            this.SectionPanel_Preferences.Controls.Add(this.Panel_Preferences_Left);
            this.SectionPanel_Preferences.Dock = System.Windows.Forms.DockStyle.Left;
            this.SectionPanel_Preferences.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.SectionPanel_Preferences.Location = new System.Drawing.Point(180, 0);
            this.SectionPanel_Preferences.Name = "SectionPanel_Preferences";
            this.SectionPanel_Preferences.SectionHeader = "Preferences";
            this.SectionPanel_Preferences.Size = new System.Drawing.Size(269, 370);
            this.SectionPanel_Preferences.TabIndex = 3;
            // 
            // Panel_Preferences_Left
            // 
            this.Panel_Preferences_Left.Controls.Add(this.Panel_Buffer);
            this.Panel_Preferences_Left.Controls.Add(this.Panel_SysMonConfigDir);
            this.Panel_Preferences_Left.Controls.Add(this.Check_SysMonHost);
            this.Panel_Preferences_Left.Dock = System.Windows.Forms.DockStyle.Left;
            this.Panel_Preferences_Left.Location = new System.Drawing.Point(1, 25);
            this.Panel_Preferences_Left.Name = "Panel_Preferences_Left";
            this.Panel_Preferences_Left.Padding = new System.Windows.Forms.Padding(10);
            this.Panel_Preferences_Left.Size = new System.Drawing.Size(267, 344);
            this.Panel_Preferences_Left.TabIndex = 0;
            // 
            // Panel_Buffer
            // 
            this.Panel_Buffer.Dock = System.Windows.Forms.DockStyle.Top;
            this.Panel_Buffer.Location = new System.Drawing.Point(10, 76);
            this.Panel_Buffer.Name = "Panel_Buffer";
            this.Panel_Buffer.Size = new System.Drawing.Size(247, 27);
            this.Panel_Buffer.TabIndex = 2;
            // 
            // Panel_SysMonConfigDir
            // 
            this.Panel_SysMonConfigDir.Controls.Add(this.TxtBx_SysMonConfigDir);
            this.Panel_SysMonConfigDir.Controls.Add(this.Btn_PopFolderBrowser);
            this.Panel_SysMonConfigDir.Controls.Add(this.darkTitle1);
            this.Panel_SysMonConfigDir.Dock = System.Windows.Forms.DockStyle.Top;
            this.Panel_SysMonConfigDir.Location = new System.Drawing.Point(10, 27);
            this.Panel_SysMonConfigDir.Name = "Panel_SysMonConfigDir";
            this.Panel_SysMonConfigDir.Padding = new System.Windows.Forms.Padding(0, 5, 0, 0);
            this.Panel_SysMonConfigDir.Size = new System.Drawing.Size(247, 49);
            this.Panel_SysMonConfigDir.TabIndex = 1;
            // 
            // TxtBx_SysMonConfigDir
            // 
            this.TxtBx_SysMonConfigDir.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(69)))), ((int)(((byte)(73)))), ((int)(((byte)(74)))));
            this.TxtBx_SysMonConfigDir.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.TxtBx_SysMonConfigDir.Dock = System.Windows.Forms.DockStyle.Left;
            this.TxtBx_SysMonConfigDir.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.TxtBx_SysMonConfigDir.Location = new System.Drawing.Point(0, 23);
            this.TxtBx_SysMonConfigDir.Name = "TxtBx_SysMonConfigDir";
            this.TxtBx_SysMonConfigDir.Size = new System.Drawing.Size(211, 22);
            this.TxtBx_SysMonConfigDir.TabIndex = 3;
            this.TxtBx_SysMonConfigDir.Validating += new System.ComponentModel.CancelEventHandler(this.SysMonConfigDir_Validate);
            // 
            // Btn_PopFolderBrowser
            // 
            this.Btn_PopFolderBrowser.Dock = System.Windows.Forms.DockStyle.Right;
            this.Btn_PopFolderBrowser.FlatAppearance.BorderSize = 0;
            this.Btn_PopFolderBrowser.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.Btn_PopFolderBrowser.Image = global::SrfSetup.SrfResources.folder_outline_small;
            this.Btn_PopFolderBrowser.Location = new System.Drawing.Point(217, 23);
            this.Btn_PopFolderBrowser.Name = "Btn_PopFolderBrowser";
            this.Btn_PopFolderBrowser.Size = new System.Drawing.Size(30, 26);
            this.Btn_PopFolderBrowser.TabIndex = 2;
            this.Btn_PopFolderBrowser.UseVisualStyleBackColor = true;
            this.Btn_PopFolderBrowser.Click += new System.EventHandler(this.Btn_PopFolderBrowser_Click);
            // 
            // darkTitle1
            // 
            this.darkTitle1.Dock = System.Windows.Forms.DockStyle.Top;
            this.darkTitle1.Location = new System.Drawing.Point(0, 5);
            this.darkTitle1.Name = "darkTitle1";
            this.darkTitle1.Size = new System.Drawing.Size(247, 18);
            this.darkTitle1.TabIndex = 0;
            this.darkTitle1.Text = "SysMon Config Dir";
            // 
            // Check_SysMonHost
            // 
            this.Check_SysMonHost.Dock = System.Windows.Forms.DockStyle.Top;
            this.Check_SysMonHost.Location = new System.Drawing.Point(10, 10);
            this.Check_SysMonHost.Name = "Check_SysMonHost";
            this.Check_SysMonHost.Size = new System.Drawing.Size(247, 17);
            this.Check_SysMonHost.TabIndex = 0;
            this.Check_SysMonHost.Text = "Configure as SysMon Host";
            this.Check_SysMonHost.CheckedChanged += new System.EventHandler(this.Check_SysMonHost_CheckedChanged);
            this.Check_SysMonHost.Leave += new System.EventHandler(this.Check_SysMonHost_Leave);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(696, 394);
            this.Controls.Add(this.SectionPanel_Preferences);
            this.Controls.Add(this.SectionPanel_ApiToken);
            this.Controls.Add(this.StatusStrip);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "MainForm";
            this.Text = "SmartResponse.Framework [Setup]";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.StatusStrip.ResumeLayout(false);
            this.StatusStrip.PerformLayout();
            this.SectionPanel_ApiToken.ResumeLayout(false);
            this.Panel_ApiToken.ResumeLayout(false);
            this.Panel_ApiToken.PerformLayout();
            this.SectionPanel_Preferences.ResumeLayout(false);
            this.Panel_Preferences_Left.ResumeLayout(false);
            this.Panel_SysMonConfigDir.ResumeLayout(false);
            this.Panel_SysMonConfigDir.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private DarkUI.Controls.DarkButton Btn_SaveCredential;
        private DarkUI.Controls.DarkStatusStrip StatusStrip;
        private System.Windows.Forms.ToolStripStatusLabel StatusStripLabel;
        private DarkUI.Controls.DarkSectionPanel SectionPanel_ApiToken;
        private System.Windows.Forms.Panel Panel_ApiToken;
        private DarkUI.Controls.DarkTitle Title_UserName;
        private DarkUI.Controls.DarkTextBox TxtBx_UserName;
        private DarkUI.Controls.DarkTextBox TxtBx_Password;
        private DarkUI.Controls.DarkTitle Title_Password;
        private DarkUI.Controls.DarkLabel darkLabel1;
        private DarkUI.Controls.DarkSectionPanel SectionPanel_Preferences;
        private System.Windows.Forms.Panel Panel_Preferences_Left;
        private DarkUI.Controls.DarkCheckBox Check_SysMonHost;
        private System.Windows.Forms.FolderBrowserDialog FolderBrowser_SysMonConfigDir;
        private System.Windows.Forms.Button Btn_PopFolderBrowser;
        private DarkUI.Controls.DarkTextBox TxtBx_SysMonConfigDir;
        private System.Windows.Forms.Panel Panel_SysMonConfigDir;
        private DarkUI.Controls.DarkTitle darkTitle1;
        private System.Windows.Forms.Panel Panel_Buffer;
        private System.Windows.Forms.SaveFileDialog Save_TokenDialog;
    }
}

