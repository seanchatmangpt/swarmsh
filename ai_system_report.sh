SwarmSH System Report
===================
System Health: {{ system.health }}/100
Total Agents: {{ agents.count }}
Active Traces: {{ telemetry.spans }}

{% if system.health > 80 %}
✅ System is running optimally
{% elif system.health > 60 %}
⚠️ System needs attention
{% else %}
❌ System requires immediate action
{% endif %}

Active Agents:
{% for agent in agents.list %}
- {{ agent.id }}: {{ agent.role }} ({{ agent.status }})
{% endfor %}

Generated at: {{ timestamp }}
