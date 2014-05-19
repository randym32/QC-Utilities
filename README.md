Quartz Composer Utilities
=========================

This is a set of tools for Quartz Composer.



Installation
------------

1. Remove the old plugin from ~/Library/Graphics/Quartz Composer Plug-Ins
2. Copy the new plugin into ~/Library/Graphics/Quartz Composer Plug-Ins


Lessons that I have learned
---------------------------

1. A patch can't have an output called "output"
2. A patch can't have an input called "input"
3. Neither an input nor an output can be of types NSObject
4. When catching exceptions: NSLogUncaughtSystemExceptionMask catches when the framework  synthesizes a field.
  For example, when Quartz Composer environment synthesizes inputs/outputs.  So this exception mask shouldn't be employed
5. If you provide a structure to an input (which doesn't have a type declare, or is declared a string) Quartz Composer converts it to a string.  No way for virtual or generic types at this time.
6. Fetching any of the outputs (eg from within 'execute:atTime:withArguments:') seems to be a bad idea; it works better if they are only stored
7. Don't set any outputs in 'startExecution:' or in 'stopExecution:'
8. If using Grand Central Dispatch (eg dispatch_async) *do not use 'dispatch_get_main_queue()'*.  Quartz Composer will stop responding -- with a spinning beach ball -- if that background task block takes any time to execute.  Use 'dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)' instead
8. 'executionTimeForContext:atTime:withArguments:' is called very frequently, no matter what it returned last



Requirements
---------------
The plugin was created using the Xcode editor running under Mac OS X 10.8.x or later. 

Patches
========


* *Exception (Unhandled) Reporter*: Captures errant UNIX signals and unhandled framework exceptions.
* *Hex To Color*: Converts a hex string to a color.
* *Host Reachability*: Checks to see if a host is reachable.
* *Is String Bound*: Checks to see if a string is null or empty
* *Is Structure Bound*: Checks to see if a structure is null or empty
* *JSON Convert*: Convert a string form of a JSON file to a structure
* *Merge Structure*: Merges two structures
* *Network Reachability*: Checks to see if the local network is reachable
* *String Import*: Imports a structure from a JSON formatted file
* *URL Parser*: Parse a URL into its parts
* *WiFi Reachability*: Checks to see if the local WiFi network is reachable

|What|Patches|
|-:|-|
|**Devices, Hardware**|Network Reachability|
|**Error Management**|Exception (Unhandled) Reporter, Host Reachability, Network Reachability, URL Parser|
|**Network**   |String Import, URL Parser|
|**Strings**   |Hex To Color, Is String Bound, String Import|
|**Structures**|Is Structure Bound, Merge Structure, URL Structure|


Exception (Unhandled) Reporter
------------------------------

Captures errant UNIX signals and unhandled framework exceptions.

|           | Name  | Type | Description |
|----------:|-------|------|-------------|
|**Inputs** | _None_|      |             |
|**Outputs**| error | array| An array of exceptions; the most recent first |

Each exception is a structure.  Each structure has the following fields:

| Field   | Description    |
|---------|----------------|
| name    | The name of the exception as provided by Objective-C     |
| reason  | The reason for the exception, as provided by Objective-C |
|callStack| The traceback / call stack of where the exception occurred; does not include line numbers at this time|
| userInfo| Another structure, provided by Objective-C               |



Hex To Color
------------

Converts a hex string to a color.

|           | Name          | Type   | Description |
|----------:|---------------|--------|-------------|
|**Inputs** | hex RGB       | string | The RGB hex code for the color                                                 |
|           | default Color | color  | The color to employ if "hex RGB" is empty or can't be converted to a hex color |
|**Outputs**| color         | color  | The color, from _hex RGB_ if possible, from _default Color_ if neccessary      |


Host Reachability
------------------
Checks to see if a host is reachable.  See also *Network Reachability*.

|           | Name                  | Type   | Description |
|----------:|-----------------------|--------|-------------|
|**Inputs** | Host name or IPAddress| string | The host name or IP address of the machine we will are interested in contacting.|
|**Outputs**| connection required   | boolean| True if the network will be need to enabled.  |
|           | reachable             | boolean| True if the host is reachable.                |
|           | reachable via WWAN    | boolean| True if on an iPhone and can reach using cellular data services. |


Is String Bound
---------------

Checks to see if a string is null or empty.

|           | Name          | Type   | Description |
|----------:|---------------|--------|-------------|
|**Inputs** | input         | string | The input string                                     |
|**Outputs**| is free       | boolean| True if the string is null or empty; false otherwise |
|           | is bound      | boolean| False if the string is null or empty; true otherwise |



Is Structure Bound
------------------

Checks to see if a structure is null or empty.

|           | Name          | Type      | Description |
|----------:|---------------|-----------|-------------|
|**Inputs** | input         | structure | The input structure                                     |
|**Outputs**| is free       | boolean   | True if the structure is null or empty; false otherwise |
|           | is bound      | boolean   | False if the structure is null or empty; true otherwise |


JSON Converter
--------------

Converts a JSON formated text string into  a structure.

|           | Name            | Type      | Description |
|----------:|-----------------|-----------|-------------|
|**Inputs** | JSON data       | string    | The JSON formatted text string                                 |
|**Outputs**| output          | structure | The structure specified in the JSON file (empty on error)      |
|           | error           | structure | An array of [error structures][e] (see below) with the most underlying one first |
|           | ready           | boolean   | True if the structure is loaded and was read without error; false otherwise |

1. The data is interpreted as a JSON formatted text.  If this produced an error, it is set in _error_
2. Otherwise _output_ is set with the JSON structure and _ready_ is set to true.

The JSON conversion is done in the background, using a Grand Central Dispatch Queue.
Quartz Composer does other things while the data is converted.  To let QC know that the loading is done, the patch uses a
timebase to tell QC to periodically poll us, and get the results from the background thread.  The interval is also
shortened if the input to the patch changes.


Network Reachability
--------------------
Checks to see if a network is reachable.  See also *Host Reachability*, *WiFi Reachability*

|           | Name                  | Type   | Description |
|----------:|-----------------------|--------|-------------|
|**Inputs** | *none*                |        |             |
|**Outputs**| connection required   | boolean| True if the network will be need to enabled.  |
|           | reachable             | boolean| True if the host is reachable.                |
|           | reachable via WWAN    | boolean| True if on an iPhone and can reach using cellular data services. |



String Importer
---------------

Imports a structure from a JSON formated file

|           | Name            | Type      | Description |
|----------:|-----------------|-----------|-------------|
|**Inputs** |File path or URL for string| string    | The local file path for the file or the remote URL for the file|
|**Outputs**| string          | string    | The text file specified by the path or URL                                  |
|           | error           | structure | An array of error structures (see below) with the most underlying one first |
|           | ready           | boolean   | True if the structure is loaded and was read without error; false otherwise |



The operations:

1. It first assumes that it was given a file path and tries to load from that
2. If that doesn't work, it assumes that it was given an URL and tries to load from that.
3. If neither work, the error structure is populated
4. Otherwise, the output _string_ is set and _ready_ is set to true


The loading of the string is done in the background, using a Grand Central Dispatch Queue.
Quartz Composer does other things while the data loads.  To let QC know that the loading is done, the patch uses a
timebase to tell QC to periodically poll us, and get the results from the background thread.  The interval is also
shortened if the input to the patch changes.


URL Parser
----------
Parse a URL into its parts

|           | Name            | Type      | Description |
|----------:|-----------------|-----------|-------------|
|**Inputs** |File path or URL | string    | The local file path for the file or the remote URL for the file|
|**Outputs**| output          | structure | The pieces of the URL (described below)      |
|           | error           | structure | An error structures (see below) if is a file but can't be accessed. |
|           | is file         | boolean   | True if the URL specifies a local file; false otherwise |
|           | standardized URL| string    | The URL in a standardized format. |


The structure of the URL includes:

| Field                     | Description                 |
|---------------------------|-----------------------------|
| absolute                  |                             |
| absolute URL              |                             |
| base                      |                             |
| fragment                  |                             |
| host                      |                             |
| parameters                |                             |
| password                  |                             |
| path                      |                             |
| port                      |                             |
| query                     |                             |
| relative                  | The relative portion of a URL.  If 'base' is nil this is the same as absolute|
| relativePath              | The same as path if base is nil|
| resourceSpecifier         |                             |
| scheme                    |                             |
| user                      |                             |



WiFi Reachability
--------------------
Checks to see if a network is reachable.  See also *Host Reachability*, *Network Reachability*

|           | Name                  | Type   | Description |
|----------:|-----------------------|--------|-------------|
|**Inputs** | *none*                |        |             |
|**Outputs**| connection required   | boolean| True if the network will be need to enabled.  |
|           | reachable             | boolean| True if the host is reachable.                |
|           | reachable via WWAN    | boolean| True if on an iPhone and can reach using cellular data services. |




Error Structure
---------------

The error structure may include the following fields (text borrowed from Apple Documentation):

| Field                     | Description                 |
|---------------------------|-----------------------------|
|localizedDescription       |The primary user-presentable message for the error. In the absence of a custom error string, the manufactured one might not be suitable for presentation to the user, but can be used in logs or debugging.|
|localizedFailureReason     |A complete sentence which describes why the operation failed. In many cases this will be just the "because" part of the error message (but as a complete sentence, which makes localization easier).|
|localizedRecoverySuggestion|The string that can be displayed as the "informative" (aka "secondary") message.|
|localizedRecoveryOptions   |Titles of buttons that are appropriate for displaying in an alert. These should match the string provided as a part of localizedRecoverySuggestion.  The first string would be the title of the default option, the second one the next option, and so on.|
| recoveryAttempter         | An object that conforms to the NSErrorRecoveryAttempting informal protocol.|
|     helpAnchor            |The help anchor that can be used to create a help button to accompany the error when it's displayed to the user.|


Note: This patch does not give a download progress indicator.  There are other JSON importers that do; this was
kept simple.


