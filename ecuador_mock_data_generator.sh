#!/bin/bash

##############################################################################
# Ecuador Mock Data Generator - Realistic Government Metrics
##############################################################################
# Generates comprehensive mock data for Ecuador government efficiency metrics
# Supporting the $6.7B opportunity visualization with accurate context

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/otel-simple.sh" || true

# Configuration
DATA_DIR="$SCRIPT_DIR/ecuador_demo_data"
LOG_FILE="$SCRIPT_DIR/logs/ecuador_data_generator.log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Ecuador geographic structure
declare -A REGIONS=(
    ["costa"]="7"
    ["sierra"]="10"
    ["oriente"]="6"
    ["galapagos"]="1"
)

declare -a PROVINCES=(
    "Azuay" "Bolivar" "Canar" "Carchi" "Chimborazo" "Cotopaxi"
    "El_Oro" "Esmeraldas" "Galapagos" "Guayas" "Imbabura" "Loja"
    "Los_Rios" "Manabi" "Morona_Santiago" "Napo" "Orellana" "Pastaza"
    "Pichincha" "Santa_Elena" "Santo_Domingo" "Sucumbios" "Tungurahua" "Zamora_Chinchipe"
)

declare -a MINISTRIES=(
    "Finance" "Health" "Education" "Agriculture" "Tourism" "Transport"
    "Energy" "Environment" "Labor" "Justice" "Defense" "Interior"
    "Foreign_Relations" "Economic_Policy" "Social_Development" "Culture"
    "Public_Works" "Telecommunications" "Mining" "Production" "Housing"
    "Sports" "Urban_Development" "Public_Security"
)

# Economic constants (in millions USD)
declare -A ECONOMIC_DATA=(
    ["gdp_total"]=115500
    ["fiscal_deficit"]=5200
    ["admin_overhead"]=2000
    ["procurement_waste_min"]=600
    ["procurement_waste_max"]=1500
    ["current_efficiency"]=0.30  # 30% efficiency
    ["target_efficiency"]=0.85   # 85% with CiviqCore
)

# Initialize data directories
mkdir -p "$DATA_DIR"/{raw,processed,api_ready}
mkdir -p "$(dirname "$LOG_FILE")"

# Initialize telemetry
init_telemetry() {
    local trace_id=$(generate_trace_id)
    local span_id=$(generate_span_id)
    
    export OTEL_TRACE_ID="$trace_id"
    export OTEL_SPAN_ID="$span_id"
    export OTEL_SERVICE_NAME="ecuador-data-generator"
}

# Log with timestamp
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Generate random number in range
random_range() {
    local min="$1"
    local max="$2"
    echo $((min + RANDOM % (max - min + 1)))
}

# Generate realistic variance (±20%)
add_variance() {
    local base="$1"
    local variance=$((base * 20 / 100))
    local min=$((base - variance))
    local max=$((base + variance))
    random_range "$min" "$max"
}

# Generate time series data
generate_time_series() {
    local metric_name="$1"
    local base_value="$2"
    local periods="${3:-12}"  # months
    local trend="${4:-flat}"  # flat, increasing, decreasing
    
    local data_file="$DATA_DIR/raw/${metric_name}_time_series.json"
    
    echo "Generating time series for $metric_name..."
    
    {
        echo "{"
        echo "  \"metric\": \"$metric_name\","
        echo "  \"base_value\": $base_value,"
        echo "  \"trend\": \"$trend\","
        echo "  \"periods\": $periods,"
        echo "  \"data\": ["
        
        for ((i=0; i<periods; i++)); do
            local month=$(date -v-${i}m +"%Y-%m" 2>/dev/null || date -d "$i months ago" +"%Y-%m")
            local value="$base_value"
            
            # Apply trend
            case "$trend" in
                "increasing")
                    value=$((base_value + (i * base_value / 50)))  # 2% increase per period
                    ;;
                "decreasing")
                    value=$((base_value - (i * base_value / 50)))  # 2% decrease per period
                    ;;
                "volatile")
                    value=$(add_variance "$base_value")
                    ;;
            esac
            
            # Add realistic variance
            value=$(add_variance "$value")
            
            echo "    {"
            echo "      \"period\": \"$month\","
            echo "      \"value\": $value"
            echo -n "    }"
            
            if [[ $i -lt $((periods - 1)) ]]; then
                echo ","
            else
                echo ""
            fi
        done
        
        echo "  ]"
        echo "}"
    } > "$data_file"
}

