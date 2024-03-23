swallow_stdin() {
    while read -t 0 notused; do
        read input
    done
}
revert() {
    echo "This option will re-enroll your chromebook restore to before fakemurk was run. This is useful if you need to quickly go back to normal"
    echo "THIS IS A PERMANENT CHANGE!! YOU WILL NOT BE ABLE TO GO BACK UNLESS YOU UNENROLL AGAIN AND RUN THE SCRIPT, AND IF YOU UPDATE TO THE VERSION SH1MMER IS PATCHED, YOU MAY BE STUCK ENROLLED"
    echo "ARE YOU SURE YOU WANT TO CONTINUE? (press enter to continue, ctrl-c to cancel)"
    swallow_stdin
    read -r
    sleep 4
    echo "setting kernel priority"

    DST=/dev/$(get_largest_nvme_namespace)

    if doas "((\$(cgpt show -n \"$DST\" -i 2 -P) > \$(cgpt show -n \"$DST\" -i 4 -P)))"; then
        doas cgpt add "$DST" -i 2 -P 0
        doas cgpt add "$DST" -i 4 -P 1
    else
        doas cgpt add "$DST" -i 4 -P 0
        doas cgpt add "$DST" -i 2 -P 1
    fi
    echo "setting vpd"
    doas vpd -i RW_VPD -s check_enrollment=1
    doas vpd -i RW_VPD -s block_devmode=1
    doas crossystem.old block_devmode=1
    
    rm -f /stateful_unfucked

    echo "Done. Press enter to reboot"
    swallow_stdin
    read -r
    echo "bye!"
    sleep 2
    doas reboot
    sleep 1000
runjob revert ;;