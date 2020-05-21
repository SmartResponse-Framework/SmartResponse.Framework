#TODO: Publish-SrfBuild



# Create Directory Structure
    # Create Directory [ModuleName-Release]
    # Create [install] directory
        # Copy: Root\install\Install-Lrt.ps1
        # Copy: Root\install\New-LrtConfig.ps1
    # Copy Root\install\Install.ps1
    # Copy Root\ModuleInfo
    # Copy BUILDID\ModuleName.zip

    # Zip all of that up as ModuleName-Release.zip

# Output the Build ID (Guid) and path to final zip


#  [Lrt-Release.zip]
# 	+ install\
# 		- Install-Lrt.ps1
# 		- New-LrtConfig.ps1
# 	- Install.ps1
# 	- ModuleInfo.json
# 	- Lrt.zip