# Generate ministry-specific data
generate_ministry_data() {
    local ministry="$1"
    local span_id=$(generate_span_id)
    start_span "$span_id" "generate_ministry_$ministry" "$OTEL_SPAN_ID"
    
    log "INFO" "Generating data for Ministry of $ministry"
    
    # Base metrics (vary by ministry importance)
    local budget_base
    local employees_base
    local efficiency_base
    
    case "$ministry" in
        "Finance"|"Health"|"Education"|"Defense")
            budget_base=800  # High-priority ministries
            employees_base=15000
            efficiency_base=35
            ;;
        "Agriculture"|"Transport"|"Energy"|"Justice")
            budget_base=400  # Medium-priority ministries
            employees_base=8000
            efficiency_base=30
            ;;
        *)
            budget_base=200  # Standard ministries
            employees_base=3000
            efficiency_base=25
            ;;
    esac
    
    # Current state metrics
    local current_budget=$(add_variance "$budget_base")
    local current_employees=$(add_variance "$employees_base")
    local current_efficiency=$(add_variance "$efficiency_base")
    local current_process_time=$(random_range 60 90)  # days
    local current_cost_per_transaction=$(random_range 2000 3000)  # USD
    local citizen_satisfaction=$(random_range 20 40)  # percent
    
    # Optimized state (with CiviqCore)
    local optimized_efficiency=$((current_efficiency * 3))  # 3x improvement
    local optimized_process_time=2  # hours converted to days
    local optimized_cost_per_transaction=$((current_cost_per_transaction / 25))  # 96% reduction
    local optimized_satisfaction=$(random_range 80 95)  # percent
    
    # Calculate savings
    local annual_transactions=$(random_range 50000 200000)
    local current_annual_cost=$((annual_transactions * current_cost_per_transaction))
    local optimized_annual_cost=$((annual_transactions * optimized_cost_per_transaction))
    local annual_savings=$((current_annual_cost - optimized_annual_cost))
    
    # Generate ministry data file
    local ministry_file="$DATA_DIR/processed/ministry_${ministry,,}.json"
    cat > "$ministry_file" <<EOF
{
    "ministry": "$ministry",
    "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "current_state": {
        "annual_budget_millions": $current_budget,
        "employees": $current_employees,
        "efficiency_score": $current_efficiency,
        "avg_process_time_days": $current_process_time,
        "cost_per_transaction": $current_cost_per_transaction,
        "citizen_satisfaction_percent": $citizen_satisfaction,
        "annual_transactions": $annual_transactions,
        "annual_cost_millions": $(echo "scale=2; $current_annual_cost / 1000000" | bc)
    },
    "optimized_state": {
        "efficiency_score": $optimized_efficiency,
        "avg_process_time_hours": 2,
        "cost_per_transaction": $optimized_cost_per_transaction,
        "citizen_satisfaction_percent": $optimized_satisfaction,
        "annual_cost_millions": $(echo "scale=2; $optimized_annual_cost / 1000000" | bc)
    },
    "transformation_impact": {
        "efficiency_improvement_percent": $(echo "scale=1; ($optimized_efficiency - $current_efficiency) * 100 / $current_efficiency" | bc),
        "time_reduction_percent": $(echo "scale=1; (1 - 2.0/24/$current_process_time) * 100" | bc),
        "cost_reduction_percent": $(echo "scale=1; (1 - $optimized_cost_per_transaction * 1.0 / $current_cost_per_transaction) * 100" | bc),
        "annual_savings_millions": $(echo "scale=2; $annual_savings / 1000000" | bc),
        "satisfaction_improvement": $((optimized_satisfaction - citizen_satisfaction))
    },
    "risk_factors": {
        "implementation_complexity": "$(case "$ministry" in Finance|Health|Defense) echo "high";; *) echo "medium";; esac)",
        "change_resistance": "$(random_range 20 60)",
        "technical_debt": "$(case "$ministry" in Transport|Energy) echo "high";; *) echo "medium";; esac)"
    }
}
EOF
    
    end_span "$span_id" "success"
}

