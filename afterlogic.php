<?php
include_once '/var/www/html/system/autoload.php';
\Aurora\System\Api::Init(true);

$oSettings = \Aurora\System\Api::GetSettings();
if ($oSettings)
{
	$oSettings->SetConf('DBHost', 'db:3306');
	$oSettings->SetConf('DBName', 'afterlogic');
	$oSettings->SetConf('DBLogin', 'afterlogic');
	$oSettings->SetConf('DBPassword', 'docker_Bundle');
	$oSettings->Save();

	\Aurora\System\Api::GetModuleManager()->SyncModulesConfigs();
}