#!/bin/bash
set -euo pipefail

# دالة لكتابة الرسائل في ملف اللوغ
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [فحص-النظام] $1" | sudo tee -a /var/log/syshealth.log
}

# فحص استخدام الهارديسك
check_disk() {
    local usage
    usage=$(df -h / | awk 'NR==2 {gsub(/%/,""); print $5}')
    if [[ $usage -gt 90 ]]; then
        log "مشكلة: الهارديسك مليان ${usage}%"
        exit 1
    else
        log "الهارديسك تمام (${usage}%)"
    fi
}

# فحص استخدام البروسيسور
check_cpu() {
    local cpu_idle
    local cpu_used
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'.' -f1)
    cpu_used=$((100 - cpu_idle))
    if [[ $cpu_used -gt 80 ]]; then
        log "مشكلة: البروسيسور شغال ${cpu_used}%"
        exit 2
    else
        log "البروسيسور تمام (${cpu_used}%)"
    fi
}

# فحص حالة خدمة (هنستخدم nginx كمثال)
check_service() {
    if ! systemctl is-active --quiet nginx; then
        log "مشكلة: خدمة nginx واقفة"
        exit 3
    else
        log "خدمة nginx شغالة"
    fi
}

# تشغيل الفحوصات
main() {
    log "=== بدأ فحص صحة النظام ==="
    check_disk
    check_cpu
    check_service
    log "=== كل الفحوصات تمام ==="
    exit 0
}

main