# Generate provincial data
generate_provincial_data() {
    local province="$1"
    local span_id=$(generate_span_id)
    start_span "$span_id" "generate_province_$province" "$OTEL_SPAN_ID"
    
    log "INFO" "Generating data for Province of $province"
    
    # Population and economic data (realistic ranges)
    local population
    local gdp_contribution
    local cantons
    
    case "$province" in
        "Guayas"|"Pichincha")  # Major economic centers
            population=$(random_range 3000000 4500000)
            gdp_contribution=$(random_range 25 35)
            cantons=$(random_range 20 25)
            ;;
        "Azuay"|"Manabi"|"El_Oro")  # Important provinces
            population=$(random_range 500000 1000000)
            gdp_contribution=$(random_range 5 10)
            cantons=$(random_range 10 15)
            ;;
        "Galapagos")  # Special case
            population=$(random_range 25000 35000)
            gdp_contribution=1
            cantons=3
            ;;
        *)  # Standard provinces
            population=$(random_range 200000 800000)
            gdp_contribution=$(random_range 2 8)
            cantons=$(random_range 5 12)
            ;;
    esac
    
    # Administrative efficiency metrics
    local current_digital_adoption=$(random_range 1 5)  # Very low
    local current_service_centers=$(random_range 2 8)
    local current_wait_time_days=$(random_range 15 45)
    
    # Optimized metrics
    local optimized_digital_adoption=$(random_range 60 80)
    local optimized_service_centers=$((current_service_centers * 2))
    local optimized_wait_time_hours=4
    
    # Calculate provincial impact
    local affected_citizens=$((population * 80 / 100))  # 80% use government services
    local annual_transactions_k=$((affected_citizens / 10))  # Average 0.1 transactions per person
    local current_admin_cost_millions=$((population * 150 / 1000000))  # $150 per capita
    local savings_millions=$((current_admin_cost_millions * 60 / 100))  # 60% savings
    
    local province_file="$DATA_DIR/processed/province_${province,,}.json"
    cat > "$province_file" <<EOF
{
    "province": "$province",
    "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "demographics": {
        "population": $population,
        "gdp_contribution_percent": $gdp_contribution,
        "number_of_cantons": $cantons,
        "urban_population_percent": $(random_range 40 85)
    },
    "current_services": {
        "digital_adoption_percent": $current_digital_adoption,
        "service_centers": $current_service_centers,
        "average_wait_time_days": $current_wait_time_days,
        "annual_admin_cost_millions": $current_admin_cost_millions,
        "citizen_satisfaction": $(random_range 25 45)
    },
    "optimized_services": {
        "digital_adoption_percent": $optimized_digital_adoption,
        "service_centers": $optimized_service_centers,
        "average_wait_time_hours": $optimized_wait_time_hours,
        "citizen_satisfaction": $(random_range 75 90)
    },
    "transformation_impact": {
        "affected_citizens": $affected_citizens,
        "annual_transactions_thousands": $annual_transactions_k,
        "potential_savings_millions": $savings_millions,
        "service_improvement_percent": $(echo "scale=1; (1 - $optimized_wait_time_hours * 1.0 / (24 * $current_wait_time_days)) * 100" | bc),
        "digital_transformation_percent": $((optimized_digital_adoption - current_digital_adoption))
    }
}
EOF
    
    end_span "$span_id" "success"
}

