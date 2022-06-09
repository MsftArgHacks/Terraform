#Bloke1
#Creacion usuarios
$password = "Hackthoninv04"  # No tocar
az ad user create --display-name 'User1' --user-principal-name user1@mshackarginvt04outlook.onmicrosoft.com --password $password --force-change-password-next-login false
az ad user create --display-name 'User2' --user-principal-name user2@mshackarginvt04outlook.onmicrosoft.com --password $password --force-change-password-next-login false
az ad user create --display-name 'User3' --user-principal-name user3@mshackarginvt04outlook.onmicrosoft.com --password $password --force-change-password-next-login false
az ad user create --display-name 'User4' --user-principal-name user4@mshackarginvt04outlook.onmicrosoft.com --password $password --force-change-password-next-login false
az ad user create --display-name 'User5' --user-principal-name user5@mshackarginvt04outlook.onmicrosoft.com --password $password --force-change-password-next-login false
az ad user create --display-name 'User6' --user-principal-name user5@mshackarginvt04outlook.onmicrosoft.com --password $password --force-change-password-next-login false


#creacion Grupo

az ad group create --display-name 'DevOpsTeam' --mail-nickname DevOpsTeam

#Bloke2
#ADD usuarios a grupos

$useroid="$(az ad user list --display-name 'User2' --query [].[objectId] --output tsv)"

az ad group member add --group 'DevOpsTeam' --member-id $useroid

$useroid="$(az ad user list --display-name 'User3' --query [].[objectId] --output tsv)"

az ad group member add --group 'DevOpsTeam' --member-id $useroid

$useroid="$(az ad user list --display-name 'User4' --query [].[objectId] --output tsv)"

az ad group member add --group 'DevOpsTeam' --member-id $useroid

$useroid="$(az ad user list --display-name 'User5' --query [].[objectId] --output tsv)"

az ad group member add --group 'DevOpsTeam' --member-id $useroid

$useroid="$(az ad user list --display-name 'User6' --query [].[objectId] --output tsv)"

az ad group member add --group 'DevOpsTeam' --member-id $useroid




#Bloke3
#Asignacion role owner to the group
$subIdtemp= Get-AzSubscription
$SubID = $subIdtemp.Id
$groupoid="$(az ad group list --display-name 'DevOpsTeam' --query [].[objectId] --output tsv)"
az role assignment create --assignee-object-id $groupoid --role 'Owner'


#Bloke4
#creación ADO
# create a resource group
$pjname = "team04" # CAMBIAR
$orgname = "mshackarginvt04" # # CAMBIAR mshackarginvteam01
$resourceGroup ="ADO"
$location = "Brazil South"
az group create -l $location -n $resourceGroup
# the template we will deploy
$templateUri="ask to Walter"
# deploy, specifying all template parameters directly

az group deployment create --name TestDeployment --resource-group $resourceGroup --template-uri $templateUri -



# Agregar el grupo al ADO
# User1;User2;User3;User4;User5;User6;User7;User8;User9;User10