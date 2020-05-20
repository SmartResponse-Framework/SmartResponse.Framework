#TODO: Publish-SrfBuild



# Create Directory Structure
    # Create Directory [ModuleName-Release]
    # Create [install] directory
        # Copy: Root\install\Install-LrPs.ps1
        # Copy: Root\install\New-LrPsConfig.ps1
    # Copy Root\install\Install.ps1
    # Copy Root\ModuleInfo
    # Copy BUILDID\ModuleName.zip

    # Zip all of that up as ModuleName-Release.zip

# Output the Build ID (Guid) and path to final zip


#  [LrPs-Release.zip]
# 	+ install\
# 		- Install-LrPs.ps1
# 		- New-LrPsConfig.ps1
# 	- Install.ps1
# 	- ModuleInfo.json
# 	- LrPs.zip