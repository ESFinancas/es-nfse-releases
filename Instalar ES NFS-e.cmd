@echo off
title Instalar ES NFS-e
echo Instalando o ES NFS-e - Everton Sousa Contabilidade...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; iex (irm https://raw.githubusercontent.com/ESFinancas/es-nfse-releases/main/instalar.ps1)"
if errorlevel 1 pause
