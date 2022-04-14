# terraform-container-apps
Azure container apps terraformed

devcontainer has terraform installed, just start codespace and enjoy.

You need to execute this on your azure subscription prior to using container apps:

`az provider register --namespace Microsoft.App`


Interesting part is in terraform/capps.tf file

Todo:
 - Container apps needs to be added to the namep provider