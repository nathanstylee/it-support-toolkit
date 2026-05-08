<#
.SYNOPSIS
Creates a generic SQL Server schema inventory report.

.DESCRIPTION
This sanitized example connects to a SQL Server or SQL Server Express database
and inventories tables, columns, indexes, views, stored procedures, and
functions. It writes JSON and Markdown reports under the artifacts folder.

Use this against lab or approved systems only. Review generated reports before
sharing because schema names from real systems may be sensitive.

.EXAMPLE
.\sql-schema-inventory.ps1 -Server ".\SQLEXPRESS" -Database "SampleDatabase" -UseWindowsAuth

.EXAMPLE
$env:SQL_INVENTORY_USERNAME = "sample_user"
# Set SQL_INVENTORY_PASSWORD in your shell or secret store before running.
.\sql-schema-inventory.ps1 -Server "<server-name>" -Database "SampleDatabase"
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Server = ".\SQLEXPRESS",

    [Parameter()]
    [string]$Database = "SampleDatabase",

    [Parameter()]
    [switch]$UseWindowsAuth,

    [Parameter()]
    [string]$Username = $env:SQL_INVENTORY_USERNAME,

    [Parameter()]
    [string]$Password = $env:SQL_INVENTORY_PASSWORD,

    [Parameter()]
    [string]$OutputDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Data

function New-ConnectionString {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder["Data Source"] = $Server
    $builder["Initial Catalog"] = $Database
    $builder["TrustServerCertificate"] = $true
    $builder["Connect Timeout"] = 15

    if ($UseWindowsAuth -or [string]::IsNullOrWhiteSpace($Username)) {
        $builder["Integrated Security"] = $true
    }
    else {
        $builder["Integrated Security"] = $false
        $builder["User ID"] = $Username
        $builder["Password"] = $Password
    }

    return $builder.ConnectionString
}

function Invoke-InventoryQuery {
    param(
        [Parameter(Mandatory)]
        [System.Data.SqlClient.SqlConnection]$Connection,

        [Parameter(Mandatory)]
        [string]$Query
    )

    $command = $Connection.CreateCommand()
    $command.CommandText = $Query
    $command.CommandTimeout = 60

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
    $table = New-Object System.Data.DataTable
    [void]$adapter.Fill($table)

    $rows = foreach ($row in $table.Rows) {
        $object = [ordered]@{}
        foreach ($column in $table.Columns) {
            $value = $row[$column.ColumnName]
            if ($value -is [System.DBNull]) {
                $value = $null
            }
            $object[$column.ColumnName] = $value
        }
        [pscustomobject]$object
    }

    return @($rows)
}

$queries = [ordered]@{
    Tables = @"
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    t.create_date AS CreatedAt,
    t.modify_date AS ModifiedAt,
    SUM(CASE WHEN p.index_id IN (0, 1) THEN p.row_count ELSE 0 END) AS RowCountEstimate
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.dm_db_partition_stats p ON t.object_id = p.object_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name, t.create_date, t.modify_date
ORDER BY s.name, t.name;
"@
    Columns = @"
SELECT
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type_desc AS ObjectType,
    c.column_id AS ColumnOrder,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.precision AS NumericPrecision,
    c.scale AS NumericScale,
    c.is_nullable AS IsNullable,
    c.is_identity AS IsIdentity
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE o.type IN ('U', 'V')
  AND o.is_ms_shipped = 0
ORDER BY s.name, o.name, c.column_id;
"@
    Indexes = @"
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key AS IsPrimaryKey,
    i.is_unique AS IsUnique,
    STUFF((
        SELECT ', ' + c2.name
        FROM sys.index_columns ic2
        INNER JOIN sys.columns c2
            ON ic2.object_id = c2.object_id
            AND ic2.column_id = c2.column_id
        WHERE ic2.object_id = i.object_id
          AND ic2.index_id = i.index_id
        ORDER BY ic2.key_ordinal
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)'), 1, 2, '') AS IndexedColumns
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0
  AND i.name IS NOT NULL
ORDER BY s.name, t.name, i.name;
"@
    Views = @"
SELECT
    s.name AS SchemaName,
    v.name AS ViewName,
    v.create_date AS CreatedAt,
    v.modify_date AS ModifiedAt
FROM sys.views v
INNER JOIN sys.schemas s ON v.schema_id = s.schema_id
WHERE v.is_ms_shipped = 0
ORDER BY s.name, v.name;
"@
    StoredProcedures = @"
SELECT
    s.name AS SchemaName,
    p.name AS ProcedureName,
    p.create_date AS CreatedAt,
    p.modify_date AS ModifiedAt
FROM sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.is_ms_shipped = 0
ORDER BY s.name, p.name;
"@
    Functions = @"
SELECT
    s.name AS SchemaName,
    o.name AS FunctionName,
    o.type_desc AS FunctionType,
    o.create_date AS CreatedAt,
    o.modify_date AS ModifiedAt
FROM sys.objects o
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type IN ('FN', 'IF', 'TF', 'FS', 'FT')
  AND o.is_ms_shipped = 0
ORDER BY s.name, o.name;
"@
}

$connectionString = New-ConnectionString
$connection = New-Object System.Data.SqlClient.SqlConnection $connectionString

try {
    $connection.Open()

    $inventory = [ordered]@{
        Server = $Server
        Database = $Database
        GeneratedAt = (Get-Date).ToString("s")
        Tables = @()
        Columns = @()
        Indexes = @()
        Views = @()
        StoredProcedures = @()
        Functions = @()
    }

    foreach ($name in $queries.Keys) {
        $inventory[$name] = Invoke-InventoryQuery -Connection $connection -Query $queries[$name]
    }
}
finally {
    $connection.Dispose()
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

$jsonPath = Join-Path $OutputDirectory "db-inventory.json"
$markdownPath = Join-Path $OutputDirectory "db-inventory.md"

$inventory | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonPath -Encoding UTF8

$markdown = New-Object System.Collections.Generic.List[string]
$markdown.Add("# Database Inventory")
$markdown.Add("")
$markdown.Add("- Server: ``$Server``")
$markdown.Add("- Database: ``$Database``")
$markdown.Add("- Generated: $($inventory.GeneratedAt)")
$markdown.Add("")

foreach ($section in @("Tables", "Columns", "Indexes", "Views", "StoredProcedures", "Functions")) {
    $rows = @($inventory[$section])
    $markdown.Add("## $section")
    $markdown.Add("")
    $markdown.Add("Count: $($rows.Count)")
    $markdown.Add("")

    if ($rows.Count -eq 0) {
        $markdown.Add("_No items found._")
        $markdown.Add("")
        continue
    }

    $columns = @($rows[0].PSObject.Properties.Name)
    $markdown.Add("| " + ($columns -join " | ") + " |")
    $markdown.Add("| " + (($columns | ForEach-Object { "---" }) -join " | ") + " |")

    foreach ($row in $rows) {
        $values = foreach ($column in $columns) {
            $text = [string]$row.$column
            $text.Replace("|", "\|")
        }
        $markdown.Add("| " + ($values -join " | ") + " |")
    }

    $markdown.Add("")
}

$markdown | Set-Content -Path $markdownPath -Encoding UTF8

Write-Host "Inventory written to:"
Write-Host "- $jsonPath"
Write-Host "- $markdownPath"
