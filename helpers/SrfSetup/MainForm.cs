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

        #endregion



        #region [ Constructor ]
        public MainForm()
        {
            InitializeComponent();
        }
        #endregion




        private void MainForm_Load(object sender, EventArgs e)
        {
            //get the full location of the assembly with DaoTests in it
            LoadSrfPreferences();
            
            //get the folder that's in
            //FileInfo f = new FileInfo(_path);
            //Debug.Write($"Path: {_path}");
        }


        private void LoadSrfPreferences()
        {
            // Movie movie1 = JsonConvert.DeserializeObject<Movie>(File.ReadAllText(@"c:\movie.json"));
            FileInfo exePath = new FileInfo(Assembly.GetExecutingAssembly().Location);

            string _srfPreferencesPath = Path.Combine(exePath.Directory.FullName, SrfResources.SrfPreferencesPath);
            if (! File.Exists(_srfPreferencesPath)) 
            {
                throw new FileNotFoundException($"Unable to load SrfPreferences.json file. Path: {_srfPreferencesPath}");
            }
            // deserialize JSON directly from a file
            using (StreamReader file = File.OpenText(_srfPreferencesPath))
            {
                JsonSerializer serializer = new JsonSerializer();
                LrDeployment deployment = (LrDeployment)serializer.Deserialize(file, typeof(LrDeployment));
            }
        }
    }
}