# Generate ROI progression data
generate_roi_data() {
    log "INFO" "Generating ROI progression analysis"
    
    local roi_file="$DATA_DIR/api_ready/roi_progression.json"
    
    cat > "$roi_file" <<EOF
{
    "analysis_name": "Ecuador CiviqCore ROI Progression",
    "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "investment_timeline": {
        "total_investment_millions": 175,
        "implementation_months": 36,
        "phases": [
            {
                "phase": "Foundation",
                "duration_months": 6,
                "investment_millions": 75,
                "scope": "Finance Ministry + Core Infrastructure",
                "expected_savings_millions": 25,
                "risk_level": "medium"
            },
            {
                "phase": "Expansion",
                "duration_months": 12,
                "investment_millions": 65,
                "scope": "5 Key Ministries + Regional Integration",
                "expected_savings_millions": 125,
                "risk_level": "medium-high"
            },
            {
                "phase": "Full Scale",
                "duration_months": 18,
                "investment_millions": 35,
                "scope": "24 Ministries + 221 Canton Integration",
                "expected_savings_millions": 300,
                "risk_level": "low"
            }
        ]
    },
    "financial_projections": {
        "baseline_waste_billions": 6.7,
        "recoverable_annually_billions": 3.5,
        "total_roi_millions": 450,
        "roi_percentage": 257,
        "payback_months": 24,
        "risk_adjusted_roi_millions": 380
    },
    "efficiency_metrics": {
        "process_time_reduction": {
            "from_days": 75,
            "to_hours": 2,
            "improvement_percent": 97.8
        },
        "cost_per_transaction": {
            "from_usd": 2400,
            "to_usd": 85,
            "reduction_percent": 96.5
        },
        "citizen_satisfaction": {
            "from_percent": 30,
            "to_percent": 85,
            "improvement_points": 55
        }
    },
    "geographic_rollout": {
        "total_provinces": 24,
        "total_cantons": 221,
        "affected_population": 17640000,
        "rollout_sequence": [
            {"quarter": "Q1-Q2", "provinces": 3, "cantons": 45, "priority": "pilot"},
            {"quarter": "Q3-Q4", "provinces": 8, "cantons": 75, "priority": "expansion"},
            {"quarter": "Q5-Q6", "provinces": 13, "cantons": 101, "priority": "scale"}
        ]
    }
}
EOF
}

# Generate real-time dashboard data
generate_dashboard_data() {
    log "INFO" "Generating real-time dashboard data"
    
    local dashboard_file="$DATA_DIR/api_ready/dashboard_realtime.json"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Simulate real-time metrics
    local active_processes=$(random_range 1200 1800)
    local avg_response_time=$(random_range 800 1200)  # milliseconds
    local error_rate=$(echo "scale=2; $(random_range 0 5) / 100" | bc)
    local citizen_services_today=$(random_range 25000 35000)
    
    cat > "$dashboard_file" <<EOF
{
    "timestamp": "$timestamp",
    "system_status": "operational",
    "performance_metrics": {
        "active_processes": $active_processes,
        "avg_response_time_ms": $avg_response_time,
        "error_rate_percent": $error_rate,
        "throughput_per_hour": $(random_range 8000 12000),
        "system_load_percent": $(random_range 45 75)
    },
    "daily_statistics": {
        "citizen_services_completed": $citizen_services_today,
        "documents_processed": $(random_range 15000 25000),
        "digital_transactions": $(random_range 18000 28000),
        "cost_savings_today_usd": $(random_range 180000 250000)
    },
    "ministry_status": [
$(for ministry in "${MINISTRIES[@]}"; do
    local status=("operational" "degraded" "maintenance")
    local health=$(random_range 85 100)
    echo "        {"
    echo "            \"ministry\": \"$ministry\","
    echo "            \"status\": \"${status[RANDOM % 3]}\","
    echo "            \"health_score\": $health,"
    echo "            \"active_users\": $(random_range 50 200)"
    echo -n "        }"
    if [[ "$ministry" != "${MINISTRIES[-1]}" ]]; then
        echo ","
    fi
done)
    ],
    "alerts": [
        {
            "level": "info",
            "message": "System performing optimally",
            "timestamp": "$timestamp"
        }
    ]
}
EOF
}

