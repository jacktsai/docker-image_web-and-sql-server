FROM microsoft/windowsservercore

# install sql server
RUN powershell -Command (New-Object System.Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/?linkid=829176', 'sqlexpress.exe') && /sqlexpress.exe /qs /x:setup && /setup/setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT="NT AUTHORITY\System" /SQLSYSADMINACCOUNTS="BUILTIN\ADMINISTRATORS" /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS && del /F /Q sqlexpress.exe && rd /q /s setup

# install web server
RUN powershell -Command \
	Add-WindowsFeature Web-Server; \
	Add-WindowsFeature NET-Framework-45-ASPNET; \
	Add-WindowsFeature Web-Asp-Net45;

# setup sql server
RUN powershell -Command \
	Invoke-Sqlcmd -Query 'ALTER LOGIN sa with password=''P@ssw0rd''; ALTER LOGIN sa ENABLE;' \
        set-strictmode -version latest; \
        stop-service MSSQLSERVER; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql13.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value ''; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql13.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql13.MSSQLSERVER\mssqlserver\' -name LoginMode -value 2;

EXPOSE 80 1433
CMD powershell
