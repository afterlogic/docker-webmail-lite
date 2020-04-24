<?php 
include_once '/var/www/html/system/autoload.php';
\Aurora\System\Api::Init(true);

$oSettings = \Aurora\System\Api::GetSettings();
if ($oSettings)
{
	$oSettings->SetConf('DBHost', 'localhost');
	$oSettings->SetConf('DBName', 'afterlogic');
	$oSettings->SetConf('DBLogin', 'rootuser');
	$oSettings->SetConf('DBPassword', 'dockerbundle');
	$result = $oSettings->Save();
	
	\Aurora\System\Api::GetModuleDecorator('Core')->CreateTables();
	\Aurora\System\Api::GetModuleManager()->SyncModulesConfigs();
}