#!/usr/bin/env php
<?php
// @description Create file containing key mappings for aerospace
// Usage: ./create-aerospace-keymaps.sh
// vim: ft=php ts=4 sw=4 sts=4 sr et

$dotfiles_env = getenv("DOTFILES") ?? '~/.dotfiles';

$dest = "$dotfiles_env/docs/aerospace-keybindings.md";

exec("aerospace config --get mode --json", $output);
$output = join(' ', $output);
$config = json_decode($output, true);

$main = $config['main'];
unset($config['main']);

function process_section(string $title, array $array)
{
    $bindings = $array['binding'] ?? [];
    ksort($bindings);

    $output = [];
    $output[] = sprintf("\n## %s\n", $title);

    $k_len = max(array_map('strlen', array_keys($bindings)));
    $v_len = max(array_map('strlen', array_values($bindings)));

    $output[] = sprintf(
        "| %s | %s |",
        str_pad('Key', $k_len + 1),
        str_pad('Command(s) and actions', $v_len + 1)
    );
    $output[] = sprintf(
        "|%s|%s|",
        str_repeat('-', $k_len + 3),
        str_repeat('-', $v_len + 3)
    );

    foreach ($bindings as $key => $value) {
        $k = str_pad($key, $k_len + 1);
        $v = str_pad($value, $v_len + 1);
        $output[] = sprintf("| %s | %s |", $k, $v);
    }

    return implode("\n", $output);
}

$contents = [];
$contents[] = "# aerospace keybindings";

$contents[] = process_section("main", $main);

ksort($config);

foreach ($config as $mode => $bindings) {
    $contents[] = process_section($mode, $bindings);
}

$contents[] = "\nFile generated: " . date("Y-m-d H:i:s") . "\n";

$config_file_name = 'config/aerospace/aerospace.toml';
$config_file_source = './../config/aerospace/aerospace.toml';
$contents[] = "Config file: [$config_file_name]($config_file_source)\n";

$file = implode("\n", $contents);
file_put_contents($dest, $file);
