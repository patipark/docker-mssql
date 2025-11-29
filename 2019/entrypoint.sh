#!/bin/bash

# ตั้งค่า SQL Server เพื่อประหยัดทรัพยากร
# https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/server-memory-server-configuration-options

# เริ่ม SQL Server ในพื้นหลัง
/opt/mssql/bin/sqlservr &

# รอให้ SQL Server พร้อม
sleep 20s

# ปรับแต่งการใช้หน่วยความจำ (ตั้งค่าต่ำสุดและสูงสุด)
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "EXEC sp_configure 'show advanced options', 1; RECONFIGURE;"
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "EXEC sp_configure 'min server memory (MB)', 256; RECONFIGURE;"
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "EXEC sp_configure 'max server memory (MB)', 1536; RECONFIGURE;"

# ปรับแต่ง parallelism เพื่อลด CPU usage
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "EXEC sp_configure 'max degree of parallelism', 2; RECONFIGURE;"
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "EXEC sp_configure 'cost threshold for parallelism', 50; RECONFIGURE;"

# ปิด SQL Server Agent (ถ้ายังไม่ได้ปิด)
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "EXEC sp_configure 'Agent XPs', 0; RECONFIGURE;"

echo "SQL Server optimization completed"

# นำ SQL Server process กลับมาที่ foreground
wait
