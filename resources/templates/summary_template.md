# {{summary['platform']}}
{% if summary['campaign']|length > 0 %}
## ATT&CK Navigator View

<iframe src="https://mitre-attack.github.io/attack-navigator/enterprise/#layerURL=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FCloud-Katana%2Fmain%2Fdocs%2Fsimulate%2F{{summary['platform']|lower}}%2F{{summary['platform']|lower}}.json&tabs=false&selecting_techniques=false" width="950" height="450"></iframe>

## Table View

|Created|Action|Description|Author|
| :---| :---| :---| :---|
{% for s in summary['campaign']|sort(attribute='creationDate',reverse = True) %}|{{s['metadata']['creationDate']}} |[{{s['name']}}](https://cloud-katana.com/simulate/{{summary['platform']|lower}}/{{s['location']}}/{{s['file_name']}}.html) |{{s['metadata']['description']|trim}} |{% for contributor in s['metadata']['contributors'] %}{{contributor}}{% if not loop.last %}, {% endif %}{% endfor %} |
{% endfor %}{% endif %}
