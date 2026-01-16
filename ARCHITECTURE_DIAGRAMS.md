# 🏗️ HMS System Architecture Diagrams

> **Senior System Design Engineer**  
> **Hospital Management System - Complete Architecture**  
> **Date:** 2026-01-16

---

## 📊 Table of Contents

1. [High-Level System Architecture](#1-high-level-system-architecture)
2. [Frontend Architecture](#2-frontend-architecture)
3. [Backend Architecture](#3-backend-architecture)
4. [Database Architecture](#4-database-architecture)
5. [Deployment Architecture](#5-deployment-architecture)
6. [Real-time Communication Flow](#6-real-time-communication-flow)
7. [Authentication & Authorization Flow](#7-authentication--authorization-flow)
8. [Data Flow Diagrams](#8-data-flow-diagrams)
9. [Multi-Tenant Architecture](#9-multi-tenant-architecture)
10. [Scalability & Performance](#10-scalability--performance)

---

## 1. High-Level System Architecture

### Overview

```mermaid
graph TB
    subgraph "Client Layer"
        WEB["🌐 Web App<br/>(Next.js 15)"]
        ANDROID["📱 Android App<br/>(Jetpack Compose)"]
        IOS["🍎 iOS App<br/>(SwiftUI)"]
    end

    subgraph "CDN & Edge"
        CF["Cloudflare CDN<br/>Global Edge Network"]
    end

    subgraph "API Gateway Layer"
        LB["Load Balancer<br/>(Application LB)"]
        WAF["WAF<br/>Security Layer"]
    end

    subgraph "Backend Services"
        GO["Go Service<br/>(Fiber v3)<br/>Primary API"]
        PY["Python Service<br/>(FastAPI)<br/>ML & Analytics"]
        WS["WebSocket Server<br/>(Go)"]
    end

    subgraph "Data Layer"
        REDIS["Redis Cluster<br/>Cache & Pub/Sub"]
        PG["PostgreSQL<br/>(Aurora/Neon)<br/>Primary DB"]
        S3["Object Storage<br/>(S3/GCS)"]
    end

    subgraph "External Services"
        NOTIFY["Notification Service<br/>(FCM/APNs)"]
        EMAIL["Email Service<br/>(SendGrid)"]
    end

    WEB --> CF
    ANDROID --> LB
    IOS --> LB
    CF --> LB
    
    LB --> WAF
    WAF --> GO
    WAF --> PY
    WAF --> WS
    
    GO --> REDIS
    GO --> PG
    PY --> REDIS
    PY --> PG
    WS --> REDIS
    
    GO --> S3
    PY --> S3
    
    GO --> NOTIFY
    GO --> EMAIL
    
    style WEB fill:#4A90E2
    style ANDROID fill:#4CAF50
    style IOS fill:#FF9500
    style GO fill:#00ADD8
    style PY fill:#3776AB
    style REDIS fill:#DC382D
    style PG fill:#336791
```

---

## 2. Frontend Architecture

### Web Architecture (Next.js 15)

```mermaid
graph TB
    subgraph "Next.js Application"
        subgraph "App Router"
            LAYOUT["app/layout.tsx<br/>Root Layout"]
            HOME["app/page.tsx<br/>Home"]
            DASH["app/dashboard/page.tsx<br/>Dashboard"]
            WORK["app/workbench/page.tsx<br/>Doctor Workbench"]
        end
        
        subgraph "Components Layer"
            SHADCN["Shadcn/ui<br/>Base Components"]
            CUSTOM["Custom Components"]
            CHARTS["Recharts<br/>Data Visualization"]
        end
        
        subgraph "State Management"
            ZUSTAND["Zustand<br/>Global State"]
            TANSTACK["TanStack Query<br/>Server State"]
            SOCKET["Socket.io Client<br/>Real-time"]
        end
        
        subgraph "Services"
            API["API Client<br/>(Axios)"]
            AUTH["Auth Service"]
            WEBSOCKET["WebSocket Service"]
        end
        
        subgraph "Styling"
            TAILWIND["Tailwind CSS"]
            FRAMER["Framer Motion<br/>Animations"]
        end
    end

    LAYOUT --> HOME
    LAYOUT --> DASH
    LAYOUT --> WORK
    
    HOME --> CUSTOM
    DASH --> CUSTOM
    WORK --> CUSTOM
    
    CUSTOM --> SHADCN
    CUSTOM --> CHARTS
    CUSTOM --> FRAMER
    
    CUSTOM --> ZUSTAND
    CUSTOM --> TANSTACK
    CUSTOM --> SOCKET
    
    ZUSTAND --> API
    TANSTACK --> API
    SOCKET --> WEBSOCKET
    
    API --> AUTH
    
    style LAYOUT fill:#0070F3
    style ZUSTAND fill:#433E38
    style TANSTACK fill:#FF4154
    style TAILWIND fill:#38B2AC
```

### Mobile Architecture (Native)

```mermaid
graph LR
    subgraph "Android App (Jetpack Compose)"
        subgraph "Presentation Layer"
            ACOMP["Composables<br/>UI Components"]
            AVIEW["ViewModels<br/>(Hilt Injected)"]
        end
        
        subgraph "Domain Layer"
            AUSECASE["Use Cases<br/>Business Logic"]
            AREPO["Repository Interfaces"]
        end
        
        subgraph "Data Layer"
            AAPI["Retrofit API"]
            AROOM["Room Database"]
            ASOCKET["Socket.IO Client"]
        end
    end
    
    subgraph "iOS App (SwiftUI)"
        subgraph "Presentation"
            IVIEW["SwiftUI Views"]
            IVM["ObservableObjects<br/>ViewModels"]
        end
        
        subgraph "Domain"
            IUSECASE["Use Cases"]
            IREPO["Repository Protocols"]
        end
        
        subgraph "Data"
            IAPI["URLSession"]
            ISWIFTDATA["SwiftData"]
            ISOCKET["Socket.IO Client"]
        end
    end

    ACOMP --> AVIEW
    AVIEW --> AUSECASE
    AUSECASE --> AREPO
    AREPO --> AAPI
    AREPO --> AROOM
    AREPO --> ASOCKET
    
    IVIEW --> IVM
    IVM --> IUSECASE
    IUSECASE --> IREPO
    IREPO --> IAPI
    IREPO --> ISWIFTDATA
    IREPO --> ISOCKET
    
    style ACOMP fill:#4CAF50
    style IVIEW fill:#FF9500
    style AAPI fill:#00ADD8
    style IAPI fill:#00ADD8
```

---

## 3. Backend Architecture

### Microservices Architecture

```mermaid
graph TB
    subgraph "API Gateway"
        NGINX["Nginx / ALB<br/>Load Balancer"]
        RATE["Rate Limiter<br/>(Redis)"]
    end

    subgraph "Go Service (Primary API)"
        subgraph "API Handlers"
            AUTH_H["Auth Handler"]
            PATIENT_H["Patient Handler"]
            PRESC_H["Prescription Handler"]
            VITAL_H["Vitals Handler"]
        end
        
        subgraph "Business Logic"
            AUTH_S["Auth Service"]
            PATIENT_S["Patient Service"]
            PRESC_S["Prescription Service"]
        end
        
        subgraph "Data Access"
            GORM["GORM ORM"]
            REDIS_C["Redis Client"]
        end
        
        subgraph "WebSocket"
            WS_H["WebSocket Handler"]
            PUBSUB["Redis Pub/Sub"]
        end
    end

    subgraph "Python Service (ML/AI)"
        subgraph "ML Endpoints"
            DRUG_INT["Drug Interaction API"]
            DOSAGE["Dosage Calculator"]
            READMIT["Readmission Predictor"]
            OCR["Prescription OCR"]
        end
        
        subgraph "ML Models"
            SKLEARN["scikit-learn Models"]
            TF["TensorFlow Models"]
        end
        
        subgraph "Tasks"
            CELERY["Celery Workers"]
        end
    end

    subgraph "Shared Data Layer"
        POSTGRES["PostgreSQL<br/>Multi-tenant Schemas"]
        REDIS_MAIN["Redis Cluster<br/>Cache + Pub/Sub"]
        S3_BUCKET["S3 Bucket<br/>File Storage"]
    end

    NGINX --> RATE
    RATE --> AUTH_H
    RATE --> PATIENT_H
    RATE --> PRESC_H
    RATE --> VITAL_H
    RATE --> WS_H
    
    AUTH_H --> AUTH_S
    PATIENT_H --> PATIENT_S
    PRESC_H --> PRESC_S
    VITAL_H -.Internal API.-> DRUG_INT
    
    AUTH_S --> GORM
    PATIENT_S --> GORM
    PRESC_S --> GORM
    
    GORM --> POSTGRES
    REDIS_C --> REDIS_MAIN
    
    WS_H --> PUBSUB
    PUBSUB --> REDIS_MAIN
    
    DRUG_INT --> SKLEARN
    DOSAGE --> SKLEARN
    READMIT --> TF
    OCR --> TF
    
    CELERY --> POSTGRES
    CELERY --> REDIS_MAIN
    
    PRESC_H --> S3_BUCKET
    
    style NGINX fill:#009639
    style AUTH_H fill:#00ADD8
    style DRUG_INT fill:#3776AB
    style POSTGRES fill:#336791
    style REDIS_MAIN fill:#DC382D
```

### Service Communication

```mermaid
sequenceDiagram
    participant Client
    participant ALB as Load Balancer
    participant Go as Go Service
    participant Python as Python Service
    participant Redis
    participant Postgres as PostgreSQL

    Client->>ALB: API Request
    ALB->>Go: Route Request
    
    alt Cache Hit
        Go->>Redis: Check Cache
        Redis-->>Go: Return Cached Data
        Go-->>Client: Response (Fast)
    else Cache Miss
        Go->>Postgres: Query Database
        Postgres-->>Go: Return Data
        Go->>Redis: Store in Cache
        Go-->>Client: Response
    end
    
    alt ML Required
        Go->>Python: Internal API Call
        Python->>Postgres: Get ML Data
        Postgres-->>Python: Data
        Python->>Python: Run ML Model
        Python-->>Go: ML Result
        Go-->>Client: Response with ML
    end
```

---

## 4. Database Architecture

### Multi-Tenant Schema Design

```mermaid
graph TB
    subgraph "PostgreSQL Database"
        subgraph "Public Schema"
            TENANTS["tenants<br/>(hospital metadata)"]
            USERS["users<br/>(cross-tenant auth)"]
        end
        
        subgraph "Hospital A Schema"
            A_PAT["patients"]
            A_PRESC["prescriptions"]
            A_VITAL["vitals"]
            A_APPT["appointments"]
        end
        
        subgraph "Hospital B Schema"
            B_PAT["patients"]
            B_PRESC["prescriptions"]
            B_VITAL["vitals"]
            B_APPT["appointments"]
        end
        
        subgraph "Hospital C Schema"
            C_PAT["patients"]
            C_PRESC["prescriptions"]
            C_VITAL["vitals"]
            C_APPT["appointments"]
        end
    end
    
    TENANTS -.identifies.-> A_PAT
    TENANTS -.identifies.-> B_PAT
    TENANTS -.identifies.-> C_PAT
    
    USERS -.authorized for.-> A_PAT
    USERS -.authorized for.-> B_PAT
    
    style TENANTS fill:#FF6B6B
    style A_PAT fill:#4ECDC4
    style B_PAT fill:#95E1D3
    style C_PAT fill:#F38181
```

### Database Schema (ERD - Hospital Schema)

```mermaid
erDiagram
    USERS ||--o{ PATIENTS : "manages"
    USERS ||--o{ PRESCRIPTIONS : "creates"
    PATIENTS ||--o{ PRESCRIPTIONS : "has"
    PATIENTS ||--o{ VITALS : "has"
    PATIENTS ||--o{ APPOINTMENTS : "has"
    PATIENTS ||--o{ LAB_RESULTS : "has"
    PRESCRIPTIONS ||--o{ PRESCRIPTION_ITEMS : "contains"
    PRESCRIPTIONS ||--o{ ADVERSE_EVENTS : "may_have"
    DRUGS ||--o{ PRESCRIPTION_ITEMS : "prescribed_in"
    DRUGS ||--o{ DRUG_INTERACTIONS : "interacts_with"

    USERS {
        uuid id PK
        string email
        string password_hash
        string role
        uuid hospital_id FK
        timestamp created_at
    }
    
    PATIENTS {
        uuid id PK
        string name
        date date_of_birth
        string gender
        string blood_group
        jsonb allergies
        uuid hospital_id FK
        timestamp created_at
    }
    
    PRESCRIPTIONS {
        uuid id PK
        uuid patient_id FK
        uuid doctor_id FK
        timestamp prescribed_at
        string status
        jsonb warnings
    }
    
    PRESCRIPTION_ITEMS {
        uuid id PK
        uuid prescription_id FK
        uuid drug_id FK
        string dosage
        string frequency
        int duration_days
    }
    
    VITALS {
        uuid id PK
        uuid patient_id FK
        timestamp recorded_at
        float heart_rate
        string blood_pressure
        float temperature
        float spo2
    }
    
    DRUGS {
        uuid id PK
        string name
        string category
        jsonb contraindications
        boolean in_stock
    }
```

### Caching Strategy

```mermaid
graph LR
    subgraph "Cache Layers"
        L1["L1: Application Memory<br/>(In-Process Cache)"]
        L2["L2: Redis<br/>(Distributed Cache)"]
        L3["L3: PostgreSQL<br/>(Source of Truth)"]
    end
    
    APP["Application"]
    
    APP -->|1. Check| L1
    L1 -->|Miss| L2
    L2 -->|Miss| L3
    L3 -->|Store| L2
    L2 -->|Store| L1
    L1 -->|Hit| APP
    
    style L1 fill:#FFD93D
    style L2 fill:#DC382D
    style L3 fill:#336791
```

---

## 5. Deployment Architecture

### Development Environment

```mermaid
graph TB
    subgraph "Local Development"
        DEV_FE["Frontend Dev Server<br/>(Next.js / Expo)"]
        DEV_GO["Go Service<br/>(localhost:8080)"]
        DEV_PY["Python Service<br/>(localhost:8000)"]
        DEV_DB["PostgreSQL<br/>(Docker / Neon)"]
        DEV_REDIS["Redis<br/>(Docker)"]
    end
    
    DEV_FE --> DEV_GO
    DEV_FE --> DEV_PY
    DEV_GO --> DEV_DB
    DEV_GO --> DEV_REDIS
    DEV_PY --> DEV_DB
    
    style DEV_FE fill:#0070F3
    style DEV_GO fill:#00ADD8
    style DEV_PY fill:#3776AB
```

### Production Deployment (GCP)

```mermaid
graph TB
    subgraph "Global CDN"
        CF["Cloudflare CDN<br/>Global PoPs"]
    end
    
    subgraph "Google Cloud Platform"
        subgraph "Frontend Hosting"
            VERCEL["Vercel Edge Network<br/>(Next.js)"]
        end
        
        subgraph "Compute Engine"
            LB["Cloud Load Balancer"]
            
            subgraph "Cloud Run Services"
                GO1["Go API Instance 1"]
                GO2["Go API Instance 2"]
                GO3["Go API Instance 3"]
                PY1["Python ML Instance"]
            end
        end
        
        subgraph "Database Layer"
            CLOUDSQL["Cloud SQL<br/>PostgreSQL<br/>(Primary)"]
            REPLICA1["Read Replica 1<br/>(US)"]
            REPLICA2["Read Replica 2<br/>(EU)"]
        end
        
        subgraph "Caching & Queue"
            MEMORYSTORE["Memorystore<br/>Redis Cluster"]
        end
        
        subgraph "Storage"
            GCS["Cloud Storage<br/>(Files & Backups)"]
        end
        
        subgraph "Monitoring"
            CLOUDMON["Cloud Monitoring"]
            CLOUDLOG["Cloud Logging"]
        end
    end
    
    subgraph "Mobile Delivery"
        APPSTORE["App Store"]
        PLAYSTORE["Play Store"]
    end

    CF --> VERCEL
    CF --> LB
    
    LB --> GO1
    LB --> GO2
    LB --> GO3
    LB --> PY1
    
    GO1 --> MEMORYSTORE
    GO2 --> MEMORYSTORE
    GO3 --> MEMORYSTORE
    PY1 --> MEMORYSTORE
    
    GO1 --> CLOUDSQL
    GO2 --> REPLICA1
    GO3 --> REPLICA2
    PY1 --> CLOUDSQL
    
    GO1 --> GCS
    PY1 --> GCS
    
    CLOUDSQL -.replicates to.-> REPLICA1
    CLOUDSQL -.replicates to.-> REPLICA2
    
    GO1 --> CLOUDMON
    GO1 --> CLOUDLOG
    
    APPSTORE -.downloads.-> IOS_APP["iOS App"]
    PLAYSTORE -.downloads.-> ANDROID_APP["Android App"]
    
    IOS_APP --> CF
    ANDROID_APP --> CF
    
    style CF fill:#F38020
    style VERCEL fill:#000000
    style GO1 fill:#00ADD8
    style CLOUDSQL fill:#4285F4
    style MEMORYSTORE fill:#DC382D
```

### Auto-Scaling Strategy

```mermaid
graph LR
    subgraph "Auto-Scaling Rules"
        METRIC["Metrics<br/>CPU / Memory / Requests"]
        THRESHOLD["Threshold Check<br/>CPU > 70%"]
        SCALE_UP["Scale Up<br/>Add Instances"]
        SCALE_DOWN["Scale Down<br/>Remove Instances"]
    end
    
    subgraph "Instance Pool"
        INST1["Instance 1"]
        INST2["Instance 2"]
        INST3["Instance 3"]
        INST_N["Instance N"]
    end
    
    METRIC --> THRESHOLD
    THRESHOLD -->|Above| SCALE_UP
    THRESHOLD -->|Below| SCALE_DOWN
    
    SCALE_UP --> INST_N
    SCALE_DOWN --> INST3
    
    style METRIC fill:#4285F4
    style SCALE_UP fill:#34A853
    style SCALE_DOWN fill:#EA4335
```

---

## 6. Real-time Communication Flow

### WebSocket Architecture

```mermaid
sequenceDiagram
    participant Client1 as Client (Doctor)
    participant Client2 as Client (Pharmacist)
    participant WS as WebSocket Server
    participant Redis as Redis Pub/Sub
    participant DB as PostgreSQL

    Note over Client1,DB: Initial Connection
    Client1->>WS: Connect + Auth Token
    WS->>WS: Validate Token
    WS->>Redis: Subscribe to hospital:A:*
    WS-->>Client1: Connected

    Note over Client1,DB: Doctor Creates Prescription
    Client1->>WS: {event: "prescription:create", data: {...}}
    WS->>DB: Save Prescription
    DB-->>WS: Success
    WS->>Redis: Publish to hospital:A:prescriptions
    WS-->>Client1: {event: "prescription:created", data: {...}}
    
    Note over Client2,DB: Pharmacist Receives Update
    Client2->>WS: Connect (joins hospital:A room)
    WS->>Redis: Subscribe to hospital:A:*
    Redis-->>WS: New prescription event
    WS-->>Client2: {event: "prescription:new", data: {...}}
    
    Note over Client1,DB: Real-time Vitals Update
    Client1->>WS: {event: "vitals:update", patient_id: "123"}
    WS->>Redis: Publish to hospital:A:vitals
    Redis-->>WS: Broadcast
    WS-->>Client1: {event: "vitals:updated"}
    WS-->>Client2: {event: "vitals:updated"} (if subscribed)
```

### Pub/Sub Pattern

```mermaid
graph TB
    subgraph "Publishers"
        GO["Go API<br/>(Prescriptions)"]
        DEVICE["IoT Device<br/>(Vitals Monitor)"]
        ADMIN["Admin Panel<br/>(Announcements)"]
    end
    
    subgraph "Redis Pub/Sub"
        CHANNEL1["Channel: hospital:A:prescriptions"]
        CHANNEL2["Channel: hospital:A:vitals"]
        CHANNEL3["Channel: hospital:A:announcements"]
    end
    
    subgraph "Subscribers"
        WS1["WebSocket Server 1"]
        WS2["WebSocket Server 2"]
        WS3["WebSocket Server 3"]
    end
    
    subgraph "Clients"
        DOCTOR["Doctor (Web)"]
        NURSE["Nurse (Android)"]
        PHARMA["Pharmacist (iOS)"]
    end
    
    GO --> CHANNEL1
    DEVICE --> CHANNEL2
    ADMIN --> CHANNEL3
    
    CHANNEL1 --> WS1
    CHANNEL1 --> WS2
    CHANNEL2 --> WS2
    CHANNEL2 --> WS3
    CHANNEL3 --> WS1
    CHANNEL3 --> WS2
    CHANNEL3 --> WS3
    
    WS1 --> DOCTOR
    WS2 --> NURSE
    WS3 --> PHARMA
    
    style GO fill:#00ADD8
    style CHANNEL1 fill:#DC382D
    style DOCTOR fill:#0070F3
```

---

## 7. Authentication & Authorization Flow

### JWT Authentication Flow

```mermaid
sequenceDiagram
    participant Client
    participant Go as Go API
    participant DB as PostgreSQL
    participant Redis

    Note over Client,Redis: Login Flow
    Client->>Go: POST /auth/login<br/>{email, password}
    Go->>DB: SELECT user WHERE email
    DB-->>Go: User data
    Go->>Go: Verify password (Argon2)
    Go->>Go: Generate JWT (15min)<br/>Generate Refresh Token (7 days)
    Go->>Redis: Store refresh token
    Go-->>Client: {accessToken, refreshToken}
    
    Note over Client,Redis: Authenticated Request
    Client->>Go: GET /patients<br/>Authorization: Bearer {accessToken}
    Go->>Go: Validate JWT
    Go->>Go: Extract user + hospital from JWT
    Go->>DB: SELECT FROM hospital_a.patients
    DB-->>Go: Patients data
    Go-->>Client: {patients: [...]}
    
    Note over Client,Redis: Token Refresh
    Client->>Go: POST /auth/refresh<br/>{refreshToken}
    Go->>Redis: Verify refresh token
    Redis-->>Go: Valid
    Go->>Go: Generate new JWT
    Go-->>Client: {accessToken}
    
    Note over Client,Redis: Logout
    Client->>Go: POST /auth/logout<br/>{refreshToken}
    Go->>Redis: DELETE refresh token
    Go-->>Client: Success
```

### RBAC (Role-Based Access Control)

```mermaid
graph TB
    subgraph "Roles"
        SUPER_ADMIN["Super Admin<br/>(Platform)"]
        HOSPITAL_ADMIN["Hospital Admin"]
        DOCTOR["Doctor"]
        NURSE["Nurse"]
        PHARMACIST["Pharmacist"]
        LAB_STAFF["Lab Staff"]
        RECEPTIONIST["Receptionist"]
    end
    
    subgraph "Permissions"
        MANAGE_HOSPITALS["Manage Hospitals"]
        MANAGE_USERS["Manage Users"]
        VIEW_PATIENTS["View Patients"]
        EDIT_PATIENTS["Edit Patients"]
        CREATE_PRESC["Create Prescriptions"]
        VIEW_PRESC["View Prescriptions"]
        DISPENSE["Dispense Medication"]
        CREATE_LAB["Create Lab Orders"]
        VIEW_LAB["View Lab Results"]
        CHECKIN["Patient Check-in"]
    end
    
    SUPER_ADMIN --> MANAGE_HOSPITALS
    SUPER_ADMIN --> MANAGE_USERS
    
    HOSPITAL_ADMIN --> MANAGE_USERS
    HOSPITAL_ADMIN --> VIEW_PATIENTS
    HOSPITAL_ADMIN --> EDIT_PATIENTS
    
    DOCTOR --> VIEW_PATIENTS
    DOCTOR --> EDIT_PATIENTS
    DOCTOR --> CREATE_PRESC
    DOCTOR --> VIEW_PRESC
    DOCTOR --> CREATE_LAB
    DOCTOR --> VIEW_LAB
    
    NURSE --> VIEW_PATIENTS
    NURSE --> EDIT_PATIENTS
    NURSE --> VIEW_PRESC
    NURSE --> VIEW_LAB
    
    PHARMACIST --> VIEW_PATIENTS
    PHARMACIST --> VIEW_PRESC
    PHARMACIST --> DISPENSE
    
    LAB_STAFF --> VIEW_PATIENTS
    LAB_STAFF --> VIEW_LAB
    LAB_STAFF --> CREATE_LAB
    
    RECEPTIONIST --> VIEW_PATIENTS
    RECEPTIONIST --> EDIT_PATIENTS
    RECEPTIONIST --> CHECKIN
    
    style SUPER_ADMIN fill:#FF6B6B
    style DOCTOR fill:#4ECDC4
    style PHARMACIST fill:#95E1D3
```

---

## 8. Data Flow Diagrams

### Prescription Creation Flow

```mermaid
flowchart TD
    START([Doctor Opens Workbench])
    SELECT[Select Patient]
    LOAD_HISTORY[Load Patient History<br/>Allergies, Current Meds]
    
    CHECK_CACHE{Cache Hit?}
    GET_CACHE[Get from Redis]
    GET_DB[Query PostgreSQL]
    STORE_CACHE[Store in Redis]
    
    DISPLAY[Display Patient Info]
    
    INPUT[Doctor Inputs Prescription]
    ML_CHECK[ML Service Checks:<br/>- Drug Interactions<br/>- Dosage Safety<br/>- Allergy Conflicts]
    
    WARN{Warnings?}
    SHOW_WARN[Show Warning Dialog]
    OVERRIDE{Doctor Override?}
    
    VALIDATE[Validate Prescription]
    SAVE[Save to PostgreSQL]
    
    UPDATE_CACHE[Update Redis Cache]
    NOTIFY_WS[Publish to WebSocket]
    NOTIFY_PHARMA[Notify Pharmacist]
    
    SUCCESS([Prescription Created])
    CANCEL([Cancelled])
    
    START --> SELECT
    SELECT --> LOAD_HISTORY
    LOAD_HISTORY --> CHECK_CACHE
    
    CHECK_CACHE -->|Yes| GET_CACHE
    CHECK_CACHE -->|No| GET_DB
    GET_DB --> STORE_CACHE
    STORE_CACHE --> DISPLAY
    GET_CACHE --> DISPLAY
    
    DISPLAY --> INPUT
    INPUT --> ML_CHECK
    ML_CHECK --> WARN
    
    WARN -->|Yes| SHOW_WARN
    WARN -->|No| VALIDATE
    SHOW_WARN --> OVERRIDE
    OVERRIDE -->|Yes| VALIDATE
    OVERRIDE -->|No| CANCEL
    
    VALIDATE --> SAVE
    SAVE --> UPDATE_CACHE
    UPDATE_CACHE --> NOTIFY_WS
    NOTIFY_WS --> NOTIFY_PHARMA
    NOTIFY_PHARMA --> SUCCESS
    
    style START fill:#4ECDC4
    style ML_CHECK fill:#3776AB
    style SAVE fill:#336791
    style SUCCESS fill:#34A853
    style CANCEL fill:#EA4335
```

### Real-time Vitals Monitoring

```mermaid
flowchart LR
    DEVICE["IoT Vitals Monitor"]
    GATEWAY["IoT Gateway"]
    API["Go API"]
    REDIS["Redis Pub/Sub"]
    DB["PostgreSQL<br/>(Time-series)"]
    
    WS1["WebSocket<br/>Server 1"]
    WS2["WebSocket<br/>Server 2"]
    
    DOCTOR["Doctor Dashboard<br/>(Web)"]
    NURSE["Nurse Station<br/>(Android)"]
    
    ALERT["Alert Service"]
    NOTIFY["Push Notification"]
    
    DEVICE -->|MQTT/HTTP| GATEWAY
    GATEWAY -->|POST /vitals| API
    
    API --> DB
    API --> REDIS
    
    REDIS --> WS1
    REDIS --> WS2
    
    WS1 --> DOCTOR
    WS2 --> NURSE
    
    API -->|Critical Values| ALERT
    ALERT --> NOTIFY
    NOTIFY --> DOCTOR
    NOTIFY --> NURSE
    
    style DEVICE fill:#FF6B6B
    style REDIS fill:#DC382D
    style ALERT fill:#FFA500
```

---

## 9. Multi-Tenant Architecture

### Tenant Isolation Strategy

```mermaid
graph TB
    subgraph "Single Database"
        PUBLIC["Public Schema<br/>- tenants<br/>- users<br/>- global_configs"]
        
        subgraph "Hospital A"
            A_SCHEMA["Schema: hospital_a"]
            A_TABLES["Tables:<br/>- patients<br/>- prescriptions<br/>- vitals<br/>- appointments"]
        end
        
        subgraph "Hospital B"
            B_SCHEMA["Schema: hospital_b"]
            B_TABLES["Tables:<br/>- patients<br/>- prescriptions<br/>- vitals<br/>- appointments"]
        end
        
        subgraph "Hospital C"
            C_SCHEMA["Schema: hospital_c"]
            C_TABLES["Tables:<br/>- patients<br/>- prescriptions<br/>- vitals<br/>- appointments"]
        end
    end
    
    subgraph "Request Flow"
        REQUEST["Incoming Request"]
        AUTH["Extract JWT"]
        TENANT_ID["Get tenant_id<br/>(hospital_id)"]
        SET_SCHEMA["SET search_path TO<br/>hospital_{id}"]
        QUERY["Execute Query"]
    end
    
    REQUEST --> AUTH
    AUTH --> TENANT_ID
    TENANT_ID --> SET_SCHEMA
    
    SET_SCHEMA -.dynamically switches to.-> A_SCHEMA
    SET_SCHEMA -.dynamically switches to.-> B_SCHEMA
    SET_SCHEMA -.dynamically switches to.-> C_SCHEMA
    
    A_SCHEMA --> A_TABLES
    B_SCHEMA --> B_TABLES
    C_SCHEMA --> C_TABLES
    
    SET_SCHEMA --> QUERY
    
    style PUBLIC fill:#FFD93D
    style A_SCHEMA fill:#4ECDC4
    style B_SCHEMA fill:#95E1D3
    style C_SCHEMA fill:#F38181
    style TENANT_ID fill:#FF6B6B
```

### Tenant-Aware Caching

```mermaid
graph LR
    subgraph "Redis Cache Structure"
        H_A["hospital:A:patients:{id}<br/>hospital:A:prescriptions:*<br/>hospital:A:drugs:*"]
        H_B["hospital:B:patients:{id}<br/>hospital:B:prescriptions:*<br/>hospital:B:drugs:*"]
        H_C["hospital:C:patients:{id}<br/>hospital:C:prescriptions:*<br/>hospital:C:drugs:*"]
        
        GLOBAL["global:drugs<br/>global:icd_codes<br/>(Shared across tenants)"]
    end
    
    REQ_A["Request from<br/>Hospital A"]
    REQ_B["Request from<br/>Hospital B"]
    
    REQ_A --> H_A
    REQ_A --> GLOBAL
    REQ_B --> H_B
    REQ_B --> GLOBAL
    
    style H_A fill:#4ECDC4
    style H_B fill:#95E1D3
    style H_C fill:#F38181
    style GLOBAL fill:#FFD93D
```

---

## 10. Scalability & Performance

### Load Balancing Strategy

```mermaid
graph TB
    USERS["100,000+ Users"]
    
    subgraph "Edge Layer"
        CF["Cloudflare<br/>DDoS Protection<br/>SSL Termination"]
    end
    
    subgraph "Load Balancing"
        LB["Application Load Balancer<br/>Round Robin + Least Connections"]
    end
    
    subgraph "Auto-Scaling Group"
        direction LR
        GO1["Go Instance 1<br/>Handling 5k req/s"]
        GO2["Go Instance 2<br/>Handling 5k req/s"]
        GO3["Go Instance 3<br/>Handling 5k req/s"]
        GO_N["Go Instance N<br/>(Auto-scaled)"]
    end
    
    subgraph "Backend Services"
        REDIS["Redis Cluster<br/>Cache + Pub/Sub"]
        PG_MASTER["PostgreSQL Master<br/>(Writes)"]
        PG_REPLICA1["PostgreSQL Replica 1<br/>(Reads - US)"]
        PG_REPLICA2["PostgreSQL Replica 2<br/>(Reads - EU)"]
        PG_REPLICA3["PostgreSQL Replica 3<br/>(Reads - ASIA)"]
    end
    
    USERS --> CF
    CF --> LB
    
    LB --> GO1
    LB --> GO2
    LB --> GO3
    LB --> GO_N
    
    GO1 --> REDIS
    GO2 --> REDIS
    GO3 --> REDIS
    
    GO1 -->|Writes| PG_MASTER
    GO2 -->|Reads| PG_REPLICA1
    GO3 -->|Reads| PG_REPLICA2
    GO_N -->|Reads| PG_REPLICA3
    
    PG_MASTER -.Streaming Replication.-> PG_REPLICA1
    PG_MASTER -.Streaming Replication.-> PG_REPLICA2
    PG_MASTER -.Streaming Replication.-> PG_REPLICA3
    
    style USERS fill:#4285F4
    style CF fill:#F38020
    style LB fill:#34A853
    style REDIS fill:#DC382D
    style PG_MASTER fill:#FF6B6B
```

### Performance Targets

```mermaid
graph LR
    subgraph "Performance Metrics"
        API_LATENCY["API Response Time<br/>Target: p95 < 50ms<br/>p99 < 100ms"]
        WS_LATENCY["WebSocket Message<br/>Target: < 20ms"]
        DB_QUERY["Database Query<br/>Target: < 30ms"]
        CACHE_HIT["Cache Hit Ratio<br/>Target: > 85%"]
        THROUGHPUT["Throughput<br/>Target: 50k+ req/s"]
        UPTIME["Uptime<br/>Target: 99.99%"]
    end
    
    subgraph "Monitoring"
        PROMETHEUS["Prometheus"]
        GRAFANA["Grafana Dashboard"]
        ALERTS["Alert Manager"]
    end
    
    API_LATENCY --> PROMETHEUS
    WS_LATENCY --> PROMETHEUS
    DB_QUERY --> PROMETHEUS
    CACHE_HIT --> PROMETHEUS
    THROUGHPUT --> PROMETHEUS
    UPTIME --> PROMETHEUS
    
    PROMETHEUS --> GRAFANA
    PROMETHEUS --> ALERTS
    
    style THROUGHPUT fill:#34A853
    style UPTIME fill:#4285F4
```

### Caching Strategy for Performance

```mermaid
graph TB
    REQUEST["Incoming Request"]
    
    subgraph "Cache Hierarchy"
        L1["L1: In-Memory<br/>(Go map/sync.Map)<br/>~1-2ms"]
        L2["L2: Redis<br/>(Distributed)<br/>~3-5ms"]
        L3["L3: PostgreSQL<br/>(Source of Truth)<br/>~20-50ms"]
    end
    
    REQUEST --> CHECK_L1{Check L1}
    CHECK_L1 -->|Hit| RETURN_L1["Return from Memory<br/>⚡ 1ms"]
    CHECK_L1 -->|Miss| CHECK_L2{Check L2}
    
    CHECK_L2 -->|Hit| RETURN_L2["Return from Redis<br/>⚡ 3ms"]
    CHECK_L2 -->|Miss| QUERY_L3["Query PostgreSQL<br/>⚡ 30ms"]
    
    QUERY_L3 --> STORE_L2["Store in Redis<br/>(TTL: 5-60 min)"]
    STORE_L2 --> STORE_L1["Store in Memory<br/>(TTL: 1-5 min)"]
    STORE_L1 --> RETURN_L3["Return Data"]
    
    RETURN_L2 --> STORE_L1
    
    style RETURN_L1 fill:#34A853
    style RETURN_L2 fill:#FBBC04
    style QUERY_L3 fill:#EA4335
```

---

## 📊 Summary

### Key Architecture Decisions

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Web Frontend** | Next.js 15 + React 19 | SSR/SSG, Turbopack, best SEO |
| **Android** | Jetpack Compose | Native performance, declarative UI, 120fps |
| **iOS** | SwiftUI | Native performance, declarative UI, 120fps |
| **Primary API** | Go + Fiber v3 | 50k+ req/s, low latency, concurrency |
| **ML API** | Python + FastAPI | ML libraries, async support |
| **Database** | PostgreSQL | ACID, JSON support, mature |
| **Cache** | Redis | Fastest, pub/sub, distributed |
| **Real-time** | WebSocket + Socket.io | Bidirectional, auto-reconnect |
| **Multi-tenancy** | Schema-per-tenant | Data isolation, security, performance |
| **Deployment** | GCP Cloud Run | Serverless, auto-scaling, cost-effective |

### Performance Characteristics

- **API Throughput:** 50,000+ requests/second
- **API Latency:** p95 < 50ms, p99 < 100ms
- **WebSocket Latency:** < 20ms message delivery
- **Database Queries:** < 30ms average
- **Cache Hit Ratio:** > 85%
- **Uptime SLA:** 99.99% (52 minutes/year downtime)
- **Mobile FPS:** 120fps (native animations)
- **Web FPS:** 60fps (perceived as native)

---

**End of Architecture Diagrams**
