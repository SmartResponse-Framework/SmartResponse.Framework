using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security;
using System.Text;
using System.Threading.Tasks;

namespace SrfSetup
{
    public static class CredentialHelper
    {
        public static void ExportCliXml(PSCredential credential, string path)
        {
            using (Runspace runspace = RunspaceFactory.CreateRunspace())
            {
                runspace.Open();
                using (Pipeline pipeline = runspace.CreatePipeline())
                {
                    Command cmdExportCliXml = new Command("Export-CliXml");
                    cmdExportCliXml.Parameters.Add(new CommandParameter("InputObject", credential));
                    cmdExportCliXml.Parameters.Add(new CommandParameter("Path", path));
                    pipeline.Commands.Add(cmdExportCliXml);
                    Collection<PSObject> results = pipeline.Invoke();
                }
                runspace.Close();
            }
        }



        public static PSCredential MakeCredential(string username, string password)
        {
            // The maximum length of a SecureString instance is 65,536 characters.
            var _securePass = new SecureString();
            foreach (char c in password.ToCharArray())
            {
                _securePass.AppendChar(c);
            }
            return new PSCredential(username, _securePass);
        }
    }
}
