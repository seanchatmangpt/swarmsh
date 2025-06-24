# System Architecture Graph

*Auto-generated architecture overview: Tue Jun 24 15:10:12 PDT 2025*

```mermaid
graph TB
    subgraph "🎯 8020 Automation Layer"
        A[8020 Cron Controller] --> B[Health Monitor]
        A --> C[Telemetry Manager]
        A --> D[Work Optimizer]
        A --> E[Performance Collector]
    end
    
    subgraph "📊 Data Layer"
        F[Telemetry Spans<br/>     501 records] --> G[Health Reports]
        F --> H[Performance Metrics]
        F --> I[System Alerts]
    end
    
    subgraph "⚙️ Configuration Layer"
        J[Coordination Config<br/>      88 files] --> K[Agent Status]
        J --> L[Work Claims]
        J --> M[System State]
    end
    
    subgraph "🔧 Execution Layer"
        N[Script Repository<br/>      85 scripts] --> O[Cron Scheduler]
        N --> P[Manual Execution]
        N --> Q[API Integration]
    end
    
    subgraph "🚨 Alerting Layer"
        R[Health Alerts] --> S[System Notifications]
        R --> T[Performance Warnings]
        R --> U[Critical Issues]
    end
    
    B --> F
    C --> F
    D --> F
    E --> F
    
    G --> R
    H --> R
    I --> R
    
    K --> B
    L --> D
    M --> C
    
    O --> A
    P --> A
    Q --> A
    
    S --> V[Operations Team]
    T --> V
    U --> V
    
    style A fill:#e3f2fd
    style F fill:#f3e5f5
    style J fill:#e8f5e8
    style N fill:#fff3e0
    style R fill:#ffebee
    style V fill:#f1f8e9
```

## Architecture Statistics
- **Automation Scripts:**       85 executable files
- **Configuration Files:**       88 data files
- **Telemetry Records:**      502 spans generated
- **Health Score:** 90/100

*Architecture snapshot: Tue Jun 24 15:10:27 PDT 2025*
