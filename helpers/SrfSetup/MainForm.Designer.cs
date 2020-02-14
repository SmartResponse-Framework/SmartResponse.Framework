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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.Btn_SaveCredential = new DarkUI.Controls.DarkButton();
            this.StatusStrip = new DarkUI.Controls.DarkStatusStrip();
            this.StatusStripLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.SectionPanel_ApiToken = new DarkUI.Controls.DarkSectionPanel();
            this.Panel_ApiToken = new System.Windows.Forms.Panel();
            this.TxtBx_Password = new DarkUI.Controls.DarkTextBox();
            this.Title_Password = new DarkUI.Controls.DarkTitle();
            this._labelSpacer = new DarkUI.Controls.DarkLabel();
            this.TxtBx_UserName = new DarkUI.Controls.DarkTextBox();
            this.Title_UserName = new DarkUI.Controls.DarkTitle();
            this.SectionPanel_Preferences = new DarkUI.Controls.DarkSectionPanel();
            this.SectionPanel_ModuleStatus = new DarkUI.Controls.DarkSectionPanel();
            this.Table_ModuleStatus = new System.Windows.Forms.TableLayoutPanel();
            this.Label_Installed = new DarkUI.Controls.DarkLabel();
            this._label_Installed = new DarkUI.Controls.DarkLabel();
            this.Panel_PlatformMgr = new System.Windows.Forms.Panel();
            this.TxtBx_PM = new DarkUI.Controls.DarkTextBox();
            this.Label_PM = new DarkUI.Controls.DarkTitle();
            this.FolderBrowser_SysMonConfigDir = new System.Windows.Forms.FolderBrowserDialog();
            this.Save_TokenDialog = new System.Windows.Forms.SaveFileDialog();
            this.Tip_Token = new System.Windows.Forms.ToolTip(this.components);
            this.darkLabel1 = new DarkUI.Controls.DarkLabel();
            this.darkLabel2 = new DarkUI.Controls.DarkLabel();
            this.StatusStrip.SuspendLayout();
            this.SectionPanel_ApiToken.SuspendLayout();
            this.Panel_ApiToken.SuspendLayout();
            this.SectionPanel_Preferences.SuspendLayout();
            this.SectionPanel_ModuleStatus.SuspendLayout();
            this.Table_ModuleStatus.SuspendLayout();
            this.Panel_PlatformMgr.SuspendLayout();
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
            this.Panel_ApiToken.Controls.Add(this._labelSpacer);
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
            // _labelSpacer
            // 
            this._labelSpacer.Dock = System.Windows.Forms.DockStyle.Top;
            this._labelSpacer.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this._labelSpacer.Location = new System.Drawing.Point(10, 48);
            this._labelSpacer.Name = "_labelSpacer";
            this._labelSpacer.Size = new System.Drawing.Size(158, 10);
            this._labelSpacer.TabIndex = 4;
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
            this.Title_UserName.Text = "Account Name";
            this.Tip_Token.SetToolTip(this.Title_UserName, "Name of the LogRhythm account \r\nassociated with this API Token.");
            // 
            // SectionPanel_Preferences
            // 
            this.SectionPanel_Preferences.Controls.Add(this.SectionPanel_ModuleStatus);
            this.SectionPanel_Preferences.Controls.Add(this.Panel_PlatformMgr);
            this.SectionPanel_Preferences.Dock = System.Windows.Forms.DockStyle.Left;
            this.SectionPanel_Preferences.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.SectionPanel_Preferences.Location = new System.Drawing.Point(180, 0);
            this.SectionPanel_Preferences.Name = "SectionPanel_Preferences";
            this.SectionPanel_Preferences.SectionHeader = "LogRhythm Deployment";
            this.SectionPanel_Preferences.Size = new System.Drawing.Size(200, 370);
            this.SectionPanel_Preferences.TabIndex = 3;
            // 
            // SectionPanel_ModuleStatus
            // 
            this.SectionPanel_ModuleStatus.Controls.Add(this.Table_ModuleStatus);
            this.SectionPanel_ModuleStatus.Dock = System.Windows.Forms.DockStyle.Fill;
            this.SectionPanel_ModuleStatus.Location = new System.Drawing.Point(1, 111);
            this.SectionPanel_ModuleStatus.Name = "SectionPanel_ModuleStatus";
            this.SectionPanel_ModuleStatus.SectionHeader = "Module Status";
            this.SectionPanel_ModuleStatus.Size = new System.Drawing.Size(198, 258);
            this.SectionPanel_ModuleStatus.TabIndex = 5;
            // 
            // Table_ModuleStatus
            // 
            this.Table_ModuleStatus.ColumnCount = 2;
            this.Table_ModuleStatus.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 46.93877F));
            this.Table_ModuleStatus.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 53.06123F));
            this.Table_ModuleStatus.Controls.Add(this.darkLabel2, 1, 1);
            this.Table_ModuleStatus.Controls.Add(this.Label_Installed, 1, 0);
            this.Table_ModuleStatus.Controls.Add(this._label_Installed, 0, 0);
            this.Table_ModuleStatus.Controls.Add(this.darkLabel1, 0, 1);
            this.Table_ModuleStatus.Dock = System.Windows.Forms.DockStyle.Top;
            this.Table_ModuleStatus.Location = new System.Drawing.Point(1, 25);
            this.Table_ModuleStatus.Name = "Table_ModuleStatus";
            this.Table_ModuleStatus.RowCount = 3;
            this.Table_ModuleStatus.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 22F));
            this.Table_ModuleStatus.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 22F));
            this.Table_ModuleStatus.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 67F));
            this.Table_ModuleStatus.Size = new System.Drawing.Size(196, 101);
            this.Table_ModuleStatus.TabIndex = 0;
            this.Table_ModuleStatus.Paint += new System.Windows.Forms.PaintEventHandler(this.Table_ModuleStatus_Paint);
            // 
            // Label_Installed
            // 
            this.Label_Installed.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.Label_Installed.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.Label_Installed.Location = new System.Drawing.Point(94, 6);
            this.Label_Installed.Name = "Label_Installed";
            this.Label_Installed.Padding = new System.Windows.Forms.Padding(10, 0, 0, 0);
            this.Label_Installed.Size = new System.Drawing.Size(99, 16);
            this.Label_Installed.TabIndex = 1;
            this.Label_Installed.Text = "No";
            // 
            // _label_Installed
            // 
            this._label_Installed.Dock = System.Windows.Forms.DockStyle.Bottom;
            this._label_Installed.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this._label_Installed.Location = new System.Drawing.Point(3, 6);
            this._label_Installed.Name = "_label_Installed";
            this._label_Installed.Padding = new System.Windows.Forms.Padding(10, 0, 0, 0);
            this._label_Installed.Size = new System.Drawing.Size(85, 16);
            this._label_Installed.TabIndex = 0;
            this._label_Installed.Text = "Installed";
            // 
            // Panel_PlatformMgr
            // 
            this.Panel_PlatformMgr.Controls.Add(this.TxtBx_PM);
            this.Panel_PlatformMgr.Controls.Add(this.Label_PM);
            this.Panel_PlatformMgr.Dock = System.Windows.Forms.DockStyle.Top;
            this.Panel_PlatformMgr.Location = new System.Drawing.Point(1, 25);
            this.Panel_PlatformMgr.Name = "Panel_PlatformMgr";
            this.Panel_PlatformMgr.Padding = new System.Windows.Forms.Padding(10);
            this.Panel_PlatformMgr.Size = new System.Drawing.Size(198, 86);
            this.Panel_PlatformMgr.TabIndex = 4;
            // 
            // TxtBx_PM
            // 
            this.TxtBx_PM.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(69)))), ((int)(((byte)(73)))), ((int)(((byte)(74)))));
            this.TxtBx_PM.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.TxtBx_PM.Dock = System.Windows.Forms.DockStyle.Top;
            this.TxtBx_PM.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtBx_PM.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.TxtBx_PM.Location = new System.Drawing.Point(10, 28);
            this.TxtBx_PM.Name = "TxtBx_PM";
            this.TxtBx_PM.Size = new System.Drawing.Size(178, 20);
            this.TxtBx_PM.TabIndex = 4;
            // 
            // Label_PM
            // 
            this.Label_PM.Dock = System.Windows.Forms.DockStyle.Top;
            this.Label_PM.Location = new System.Drawing.Point(10, 10);
            this.Label_PM.Margin = new System.Windows.Forms.Padding(3, 0, 3, 12);
            this.Label_PM.Name = "Label_PM";
            this.Label_PM.Size = new System.Drawing.Size(178, 18);
            this.Label_PM.TabIndex = 1;
            this.Label_PM.Text = "Platform Manager Host";
            this.Tip_Token.SetToolTip(this.Label_PM, "Name of the LogRhythm account \r\nassociated with this API Token.");
            // 
            // Tip_Token
            // 
            this.Tip_Token.ToolTipIcon = System.Windows.Forms.ToolTipIcon.Info;
            this.Tip_Token.ToolTipTitle = "Info";
            // 
            // darkLabel1
            // 
            this.darkLabel1.AutoSize = true;
            this.darkLabel1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.darkLabel1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.darkLabel1.Location = new System.Drawing.Point(3, 31);
            this.darkLabel1.Name = "darkLabel1";
            this.darkLabel1.Padding = new System.Windows.Forms.Padding(10, 0, 0, 0);
            this.darkLabel1.Size = new System.Drawing.Size(85, 13);
            this.darkLabel1.TabIndex = 2;
            this.darkLabel1.Text = "Version";
            // 
            // darkLabel2
            // 
            this.darkLabel2.AutoSize = true;
            this.darkLabel2.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.darkLabel2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.darkLabel2.Location = new System.Drawing.Point(94, 31);
            this.darkLabel2.Name = "darkLabel2";
            this.darkLabel2.Padding = new System.Windows.Forms.Padding(10, 0, 0, 0);
            this.darkLabel2.Size = new System.Drawing.Size(99, 13);
            this.darkLabel2.TabIndex = 3;
            this.darkLabel2.Text = "1.2.1";
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
            this.SectionPanel_ModuleStatus.ResumeLayout(false);
            this.Table_ModuleStatus.ResumeLayout(false);
            this.Table_ModuleStatus.PerformLayout();
            this.Panel_PlatformMgr.ResumeLayout(false);
            this.Panel_PlatformMgr.PerformLayout();
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
        private DarkUI.Controls.DarkLabel _labelSpacer;
        private DarkUI.Controls.DarkSectionPanel SectionPanel_Preferences;
        private System.Windows.Forms.FolderBrowserDialog FolderBrowser_SysMonConfigDir;
        private System.Windows.Forms.SaveFileDialog Save_TokenDialog;
        private System.Windows.Forms.ToolTip Tip_Token;
        private System.Windows.Forms.Panel Panel_PlatformMgr;
        private DarkUI.Controls.DarkTitle Label_PM;
        private DarkUI.Controls.DarkTextBox TxtBx_PM;
        private DarkUI.Controls.DarkSectionPanel SectionPanel_ModuleStatus;
        private System.Windows.Forms.TableLayoutPanel Table_ModuleStatus;
        private DarkUI.Controls.DarkLabel Label_Installed;
        private DarkUI.Controls.DarkLabel _label_Installed;
        private DarkUI.Controls.DarkLabel darkLabel1;
        private DarkUI.Controls.DarkLabel darkLabel2;
    }
}

