 #!/bin/bash

# Функции-хелперы 
function disable() {
     echo -e "ОТКЛЮЧЕНИЕ модуля $1"
     ./scripts/config --disable "$1"
}

function enable() {
     echo -e "\nВКЛЮЧЕНИЕ модуля $1\n"
     ./scripts/config --enable "$1"
}

function set_val() {
     echo -e "\nУСТАНОВКА $1 = $2\n"
     ./scripts/config --set-val "$1" "$2"
}

function finalize_config() {
     echo "--- Применение изменений и проверка зависимостей ---"
     make olddefconfig
}

################ START SCRIPT ####################

echo "=== Настройка конфигурации  ==="

# 1. Отключение безопасности 
disable "SECURITY_SELINUX"
disable "SECURITY_SMACK"
disable "SECURITY_TOMOYO"
disable "SECURITY_APPARMOR"
disable "SECURITY_YAMA"

# 2. Отключение KASLR 
disable "RANDOMIZE_BASE"

# 3. Отключение защит процессора и оптимизация 
disable "CPU_MITIGATIONS"
disable "MITIGATION_SPECTRE_BHI"
disable "MITIGATION_RFDS"
disable "PAGE_TABLE_ISOLATION"
disable "ZSWAP"

# 4. Отключение BPF 
disable "BPF"
disable "BPF_SYSCALL"
disable "BPF_JIT"
disable "BPF_EVENTS"
disable "BPFILTER"

# 5. Включение инструментов отладки 
enable "DEBUG_FS"
enable "FTRACE"
enable "FUNCTION_TRACER"
enable "DYNAMIC_FTRACE"
enable "FUNCTION_GRAPH_TRACER"
enable "STACK_TRACER"
enable "KUNIT"
enable "KUNIT_TEST"
enable "KASAN"
enable "STACKTRACE"
enable "KASAN_GENERIC"
enable "KASAN_INLINE"
enable "KASAN_EXTRA_INFO"
enable "KGDB"
enable "KGDB_SERIAL_CONSOLE"
enable "CONSOLE_POLL"
enable "KPROBES"
enable "KPROBE_EVENT"

# 6. Настройка отладочной информации
disable "DEBUG_INFO_NONE"
enable "DEBUG_INFO"
set_val "CONFIG_DEBUG_INFO_DWARF5" "y"

# Финализация
finalize_config

# Проверка 
echo -e "\nПроверка критических настроек:"
grep "CONFIG_DEBUG_INFO" .config
grep "CONFIG_KASAN" .config
grep "CONFIG_RANDOMIZE_BASE" .config
