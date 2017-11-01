if (Get-Command ConvertTo-JSON -errorAction SilentlyContinue) {
    @{
        'PS1_JSON_FACT1' = 'value1'
        'ps1_json_fact2' = 2
        'ps1_json_fact3' = $True
        'ps1_json_fact4' = @('first', 'second')
        'ps1_json_fact5' = $Null
        'ps1_json_fact6' = @{ 'a' = 'b'; 'c' = 'd' }
    } | ConvertTo-JSON -Depth 1 -Compress
} else {
@'
{
    "PS1_JSON_FACT1": "value1",
    "ps1_json_fact2": 2,
    "ps1_json_fact3": true,
    "ps1_json_fact4": ["first", "second"],
    "ps1_json_fact5": null,
    "ps1_json_fact6": { "a": "b", "c": "d" }
}
'@
}