# Generate API endpoints data
generate_api_data() {
    log "INFO" "Generating API endpoint data"
    
    # Health check endpoint
    cat > "$DATA_DIR/api_ready/health.json" <<EOF
{
    "status": "healthy",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "version": "1.0.0",
    "uptime_seconds": $(random_range 3600 86400),
    "components": {
        "database": "healthy",
        "cache": "healthy",
        "external_apis": "healthy"
    }
}
EOF

    # ROI calculation endpoint
    cat > "$DATA_DIR/api_ready/roi_calculate.json" <<EOF
{
    "calculation_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "input_parameters": {
        "investment_millions": 175,
        "implementation_months": 36,
        "risk_factor": 0.15
    },
    "results": {
        "total_return_millions": 450,
        "net_benefit_millions": 275,
        "roi_percentage": 257,
        "payback_period_months": 24,
        "irr_percentage": 35.8,
        "npv_millions": 198
    },
    "sensitivity_analysis": {
        "conservative": {"roi": 180, "payback_months": 30},
        "optimistic": {"roi": 320, "payback_months": 18}
    }
}
EOF

    # Charts test endpoint
    cat > "$DATA_DIR/api_ready/charts_test.json" <<EOF
{
    "chart_performance": {
        "roi_waterfall": {"render_time_ms": $(random_range 200 400), "status": "ready"},
        "ministry_efficiency": {"render_time_ms": $(random_range 150 300), "status": "ready"},
        "geographic_coverage": {"render_time_ms": $(random_range 180 350), "status": "ready"},
        "timeline_gantt": {"render_time_ms": $(random_range 250 450), "status": "ready"}
    },
    "data_freshness": {
        "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "cache_status": "fresh",
        "next_refresh": "$(date -u -v+1H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "1 hour" +"%Y-%m-%dT%H:%M:%SZ")"
    }
}
EOF
}

