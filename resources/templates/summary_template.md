# {{summary['platform']}}
{% if summary['action']|length > 0 %}
## ATT&CK Navigator View

<iframe src="https://mitre-attack.github.io/attack-navigator/enterprise/#layerURL=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FCloud-Katana%2Fmain%2Fdocs%2Fnotebooks%2F{{summary['platform']|lower}}%2F{{summary['platform']|lower}}.json&tabs=false&selecting_techniques=false" width="950" height="450"></iframe>

## Table View

|Created|Action|Description|Author|
| :---| :---| :---| :---|
{% for s in summary['action']|sort(attribute='creationDate',reverse = True) %}|{{s['creationDate']}} |[{{s['title']}}](https://cloud-katana.com/notebooks/{{summary['platform']|lower}}/{{s['location']}}/{{s['title']}}.html) |{{s['description']|trim}} |{% for contributor in s['contributors'] %}{{contributor}}{% if not loop.last %}, {% endif %}{% endfor %} |
{% endfor %}{% endif %}
