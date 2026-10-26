<?php
include_once '/var/www/html/system/autoload.php';
\Aurora\System\Api::Init(true);

$oSettings = \Aurora\System\Api::GetSettings();
if ($oSettings)
{
	$oSettings->SetValue('DBHost', 'db:3306');
	$oSettings->SetValue('DBName', 'afterlogic');
	$oSettings->SetValue('DBLogin', 'afterlogic');
	$oSettings->SetValue('DBPassword', 'docker_Bundle');
	$oSettings->Save();

	\Aurora\System\Api::GetModuleManager()->SyncModulesConfigs();
}