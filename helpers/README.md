# Helpers

The Helpers directory contains .NET solutions created for use in SmartResponse.Framework where a dll makes more sense than a script.

This can be particularly useful for custom types (objects) that will be used by many parts of the module - this makes the structure of the object more reliable and can include serialization, validation, or other self-contained features that are easier to maintain in a library than in a script.

The only solution in use currently is ApiHelper.

## Helper Solutions

**ApiHelper**: Contains functionality for interacting with API / Web Services.  This is a fairly trivial .dll and was initially a way for me to test using custom dll's in PowerShell.  This can be replaced with a PowerShell method easily enough.