# Generate all data
generate_all_data() {
    echo -e "${CYAN}🏗️  Generating Ecuador Demo Data${NC}"
    echo "================================"
    echo "Creating comprehensive mock data for \$6.7B opportunity demo"
    echo ""
    
    init_telemetry
    
    # Generate ministry data
    echo -e "${YELLOW}📊 Generating Ministry Data...${NC}"
    for ministry in "${MINISTRIES[@]}"; do
        generate_ministry_data "$ministry"
    done
    echo "✅ Generated data for ${#MINISTRIES[@]} ministries"
    
    # Generate provincial data
    echo -e "\n${YELLOW}🗺️  Generating Provincial Data...${NC}"
    for province in "${PROVINCES[@]}"; do
        generate_provincial_data "$province"
    done
    echo "✅ Generated data for ${#PROVINCES[@]} provinces"
    
    # Generate ROI and dashboard data
    echo -e "\n${YELLOW}💰 Generating Financial Data...${NC}"
    generate_roi_data
    generate_dashboard_data
    generate_api_data
    echo "✅ Generated ROI and dashboard data"
    
    # Generate time series data
    echo -e "\n${YELLOW}📈 Generating Time Series Data...${NC}"
    generate_time_series "admin_costs" 2000 12 "increasing"
    generate_time_series "efficiency_score" 30 12 "flat"
    generate_time_series "citizen_satisfaction" 35 12 "volatile"
    generate_time_series "digital_adoption" 2 12 "increasing"
    echo "✅ Generated time series data"
    
    # Create data summary
    local summary_file="$DATA_DIR/data_generation_summary.json"
    cat > "$summary_file" <<EOF
{
    "generation_completed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "data_scope": {
        "ministries": ${#MINISTRIES[@]},
        "provinces": ${#PROVINCES[@]},
        "cantons": 221,
        "total_files_generated": $(find "$DATA_DIR" -name "*.json" | wc -l | tr -d ' ')
    },
    "financial_summary": {
        "total_opportunity_billions": 6.7,
        "investment_required_millions": 175,
        "projected_roi_millions": 450,
        "affected_population": 17640000
    },
    "data_quality": {
        "variance_applied": "±20%",
        "time_series_periods": 12,
        "real_time_simulation": "enabled"
    }
}
EOF
    
    echo -e "\n${GREEN}✅ Data generation complete!${NC}"
    echo "Generated $(find "$DATA_DIR" -name "*.json" | wc -l | tr -d ' ') data files"
    echo "Summary: $summary_file"
    
    log "INFO" "Data generation completed successfully"
}

# Data refresh simulation
refresh_realtime_data() {
    echo -e "${BLUE}🔄 Refreshing Real-time Data${NC}"
    
    # Update dashboard data with new timestamp and metrics
    generate_dashboard_data
    
    # Update health status
    cat > "$DATA_DIR/api_ready/health.json" <<EOF
{
    "status": "healthy",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "version": "1.0.0",
    "uptime_seconds": $(random_range 3600 86400),
    "components": {
        "database": "healthy",
        "cache": "healthy",
        "external_apis": "healthy"
    }
}
EOF
    
    echo "✅ Real-time data refreshed"
}

# Data validation
validate_data() {
    echo -e "${CYAN}🔍 Validating Generated Data${NC}"
    echo "==========================="
    
    local validation_passed=true
    
    # Check ministry files
    echo "Checking ministry data files..."
    for ministry in "${MINISTRIES[@]}"; do
        local file="$DATA_DIR/processed/ministry_${ministry,,}.json"
        if [[ -f "$file" ]] && jq empty "$file" 2>/dev/null; then
            echo "✅ $ministry"
        else
            echo "❌ $ministry - Invalid or missing"
            validation_passed=false
        fi
    done
    
    # Check essential API files
    echo -e "\nChecking API data files..."
    local api_files=("health.json" "roi_calculate.json" "charts_test.json" "dashboard_realtime.json")
    for file in "${api_files[@]}"; do
        local path="$DATA_DIR/api_ready/$file"
        if [[ -f "$path" ]] && jq empty "$path" 2>/dev/null; then
            echo "✅ $file"
        else
            echo "❌ $file - Invalid or missing"
            validation_passed=false
        fi
    done
    
    if $validation_passed; then
        echo -e "\n${GREEN}✅ All data validation passed${NC}"
        return 0
    else
        echo -e "\n${RED}❌ Data validation failed${NC}"
        return 1
    fi
}

# Main execution
case "${1:-help}" in
    "generate")
        generate_all_data
        ;;
    "refresh")
        refresh_realtime_data
        ;;
    "validate")
        validate_data
        ;;
    "ministry")
        generate_ministry_data "${2:-Finance}"
        ;;
    "province")
        generate_provincial_data "${2:-Pichincha}"
        ;;
    "clean")
        echo "Cleaning generated data..."
        rm -rf "$DATA_DIR"
        echo "✅ Data cleaned"
        ;;
    *)
        echo "Ecuador Mock Data Generator"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  generate  - Generate all mock data"
        echo "  refresh   - Refresh real-time data only"
        echo "  validate  - Validate all generated data"
        echo "  ministry [name] - Generate specific ministry data"
        echo "  province [name] - Generate specific province data"
        echo "  clean     - Clean all generated data"
        echo ""
        echo "Generated Data Structure:"
        echo "  $DATA_DIR/raw/           - Time series data"
        echo "  $DATA_DIR/processed/     - Ministry and province data"
        echo "  $DATA_DIR/api_ready/     - API endpoint responses"
        echo ""
        echo "This generates realistic Ecuador government data supporting"
        echo "the \$6.7B efficiency opportunity presentation."
        ;;
esac