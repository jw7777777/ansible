Role Name
=========

Refresh a SQL Server database

Requirements
------------

To workaround WinRM "double-hop" issue, enable CredSSP on the destination SQL Server instance

e.g on server win03 in this example.
```powershell
Enable-WSManCredSSP -Role Server -Force
```
Role Variables
--------------

### `mssql_src_db_instance`

The source SQL server hostname and instance name.   

This variable is required when you run the role to refresh a SQL Server database

Default: `null`

Type: `str`

### `mssql_dst_db_instance`

The destinantion SQL server hostname and instance name.   

This variable is required when you run the role to refresh a SQL Server database

Default: `null`

Type: `str`

### `mssql_src_db_name`

The source database name.   The source database must already exist.

This variable is required when you run the role to refresh a SQL Server database

Default: `null`

Type: `str`

### `mssql_dst_db_name`

The destination database name.   If the destination database already exists on the destination SQL Server instance, it will be overwritten with a copy of the source database contents.

This variable is required when you run the role to refresh a SQL Server database

Default: `null`

Type: `str`

### `mssql_fileshare_path`

The UNC network share path used to store the SQL server disk backups to.   

This variable is required when you run the role to refresh a SQL Server database

Default: `\\win03\MSSQLBackup`

Type: `str`

Dependencies
------------

dbatools powershell module is imported (https://dbatools.io).  The dbatools module will be imported by this role

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

- hosts: all
  vars:
    mssql_src_db_instance: win02
    mssql_dst_db_instance: win03
    mssql_src_db_name: AdventureWorks 
    mssql_dst_db_name: AdventureWorks_DEV
  roles:
    - microsoft.sql.server

License
-------

MIT

Author Information
------------------

jw7777777
