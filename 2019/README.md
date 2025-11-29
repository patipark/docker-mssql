# SQL Server Docker - Optimized for Low Resource Usage

## การปรับแต่งเพื่อประหยัด CPU และ Memory

### 1. Docker Compose Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'        # จำกัด CPU สูงสุด 2 cores
      memory: 2G         # จำกัด RAM สูงสุด 2GB
    reservations:
      cpus: '0.5'        # สำรอง CPU ขั้นต่ำ
      memory: 512M       # สำรอง RAM ขั้นต่ำ
```

### 2. SQL Server Configuration

**Memory Settings:**
- `MSSQL_MEMORY_LIMIT_MB=1536` - จำกัดหน่วยความจำ 1.5GB
- `min server memory = 256 MB` - หน่วยความจำต่ำสุด
- `max server memory = 1536 MB` - หน่วยความจำสูงสุด

**CPU Settings:**
- `max degree of parallelism = 2` - จำกัดการใช้ CPU cores สำหรับ query ละ 2 cores
- `cost threshold for parallelism = 50` - เพิ่มค่า threshold เพื่อลดการใช้ parallel processing

**Features Disabled:**
- SQL Server Agent ปิดการใช้งาน
- HADR (High Availability) ปิดการใช้งาน

### 3. Database Configuration

**Recovery Model:**
- ใช้ `SIMPLE` recovery model เพื่อลดการใช้ log space

**File Growth:**
- Data file เพิ่มทีละ 64MB (แทน percentage)
- Log file เพิ่มทีละ 32MB

**Auto Settings:**
- `AUTO_SHRINK = OFF` - ปิดเพื่อลดการใช้ CPU
- `AUTO_CLOSE = OFF` - ปิดเพื่อไม่ให้ database ปิด-เปิดบ่อย

## การใช้งาน

### สร้างไฟล์ sa_password.secret
```bash
echo 'YourStrongPassword123!' > sa_password.secret
```

### เพิ่มในไฟล์ .gitignore
```
sa_password.secret
```

### สร้างและรัน container
```bash
docker-compose up -d
```

### ตรวจสอบการใช้ทรัพยากร
```bash
# ดู resource usage แบบ real-time
docker stats

# ดูเฉพาะ container ของ SQL Server
docker stats <container_name>
```

## การปรับแต่งเพิ่มเติม

### ถ้าต้องการลดทรัพยากรมากกว่านี้:

1. **ลด Memory เพิ่ม:**
```yaml
environment:
  - MSSQL_MEMORY_LIMIT_MB=1024  # ลดเหลือ 1GB
```

2. **ลด CPU cores:**
```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'  # จำกัดเหลือ 1 core
```

3. **ปรับ max degree of parallelism:**
```sql
EXEC sp_configure 'max degree of parallelism', 1;  -- ใช้แค่ 1 thread
```

### ถ้าต้องการ performance มากกว่านี้:

1. **เพิ่ม Memory:**
```yaml
deploy:
  resources:
    limits:
      memory: 4G
environment:
  - MSSQL_MEMORY_LIMIT_MB=3584
```

2. **เพิ่ม CPU:**
```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'
```

## หมายเหตุ

- การตั้งค่านี้เหมาะสำหรับ **Development/Testing environment**
- สำหรับ Production ควรปรับเพิ่มทรัพยากรตามความเหมาะสม
- ควรมีการ monitor ทรัพยากรเป็นประจำ
- ถ้า application มี load สูง อาจต้องปรับเพิ่มทรัพยากร

## ตรวจสอบการตั้งค่าปัจจุบัน

เชื่อมต่อเข้า SQL Server และรัน:

```sql
-- ตรวจสอบ memory configuration
EXEC sp_configure 'max server memory';
EXEC sp_configure 'min server memory';

-- ตรวจสอบ CPU configuration  
EXEC sp_configure 'max degree of parallelism';
EXEC sp_configure 'cost threshold for parallelism';

-- ตรวจสอบ memory usage ปัจจุบัน
SELECT 
    physical_memory_in_use_kb/1024 AS memory_used_MB,
    available_physical_memory_kb/1024 AS available_memory_MB
FROM sys.dm_os_process_memory;
```

## Performance Monitoring

```sql
-- CPU usage
SELECT 
    scheduler_id,
    cpu_id,
    current_tasks_count,
    runnable_tasks_count,
    work_queue_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255;

-- Memory clerks
SELECT TOP 10
    type,
    SUM(pages_kb)/1024 AS memory_MB
FROM sys.dm_os_memory_clerks
GROUP BY type
ORDER BY memory_MB DESC;
```
